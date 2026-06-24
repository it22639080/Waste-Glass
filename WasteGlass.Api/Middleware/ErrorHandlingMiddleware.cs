using System.Net;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;

namespace WasteGlass.Api.Middleware;

public class ErrorHandlingMiddleware(
    RequestDelegate next,
    ILogger<ErrorHandlingMiddleware> logger,
    IHostEnvironment environment)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex)
        {
            await HandleExceptionAsync(context, ex);
        }
    }

    private async Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        var statusCode = exception switch
        {
            ArgumentException => HttpStatusCode.BadRequest,
            InvalidOperationException => HttpStatusCode.BadRequest,
            DbUpdateException => HttpStatusCode.Conflict,
            _ => HttpStatusCode.InternalServerError
        };

        logger.LogError(exception, "Unhandled API error while processing {Method} {Path}.",
            context.Request.Method,
            context.Request.Path);

        var response = new ApiErrorResponse
        {
            Success = false,
            Message = statusCode == HttpStatusCode.InternalServerError
                ? "An unexpected server error occurred."
                : exception.Message,
            StatusCode = (int)statusCode,
            Path = context.Request.Path,
            TraceId = context.TraceIdentifier,
            Detail = environment.IsDevelopment() ? exception.ToString() : null
        };

        context.Response.ContentType = "application/json";
        context.Response.StatusCode = response.StatusCode;

        var json = JsonSerializer.Serialize(response, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });

        await context.Response.WriteAsync(json);
    }
}

public class ApiErrorResponse
{
    public bool Success { get; set; }
    public string Message { get; set; } = string.Empty;
    public int StatusCode { get; set; }
    public string? Path { get; set; }
    public string? TraceId { get; set; }
    public string? Detail { get; set; }
}
