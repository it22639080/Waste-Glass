import '../../core/database/local_database.dart';
import '../../core/network/api_client.dart';
import '../models/trip_report_model.dart';
import '../models/trip_sequence_model.dart';

class TripRepository {
  TripRepository({
    ApiClient? apiClient,
    LocalDatabase? database,
  })  : _apiClient = apiClient ?? ApiClient(),
        _database = database ?? LocalDatabase.instance;

  final ApiClient _apiClient;
  final LocalDatabase _database;

  Future<TripSequenceModel> getTodayTrip() async {
    try {
      final json = await _apiClient.getTodayTrip();
      final trip = TripSequenceModel.fromJson(json);
      await _database.replaceTrip(
        trip.toDb(),
        trip.stops.map((stop) => stop.toDb(trip.tripId)).toList(),
      );
      return trip;
    } catch (_) {
      final cachedTrip = await _database.getCachedTrip();
      if (cachedTrip == null) {
        rethrow;
      }

      final cachedStops = await _database.getCachedStops();
      return TripSequenceModel.fromDb(cachedTrip, cachedStops);
    }
  }

  Future<TripReportModel> getTripReport(int tripId) async {
    final json = await _apiClient.getTripReport(tripId);
    return TripReportModel.fromJson(json);
  }

  Future<List<Map<String, dynamic>>> getSuppliersForTesting() async {
    final suppliers = await _apiClient.getSuppliers();
    return suppliers
        .whereType<Map<String, dynamic>>()
        .map((supplier) => Map<String, dynamic>.from(supplier))
        .toList();
  }
}
