class SupplierStopModel {
  const SupplierStopModel({
    required this.stopId,
    required this.stopOrder,
    required this.supplierId,
    required this.supplierCode,
    required this.supplierName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.expectedKg,
    required this.status,
    required this.distanceFromPreviousKm,
  });

  final int stopId;
  final int stopOrder;
  final int supplierId;
  final String supplierCode;
  final String supplierName;
  final String address;
  final double latitude;
  final double longitude;
  final double expectedKg;
  final String status;
  final double distanceFromPreviousKm;

  bool get isNext => status == 'Next';
  bool get isCollected => status == 'Collected';

  factory SupplierStopModel.fromJson(Map<String, dynamic> json) {
    return SupplierStopModel(
      stopId: _asInt(json['stopId']),
      stopOrder: _asInt(json['stopOrder']),
      supplierId: _asInt(json['supplierId']),
      supplierCode: json['supplierCode']?.toString() ?? '',
      supplierName: json['supplierName']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      expectedKg: _asDouble(json['expectedKg']),
      status: json['status']?.toString() ?? 'Pending',
      distanceFromPreviousKm: _asDouble(json['distanceFromPreviousKm']),
    );
  }

  factory SupplierStopModel.fromDb(Map<String, dynamic> row) {
    return SupplierStopModel(
      stopId: _asInt(row['stopId']),
      stopOrder: _asInt(row['stopOrder']),
      supplierId: _asInt(row['supplierId']),
      supplierCode: row['supplierCode']?.toString() ?? '',
      supplierName: row['supplierName']?.toString() ?? '',
      address: row['address']?.toString() ?? '',
      latitude: _asDouble(row['latitude']),
      longitude: _asDouble(row['longitude']),
      expectedKg: _asDouble(row['expectedKg']),
      status: row['status']?.toString() ?? 'Pending',
      distanceFromPreviousKm: _asDouble(row['distanceFromPreviousKm']),
    );
  }

  Map<String, dynamic> toDb(int tripId) {
    return {
      'stopId': stopId,
      'tripId': tripId,
      'stopOrder': stopOrder,
      'supplierId': supplierId,
      'supplierCode': supplierCode,
      'supplierName': supplierName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'expectedKg': expectedKg,
      'status': status,
      'distanceFromPreviousKm': distanceFromPreviousKm,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'stopId': stopId,
      'stopOrder': stopOrder,
      'supplierId': supplierId,
      'supplierCode': supplierCode,
      'supplierName': supplierName,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'expectedKg': expectedKg,
      'status': status,
      'distanceFromPreviousKm': distanceFromPreviousKm,
    };
  }

  SupplierStopModel copyWith({String? status}) {
    return SupplierStopModel(
      stopId: stopId,
      stopOrder: stopOrder,
      supplierId: supplierId,
      supplierCode: supplierCode,
      supplierName: supplierName,
      address: address,
      latitude: latitude,
      longitude: longitude,
      expectedKg: expectedKg,
      status: status ?? this.status,
      distanceFromPreviousKm: distanceFromPreviousKm,
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
