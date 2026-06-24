class TripReportModel {
  const TripReportModel({
    required this.tripId,
    required this.startedAt,
    this.completedAt,
    required this.duration,
    required this.totalRouteDistanceKm,
    required this.totalExpectedKg,
    required this.totalCollectedKg,
    required this.suppliers,
  });

  final int tripId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int duration;
  final double totalRouteDistanceKm;
  final double totalExpectedKg;
  final double totalCollectedKg;
  final List<SupplierReportItemModel> suppliers;

  bool get isBelowExpected => totalCollectedKg < totalExpectedKg;

  factory TripReportModel.fromJson(Map<String, dynamic> json) {
    final rawSuppliers = json['suppliers'];
    return TripReportModel(
      tripId: _asInt(json['tripId']),
      startedAt: DateTime.tryParse(json['startedAt']?.toString() ?? '') ??
          DateTime.now(),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.tryParse(json['completedAt'].toString()),
      duration: _asInt(json['duration']),
      totalRouteDistanceKm: _asDouble(json['totalRouteDistanceKm']),
      totalExpectedKg: _asDouble(json['totalExpectedKg']),
      totalCollectedKg: _asDouble(json['totalCollectedKg']),
      suppliers: rawSuppliers is List
          ? rawSuppliers
              .whereType<Map<String, dynamic>>()
              .map(SupplierReportItemModel.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'duration': duration,
      'totalRouteDistanceKm': totalRouteDistanceKm,
      'totalExpectedKg': totalExpectedKg,
      'totalCollectedKg': totalCollectedKg,
      'suppliers': suppliers.map((supplier) => supplier.toJson()).toList(),
    };
  }
}

class SupplierReportItemModel {
  const SupplierReportItemModel({
    required this.supplierCode,
    required this.supplierName,
    required this.expectedKg,
    required this.clearGlassKg,
    required this.colouredGlassKg,
    required this.totalKg,
    this.condition,
    required this.status,
    required this.isShortfall,
  });

  final String supplierCode;
  final String supplierName;
  final double expectedKg;
  final double clearGlassKg;
  final double colouredGlassKg;
  final double totalKg;
  final String? condition;
  final String status;
  final bool isShortfall;

  factory SupplierReportItemModel.fromJson(Map<String, dynamic> json) {
    return SupplierReportItemModel(
      supplierCode: json['supplierCode']?.toString() ?? '',
      supplierName: json['supplierName']?.toString() ?? '',
      expectedKg: _asDouble(json['expectedKg']),
      clearGlassKg: _asDouble(json['clearGlassKg']),
      colouredGlassKg: _asDouble(json['colouredGlassKg']),
      totalKg: _asDouble(json['totalKg']),
      condition: json['condition']?.toString(),
      status: json['status']?.toString() ?? 'Pending',
      isShortfall: json['isShortfall'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'supplierCode': supplierCode,
      'supplierName': supplierName,
      'expectedKg': expectedKg,
      'clearGlassKg': clearGlassKg,
      'colouredGlassKg': colouredGlassKg,
      'totalKg': totalKg,
      'condition': condition,
      'status': status,
      'isShortfall': isShortfall,
    };
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
