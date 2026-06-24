import '../../core/database/local_database.dart';
import '../../core/network/api_client.dart';
import '../models/collection_record_model.dart';

class CollectionRepository {
  CollectionRepository({
    ApiClient? apiClient,
    LocalDatabase? database,
  })  : _apiClient = apiClient ?? ApiClient(),
        _database = database ?? LocalDatabase.instance;

  final ApiClient _apiClient;
  final LocalDatabase _database;

  Future<bool> saveLocalThenTrySync(CollectionRecordModel record) async {
    final alreadySaved = await _database.hasLocalRecordForSupplier(
      record.supplierCode,
      record.tripId,
    );

    if (!alreadySaved) {
      await _database.insertCollection(record);
    }

    await _database.markStopCollectedAndAdvance(record.supplierCode);

    try {
      await _apiClient.postCollection(record.toJson());
      await _database.markAsSyncedBySupplierCode(
        record.supplierCode,
        record.tripId,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<SyncSummary> syncUnsynced() async {
    final records = await _database.getUnsyncedCollections();

    if (records.isEmpty) {
      return const SyncSummary(syncedCount: 0, failedCount: 0);
    }

    final payload = {
      'records': records.map((record) => record.toApiJson()).toList(),
    };

    final response = await _apiClient.syncCollections(payload);
    final results = response['results'];

    var syncedCount = 0;
    var failedCount = 0;

    if (results is List) {
      for (var i = 0; i < records.length; i++) {
        final result = i < results.length ? results[i] : null;
        final success =
            result is Map<String, dynamic> && result['success'] == true;

        if (success) {
          await _database.markAsSyncedBySupplierCode(
            records[i].supplierCode,
            records[i].tripId,
          );
          syncedCount++;
        } else {
          failedCount++;
        }
      }
    } else {
      failedCount = records.length;
    }

    return SyncSummary(syncedCount: syncedCount, failedCount: failedCount);
  }

  Future<List<CollectionRecordModel>> getLocalCollections() async {
    return _database.getAllCollections();
  }

  Future<List<CollectionRecordModel>> getUnsyncedCollections() async {
    return _database.getUnsyncedCollections();
  }

  Future<int> getUnsyncedCount() async {
    final records = await _database.getUnsyncedCollections();
    return records.length;
  }

  Future<bool> hasLocalRecordForSupplier(
    String supplierCode,
    int tripId,
  ) {
    return _database.hasLocalRecordForSupplier(supplierCode, tripId);
  }

  Future<void> clearSyncedRecords() {
    return _database.clearSyncedRecords();
  }
}

class SyncSummary {
  const SyncSummary({
    required this.syncedCount,
    required this.failedCount,
  });

  final int syncedCount;
  final int failedCount;
}
