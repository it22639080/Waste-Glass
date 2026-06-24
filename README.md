# Waste Glass Collection App

- Flutter Android app
- .NET 8 Web API backend
- Supabase PostgreSQL database through Entity Framework Core
- Flutter SQLite offline-first collection storage
- Barcode scan gate using supplier IDs
- Backend route optimization using Haversine distance and Dijkstra-style nearest route ordering

## Database Choice

The backend uses Supabase PostgreSQL because it is hosted, relational, and suitable for evaluation without a local machine running. Supplier, trip, trip-stop, and collection data have clear relationships, so PostgreSQL with Entity Framework Core keeps the schema explicit and easy to migrate.

The mobile app also uses SQLite through `sqflite` because the collector must be able to save collection records during the trip even when the phone is offline. The app saves locally first, then syncs to the backend when connectivity is available.

## Main Flow

1. App opens and loads today's trip from the backend.
2. Backend seeds suppliers if needed and calculates optimized stop order.
3. Screen 1 shows route sequence, status, route distance, and remaining stops.
4. Screen 2 scans a supplier barcode.
5. Barcode text must exactly match the current stop supplier code.
6. Correct barcode unlocks the collection form.
7. Collection is saved locally first, then posted to the backend.
8. Backend marks the stop as `Collected` and advances the next `Pending` stop to `Next`.
9. Screen 3 shows report totals, shortfalls, and sync status.

## Seed Barcode Values

| Supplier Code | Supplier Name | Expected Kg | Barcode Text |
|---|---|---:|---|
| SUP001 | Green Glass Mart | 120 | SUP001 |
| SUP002 | City Bottle Center | 80 | SUP002 |
| SUP003 | Lanka Recycling Point | 150 | SUP003 |
| SUP004 | Eco Glass Supplier | 60 | SUP004 |
| SUP005 | Metro Waste Glass Hub | 100 | SUP005 |

Generate Code 128 barcodes with the exact text above using an external barcode generator. The app does not generate barcodes and has no manual barcode override.

## Backend Setup

```powershell
cd C:\Users\MSI\Documents\intern\WasteGlass.Api
dotnet restore
dotnet ef database update
dotnet run --launch-profile http
```

Local Swagger:

```text
http://localhost:5000/swagger
```

Phone on same Wi-Fi:

```text
http://YOUR_PC_IP:5000/health
```

## Flutter Setup

Set the backend URL in:

```text
WasteGlass.Mobile/lib/core/constants/api_constants.dart
```

For Android emulator:

```dart
static const String baseUrl = 'http://10.0.2.2:5000';
```

For a real phone on the same Wi-Fi:

```dart
static const String baseUrl = 'http://YOUR_PC_IP:5000';
```

For final APK submission, this must be your hosted backend URL, not localhost or a LAN IP.

Run:

```powershell
cd C:\Users\MSI\Documents\intern\WasteGlass.Mobile
flutter pub get
flutter run
```

Build APK:

```powershell
flutter build apk --release
```

## Deployment Reminder

Before submitting:

- Deploy the .NET API to Render, Railway, Azure, or similar.
- Set `SUPABASE_POSTGRES_CONNECTION` in the hosting provider.
- Update Flutter `ApiConstants.baseUrl` to the hosted API URL.
- Build a fresh release APK after changing the URL.
- Record the complete flow from route load to barcode scan, collection, report, and sync.
