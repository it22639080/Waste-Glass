import 'package:flutter/foundation.dart';

import '../data/models/collection_record_model.dart';
import '../data/models/supplier_stop_model.dart';
import '../data/models/trip_report_model.dart';
import '../data/models/trip_sequence_model.dart';
import '../data/repositories/collection_repository.dart';
import '../data/repositories/trip_repository.dart';

class TripProvider extends ChangeNotifier {
  TripProvider({
    TripRepository? tripRepository,
    CollectionRepository? collectionRepository,
  })  : _tripRepository = tripRepository ?? TripRepository(),
        _collectionRepository = collectionRepository ?? CollectionRepository();

  final TripRepository _tripRepository;
  final CollectionRepository _collectionRepository;

  TripSequenceModel? trip;
  SupplierStopModel? currentNextStop;
  TripReportModel? report;
  bool isLoading = false;
  bool isSubmitting = false;
  bool isSyncing = false;
  int unsyncedCount = 0;
  String? errorMessage;
  String? syncMessage;
  String? scanMessage;
  String? lastScannedCode;
  bool isFormUnlocked = false;

  SupplierStopModel? get currentStop => currentNextStop;

  Future<void> loadTodayTrip() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      _setTrip(await _tripRepository.getTodayTrip());
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      await _refreshUnsyncedCount();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTrip() => loadTodayTrip();

  Future<void> loadReport() async {
    final tripId = trip?.tripId;
    if (tripId == null) {
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      report = await _tripRepository.getTripReport(tripId);
    } catch (error) {
      final activeTrip = trip;
      if (activeTrip == null) {
        errorMessage = error.toString();
      } else {
        final localCollections =
            await _collectionRepository.getLocalCollections();
        final collectionBySupplier = {
          for (final record in localCollections) record.supplierCode: record,
        };
        final suppliers = activeTrip.stops.map((stop) {
          final collection = collectionBySupplier[stop.supplierCode];
          return SupplierReportItemModel(
            supplierCode: stop.supplierCode,
            supplierName: stop.supplierName,
            expectedKg: stop.expectedKg,
            clearGlassKg: collection?.clearGlassKg ?? 0,
            colouredGlassKg: collection?.colouredGlassKg ?? 0,
            totalKg: collection?.totalKg ?? 0,
            condition: collection?.condition,
            status: stop.status,
            isShortfall:
                collection != null && collection.totalKg < stop.expectedKg,
          );
        }).toList();

        report = TripReportModel(
          tripId: activeTrip.tripId,
          startedAt: activeTrip.tripDate,
          duration: DateTime.now().difference(activeTrip.tripDate).inMinutes,
          totalRouteDistanceKm: activeTrip.totalRouteDistanceKm,
          totalExpectedKg:
              activeTrip.stops.fold(0.0, (sum, stop) => sum + stop.expectedKg),
          totalCollectedKg:
              localCollections.fold(0.0, (sum, record) => sum + record.totalKg),
          suppliers: suppliers,
        );
        errorMessage = 'Showing local report. Server report is unavailable.';
      }
    } finally {
      await _refreshUnsyncedCount();
      isLoading = false;
      notifyListeners();
    }
  }

  void handleBarcode(String barcode) {
    final expectedStop = currentStop;
    lastScannedCode = barcode;

    if (expectedStop == null) {
      isFormUnlocked = false;
      scanMessage = 'No remaining stops for this trip.';
    } else if (barcode.trim() == expectedStop.supplierCode) {
      isFormUnlocked = true;
      scanMessage = 'Correct supplier scanned. Collection form unlocked.';
    } else {
      isFormUnlocked = false;
      scanMessage =
          'Wrong supplier. Expected ${expectedStop.supplierCode}, scanned $barcode.';
    }

    notifyListeners();
  }

  Future<bool> submitCollection({
    required String supplierCode,
    required double clearGlassKg,
    required double colouredGlassKg,
    required String condition,
  }) async {
    final activeTrip = trip;
    final stop = currentNextStop;

    if (activeTrip == null || stop == null) {
      errorMessage = 'No active trip stop is available.';
      notifyListeners();
      return false;
    }

    final scannedSupplierCode = lastScannedCode?.trim();

    if (supplierCode != stop.supplierCode ||
        scannedSupplierCode != stop.supplierCode) {
      errorMessage =
          'Scanned supplier is not the current next stop. Expected ${stop.supplierCode}.';
      notifyListeners();
      return false;
    }

    final confirmedSupplierCode = scannedSupplierCode!;

    if (!isFormUnlocked) {
      errorMessage = 'Scan the current supplier barcode before confirming.';
      notifyListeners();
      return false;
    }

    if (clearGlassKg + colouredGlassKg <= 0) {
      errorMessage = 'Enter at least one glass quantity.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    final record = CollectionRecordModel(
      tripId: activeTrip.tripId,
      supplierCode: confirmedSupplierCode,
      clearGlassKg: clearGlassKg,
      colouredGlassKg: colouredGlassKg,
      condition: condition,
      collectedAt: DateTime.now(),
    );

    final synced = await _collectionRepository.saveLocalThenTrySync(record);
    await _refreshUnsyncedCount();

    isSubmitting = false;
    isFormUnlocked = false;
    lastScannedCode = null;
    scanMessage = synced
        ? 'Collection saved and synced.'
        : 'Collection saved locally. Sync it from Trip Report.';
    _markCurrentStopCollected(supplierCode);
    if (synced) {
      await refreshTrip();
    }
    notifyListeners();
    return true;
  }

  Future<void> syncLocalRecords() async {
    isSyncing = true;
    errorMessage = null;
    syncMessage = null;
    notifyListeners();

    try {
      final summary = await _collectionRepository.syncUnsynced();
      syncMessage =
          'Sync complete: ${summary.syncedCount} synced, ${summary.failedCount} failed.';
      await _refreshUnsyncedCount();
      await refreshTrip();
      await loadReport();
    } catch (error) {
      errorMessage = 'Sync failed. Local records are still safe.';
    } finally {
      await _refreshUnsyncedCount();
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncUnsynced() => syncLocalRecords();

  Future<void> refreshUnsyncedCount() async {
    await _refreshUnsyncedCount();
    notifyListeners();
  }

  void resetScan() {
    lastScannedCode = null;
    scanMessage = null;
    isFormUnlocked = false;
    notifyListeners();
  }

  void _setTrip(TripSequenceModel nextTrip) {
    trip = nextTrip;
    currentNextStop = _findCurrentNextStop(nextTrip);
  }

  SupplierStopModel? _findCurrentNextStop(TripSequenceModel source) {
    final nextStops = source.stops.where((stop) => stop.status == 'Next');
    return nextStops.isEmpty ? null : nextStops.first;
  }

  Future<void> _refreshUnsyncedCount() async {
    unsyncedCount = await _collectionRepository.getUnsyncedCount();
  }

  void _markCurrentStopCollected(String supplierCode) {
    final activeTrip = trip;
    if (activeTrip == null) {
      return;
    }

    var advanced = false;
    final updatedStops = activeTrip.stops.map((item) {
      if (item.supplierCode == supplierCode) {
        return item.copyWith(status: 'Collected');
      }

      if (!advanced && item.status == 'Pending') {
        advanced = true;
        return item.copyWith(status: 'Next');
      }

      return item;
    }).toList();

    _setTrip(activeTrip.copyWith(stops: updatedStops));
  }
}
