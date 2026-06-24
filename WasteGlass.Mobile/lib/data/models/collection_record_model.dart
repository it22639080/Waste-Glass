class CollectionRecordModel {
  const CollectionRecordModel({
    this.id,
    required this.tripId,
    required this.supplierCode,
    required this.clearGlassKg,
    required this.colouredGlassKg,
    required this.condition,
    required this.collectedAt,
    this.isSynced = false,
  });

  final int? id;
  final int tripId;
  final String supplierCode;
  final double clearGlassKg;
  final double colouredGlassKg;
  final String condition;
  final DateTime collectedAt;
  final bool isSynced;

  double get totalKg => clearGlassKg + colouredGlassKg;

  factory CollectionRecordModel.fromJson(Map<String, dynamic> json) {
    return CollectionRecordModel(
      id: json['id'] == null ? null : _asInt(json['id']),
      tripId: _asInt(json['tripId']),
      supplierCode: json['supplierCode']?.toString() ?? '',
      clearGlassKg: _asDouble(json['clearGlassKg']),
      colouredGlassKg: _asDouble(json['colouredGlassKg']),
      condition: json['condition']?.toString() ?? '',
      collectedAt: DateTime.tryParse(json['collectedAt']?.toString() ?? '') ??
          DateTime.now(),
      isSynced: json['isSynced'] == true || _asInt(json['isSynced']) == 1,
    );
  }

  factory CollectionRecordModel.fromDb(Map<String, dynamic> row) {
    return CollectionRecordModel(
      id: row['id'] == null ? null : _asInt(row['id']),
      tripId: _asInt(row['tripId']),
      supplierCode: row['supplierCode']?.toString() ?? '',
      clearGlassKg: _asDouble(row['clearGlassKg']),
      colouredGlassKg: _asDouble(row['colouredGlassKg']),
      condition: row['condition']?.toString() ?? '',
      collectedAt: DateTime.tryParse(row['collectedAt']?.toString() ?? '') ??
          DateTime.now(),
      isSynced: _asInt(row['isSynced']) == 1,
    );
  }

  Map<String, dynamic> toDb() {
    return {
      'tripId': tripId,
      'supplierCode': supplierCode,
      'clearGlassKg': clearGlassKg,
      'colouredGlassKg': colouredGlassKg,
      'totalKg': totalKg,
      'condition': condition,
      'collectedAt': collectedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
    };
  }

  Map<String, dynamic> toApiJson() {
    return toJson();
  }

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'supplierCode': supplierCode,
      'clearGlassKg': clearGlassKg,
      'colouredGlassKg': colouredGlassKg,
      'condition': condition,
      'collectedAt': collectedAt.toIso8601String(),
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
