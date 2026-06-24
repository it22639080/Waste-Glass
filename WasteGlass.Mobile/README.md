# WasteGlass.Mobile

Flutter Android app for the Waste Glass Collection assignment.

## Setup

```powershell
cd C:\Users\MSI\Documents\intern\WasteGlass.Mobile
flutter pub get
flutter run
```

## Backend URL

Edit:

```text
lib/core/constants/api_constants.dart
```

Default emulator URL:

```dart
static const String baseUrl = 'http://10.0.2.2:5000';
```

For a hosted backend, replace it with your Render, Railway, Azure, or other hosted API URL.

## Screens

The app has exactly three main screens:

- Trip Sequence
- Scan & Collect
- Trip Report

## Barcode Testing

The backend seed suppliers use supplier codes `SUP001`, `SUP002`, `SUP003`, `SUP004`, and `SUP005`. `BarcodeValue` is the same as `supplierCode`, and the app expects scanned barcode text exactly equal to the current expected stop's `supplierCode`.

1. Go to any free online barcode generator.
2. Choose `Code 128` format.
3. Generate barcode with text `SUP001`.
4. Repeat for `SUP002` to `SUP005`.
5. Display barcode on another phone/laptop or print it.
6. Scan from the Flutter app.
7. Correct barcode unlocks form.
8. Wrong barcode blocks form.

| Supplier Code | Supplier Name | Expected Kg | Barcode Text |
|---|---|---:|---|
| SUP001 | Green Glass Mart | 120 | SUP001 |
| SUP002 | City Bottle Center | 80 | SUP002 |
| SUP003 | Lanka Recycling Point | 150 | SUP003 |
| SUP004 | Eco Glass Supplier | 60 | SUP004 |
| SUP005 | Metro Waste Glass Hub | 100 | SUP005 |

The backend also exposes this helper endpoint:

```text
GET /api/suppliers/barcode-test-list
```

Do not generate barcodes inside the app.
