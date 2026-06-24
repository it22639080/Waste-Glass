using Microsoft.EntityFrameworkCore;
using WasteGlass.Api.Data;
using WasteGlass.Api.Middleware;
using WasteGlass.Api.Services;

var builder = WebApplication.CreateBuilder(args);

var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");

var connectionString = ConnectionStringValidator.GetRequiredPostgresConnectionString(builder.Configuration);

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new()
    {
        Title = "Waste Glass Collection API",
        Version = "v1",
        Description = "Backend API for route sequencing, barcode-based collection, offline sync, and trip reporting."
    });
    options.CustomSchemaIds(type => type.FullName?.Replace("+", ".") ?? type.Name);
});

builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
            .AllowAnyHeader()
            .AllowAnyMethod();
    });
});

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseNpgsql(connectionString);
});

builder.Services.AddScoped<RouteOptimizationService>();
builder.Services.AddScoped<TripService>();
builder.Services.AddScoped<CollectionService>();

var app = builder.Build();

app.UseMiddleware<ErrorHandlingMiddleware>();

app.UseSwagger();
app.UseSwaggerUI();

if (builder.Configuration.GetValue("EnableHttpsRedirection", false))
{
    app.UseHttpsRedirection();
}
app.UseCors("AllowAll");
app.MapControllers();

app.MapGet("/health", () => Results.Ok(new
{
    status = "Healthy",
    service = "WasteGlass.Api",
    timestamp = DateTime.UtcNow
}));

app.Lifetime.ApplicationStarted.Register(() =>
{
    _ = Task.Run(async () =>
    {
        try
        {
            using var scope = app.Services.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var routeOptimizationService = scope.ServiceProvider.GetRequiredService<RouteOptimizationService>();
            var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>()
                .CreateLogger("DatabaseStartup");

            logger.LogInformation("Starting database migration and seed.");
            await dbContext.Database.MigrateAsync();
            await DbSeeder.SeedAsync(dbContext, routeOptimizationService);
            logger.LogInformation("Database migration and seed completed.");
        }
        catch (Exception exception)
        {
            var logger = app.Services.GetRequiredService<ILoggerFactory>()
                .CreateLogger("DatabaseStartup");
            logger.LogError(exception, "Database migration or seed failed.");
        }
    });
});

await app.RunAsync();
