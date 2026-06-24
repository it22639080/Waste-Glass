import 'supplier_stop_model.dart';

class TripSequenceModel {
  const TripSequenceModel({
    required this.tripId,
    required this.tripDate,
    required this.totalRouteDistanceKm,
    required this.remainingStops,
    required this.stops,
  });

  final int tripId;
  final DateTime tripDate;
  final double totalRouteDistanceKm;
  final int remainingStops;
  final List<SupplierStopModel> stops;

  SupplierStopModel? get currentStop {
    final nextStops = stops.where((stop) => stop.status == 'Next');
    if (nextStops.isNotEmpty) {
      return nextStops.first;
    }

    final pendingStops = stops.where((stop) => stop.status == 'Pending');
    return pendingStops.isEmpty ? null : pendingStops.first;
  }

  factory TripSequenceModel.fromJson(Map<String, dynamic> json) {
    final rawStops = json['stops'];
    return TripSequenceModel(
      tripId: _asInt(json['tripId']),
      tripDate: DateTime.tryParse(json['tripDate']?.toString() ?? '') ??
          DateTime.now(),
      totalRouteDistanceKm: _asDouble(json['totalRouteDistanceKm']),
      remainingStops: _asInt(json['remainingStops']),
      stops: rawStops is List
          ? rawStops
              .whereType<Map<String, dynamic>>()
              .map(SupplierStopModel.fromJson)
              .toList()
          : const [],
    );
  }

  factory TripSequenceModel.fromDb(
    Map<String, dynamic> trip,
    List<Map<String, dynamic>> stops,
  ) {
    return TripSequenceModel(
      tripId: _asInt(trip['tripId']),
      tripDate: DateTime.tryParse(trip['tripDate']?.toString() ?? '') ??
          DateTime.now(),
      totalRouteDistanceKm: _asDouble(trip['totalRouteDistanceKm']),
      remainingStops: _asInt(trip['remainingStops']),
      stops: stops.map(SupplierStopModel.fromDb).toList(),
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'tripId': tripId,
      'tripDate': tripDate.toIso8601String(),
      'totalRouteDistanceKm': totalRouteDistanceKm,
      'remainingStops': remainingStops,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'tripDate': tripDate.toIso8601String(),
      'totalRouteDistanceKm': totalRouteDistanceKm,
      'remainingStops': remainingStops,
      'stops': stops.map((stop) => stop.toJson()).toList(),
    };
  }

  TripSequenceModel copyWith({List<SupplierStopModel>? stops}) {
    final updatedStops = stops ?? this.stops;
    return TripSequenceModel(
      tripId: tripId,
      tripDate: tripDate,
      totalRouteDistanceKm: totalRouteDistanceKm,
      remainingStops:
          updatedStops.where((stop) => stop.status != 'Collected').length,
      stops: updatedStops,
    );
  }
}

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
