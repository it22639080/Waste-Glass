# WasteGlass.Api

.NET 8 Web API backend for the Waste Glass Collection App.

## Requirements

- .NET 8 SDK
- PostgreSQL database, Supabase PostgreSQL recommended
- EF Core CLI tools

Install EF tools if needed:

```powershell
dotnet tool install --global dotnet-ef
```

## Database Choice

This backend uses Supabase PostgreSQL with Entity Framework Core. PostgreSQL is a good fit because suppliers, trips, trip stops, and collection records are relational data with clear foreign keys and status history per trip. Supabase also gives a hosted PostgreSQL database for evaluation, so the final APK can point to a live backend instead of a local machine.

The Flutter app stores collection records locally in SQLite first, then syncs them to this API. That satisfies the offline-first trip requirement while keeping PostgreSQL as the central source of truth.

## Setup

From the backend folder:

```powershell
cd C:\Users\MSI\Documents\intern\WasteGlass.Api
dotnet restore
```

## Configuration

The API reads the PostgreSQL connection string from either:

1. Environment variable: `SUPABASE_POSTGRES_CONNECTION`
2. `ConnectionStrings:SupabasePostgres` in `appsettings.json`
3. `Supabase:ConnectionString` in configuration

Supabase PostgreSQL example:

```json
{
  "ConnectionStrings": {
    "SupabasePostgres": "Host=db.YOUR_PROJECT_REF.supabase.co;Port=5432;Database=postgres;Username=postgres;Password=YOUR_PASSWORD;SSL Mode=Require;Trust Server Certificate=true"
  }
}
```

PowerShell environment variable example:

```powershell
$env:SUPABASE_POSTGRES_CONNECTION="Host=db.YOUR_PROJECT_REF.supabase.co;Port=5432;Database=postgres;Username=postgres;Password=YOUR_PASSWORD;SSL Mode=Require;Trust Server Certificate=true"
```

If you see `No such host is known`, the `Host` value is still a placeholder or was copied incorrectly. Replace `YOUR_PROJECT_REF` / `YOUR_SUPABASE_DB_HOST` with the real database host from Supabase Project Settings > Database > Connection string.

## EF Core Migrations

Create and apply the database migration:

```powershell
dotnet ef migrations add InitialCreate
dotnet ef database update
```

The app also runs pending migrations automatically on startup.

## Run

HTTP:

```powershell
dotnet run --launch-profile http
```

Open:

```text
http://localhost:5000/swagger
```

HTTPS:

```powershell
dotnet run --launch-profile https
```

Open:

```text
https://localhost:7000/swagger
```

Health check:

```text
GET http://localhost:5000/health
```

## Deployment

The API is ready for Render, Railway, Azure App Service, or similar hosting.

- Set `SUPABASE_POSTGRES_CONNECTION` in the hosting provider.
- Render/Railway usually provide a `PORT` variable; `Program.cs` binds to it automatically.
- Azure can use `ASPNETCORE_URLS` or the platform default.
- Swagger is enabled in development and production for assignment testing.
- CORS currently allows all origins for Flutter APK testing.

## Seeded Data

On startup, the seeder creates or updates these suppliers and creates one active trip for today if it does not already exist.

| Supplier Code | Supplier Name | Expected Kg | Barcode Text |
|---|---|---:|---|
| SUP001 | Green Glass Mart | 120 | SUP001 |
| SUP002 | City Bottle Center | 80 | SUP002 |
| SUP003 | Lanka Recycling Point | 150 | SUP003 |
| SUP004 | Eco Glass Supplier | 60 | SUP004 |
| SUP005 | Metro Waste Glass Hub | 100 | SUP005 |

Collector start location:

```text
Latitude: 6.9271
Longitude: 79.8612
```

## API Endpoints

```text
GET  /api/trips/today
GET  /api/trips/{tripId}/report
POST /api/collections
POST /api/collections/sync
GET  /api/suppliers
GET  /api/suppliers/barcode-test-list
GET  /api/suppliers/{supplierId}
POST /api/suppliers
GET  /health
```

## Barcode Testing

The backend seed suppliers use supplier codes `SUP001`, `SUP002`, `SUP003`, `SUP004`, and `SUP005`. `BarcodeValue` is the same as `supplierCode`, and the Flutter app expects scanned barcode text exactly equal to the current stop's `supplierCode`.

