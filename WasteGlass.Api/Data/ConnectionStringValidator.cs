namespace WasteGlass.Api.Data;

public static class ConnectionStringValidator
{
    private static readonly string[] PlaceholderTokens =
    [
        "YOUR_SUPABASE_DB_HOST",
        "YOUR_SUPABASE_DB_PASSWORD",
        "YOUR_PROJECT_REF",
        "YOUR_PASSWORD"
    ];

    public static string GetRequiredPostgresConnectionString(IConfiguration configuration)
    {
        var connectionString = Environment.GetEnvironmentVariable("SUPABASE_POSTGRES_CONNECTION")
            ?? configuration.GetConnectionString("SupabasePostgres")
            ?? configuration["Supabase:ConnectionString"];

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException(
                "PostgreSQL connection string is missing. Set SUPABASE_POSTGRES_CONNECTION or ConnectionStrings:SupabasePostgres.");
        }

        connectionString = NormalizeConnectionString(connectionString);

        if (PlaceholderTokens.Any(token =>
                connectionString.Contains(token, StringComparison.OrdinalIgnoreCase)))
        {
            throw new InvalidOperationException(
                "PostgreSQL connection string still contains placeholder values. Replace Host and Password with your real Supabase database connection details.");
        }

        return connectionString;
    }

    private static string NormalizeConnectionString(string connectionString)
    {
        const string environmentPrefix = "SUPABASE_POSTGRES_CONNECTION=";
        connectionString = connectionString.Trim();

        return connectionString.StartsWith(environmentPrefix, StringComparison.OrdinalIgnoreCase)
            ? connectionString[environmentPrefix.Length..].Trim()
            : connectionString;
    }
}