1. Go to any free online barcode generator.
2. Choose `Code 128` format.
3. Generate barcode with text `SUP001`.
4. Repeat for `SUP002` to `SUP005`.
5. Display barcode on another phone/laptop or print it.
6. Scan from the Flutter app.
7. Correct barcode unlocks form.
8. Wrong barcode blocks form.

Testing helper endpoint:

```text
GET /api/suppliers/barcode-test-list
```

| Supplier Code | Supplier Name | Expected Kg | Barcode Text |
|---|---|---:|---|
| SUP001 | Green Glass Mart | 120 | SUP001 |
| SUP002 | City Bottle Center | 80 | SUP002 |
| SUP003 | Lanka Recycling Point | 150 | SUP003 |
| SUP004 | Eco Glass Supplier | 60 | SUP004 |
| SUP005 | Metro Waste Glass Hub | 100 | SUP005 |

## Sample Requests

### GET Today's Trip

```http
GET http://localhost:5000/api/trips/today
```

Response shape:

```json
{
  "tripId": 1,
  "tripDate": "2026-06-23T00:00:00Z",
  "totalRouteDistanceKm": 17.42,
  "remainingStops": 5,
  "stops": [
    {
      "stopId": 1,
      "stopOrder": 1,
      "supplierId": 1,
      "supplierCode": "SUP001",
      "supplierName": "Green Glass Mart",
      "address": "Galle Face Center Road, Colombo 03",
      "latitude": 6.9177,
      "longitude": 79.8482,
      "expectedKg": 120,
      "status": "Next",
      "distanceFromPreviousKm": 1.87
    }
  ]
}
```

### POST Collection

```http
POST http://localhost:5000/api/collections
Content-Type: application/json
```

```json
{
  "tripId": 1,
  "supplierCode": "SUP001",
  "clearGlassKg": 50,
  "colouredGlassKg": 40,
  "condition": "Good",
  "collectedAt": "2026-06-23T10:30:00"
}
```

Success response shape:

```json
{
  "success": true,
  "message": "Collection saved successfully.",
  "collectionRecordId": 1,
  "supplierCode": "SUP001",
  "alreadySynced": false,
  "tripStatus": "InProgress",
  "nextSupplierCode": "SUP002",
  "statusCode": 201
}
```

Wrong stop example:

```json
{
  "success": false,
  "message": "Supplier 'SUP003' is not the current next stop. Expected 'SUP001'.",
  "supplierCode": "SUP003",
  "alreadySynced": false,
  "statusCode": 400
}
```

### GET Report

```http
GET http://localhost:5000/api/trips/1/report
```

Response shape:

```json
{
  "tripId": 1,
  "startedAt": "2026-06-23T09:00:00Z",
  "completedAt": null,
  "duration": 90,
  "totalRouteDistanceKm": 17.42,
  "totalExpectedKg": 510,
  "totalCollectedKg": 90,
  "suppliers": [
    {
      "supplierCode": "SUP001",
      "supplierName": "Green Glass Mart",
      "expectedKg": 120,
      "clearGlassKg": 50,
      "colouredGlassKg": 40,
      "totalKg": 90,
      "condition": "Good",
      "status": "Collected",
      "isShortfall": true
    }
  ]
}
```

### POST Sync

```http
POST http://localhost:5000/api/collections/sync
Content-Type: application/json
```

```json
{
  "records": [
    {
      "tripId": 1,
      "supplierCode": "SUP001",
      "clearGlassKg": 50,
      "colouredGlassKg": 40,
      "condition": "Good",
      "collectedAt": "2026-06-23T10:30:00"
    },
    {
      "tripId": 1,
      "supplierCode": "SUP002",
      "clearGlassKg": 30,
      "colouredGlassKg": 55,
      "condition": "Mixed",
      "collectedAt": "2026-06-23T11:10:00"
    }
  ]
}
```

Response shape:

```json
{
  "success": true,
  "syncedCount": 2,
  "failedCount": 0,
  "results": [
    {
      "supplierCode": "SUP001",
      "success": true,
      "alreadySynced": true,
      "tripStatus": "InProgress",
      "message": "Collection record was already synced."
    },
    {
      "supplierCode": "SUP002",
      "success": true,
      "alreadySynced": false,
      "tripStatus": "InProgress",
      "message": "Collection saved successfully."
    }
  ]
}
```

## Notes For Flutter Testing

- Barcode scan value should be one of `SUP001` through `SUP005`.
- The backend accepts only the current `Next` stop.
- The first stop is `Next`; other stops are `Pending`.
- After a successful collection, the next pending stop becomes `Next`.
- When all stops are collected, the trip status becomes `Completed`.
