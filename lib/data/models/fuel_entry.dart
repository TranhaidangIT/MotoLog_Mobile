import 'package:uuid/uuid.dart';

/// Model đại diện cho một lần đổ xăng/nạp điện
class FuelEntry {
  final String id;
  final String vehicleId;
  final DateTime date;
  final double odometer;
  final double liters;
  final double pricePerLiter;
  final double totalCost;
  final String? stationName;
  final double? stationLat;
  final double? stationLon;
  final String? fuelType;
  final bool isFull; // Đổ đầy bình không
  final String? note;
  final DateTime createdAt;

  FuelEntry({
    String? id,
    required this.vehicleId,
    required this.date,
    required this.odometer,
    required this.liters,
    required this.pricePerLiter,
    double? totalCost,
    this.stationName,
    this.stationLat,
    this.stationLon,
    this.fuelType,
    this.isFull = true,
    this.note,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        totalCost = totalCost ?? (liters * pricePerLiter),
        createdAt = createdAt ?? DateTime.now();

  /// Tạo từ Map (SQLite row)
  factory FuelEntry.fromMap(Map<String, dynamic> map) {
    return FuelEntry(
      id: map['id'] as String,
      vehicleId: map['vehicle_id'] as String,
      date: DateTime.parse(map['date'] as String),
      odometer: (map['odometer'] as num).toDouble(),
      liters: (map['liters'] as num).toDouble(),
      pricePerLiter: (map['price_per_liter'] as num).toDouble(),
      totalCost: (map['total_cost'] as num).toDouble(),
      stationName: map['station_name'] as String?,
      stationLat: map['station_lat'] != null ? (map['station_lat'] as num).toDouble() : null,
      stationLon: map['station_lon'] != null ? (map['station_lon'] as num).toDouble() : null,
      fuelType: map['fuel_type'] as String?,
      isFull: (map['is_full'] as int? ?? 1) == 1,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Chuyển thành Map để lưu SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'liters': liters,
      'price_per_liter': pricePerLiter,
      'total_cost': totalCost,
      'station_name': stationName,
      'station_lat': stationLat,
      'station_lon': stationLon,
      'fuel_type': fuelType,
      'is_full': isFull ? 1 : 0,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Chuyển thành Map để lưu Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'liters': liters,
      'price_per_liter': pricePerLiter,
      'total_cost': totalCost,
      'station_name': stationName,
      'station_lat': stationLat,
      'station_lon': stationLon,
      'fuel_type': fuelType,
      'is_full': isFull,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Tạo từ Firestore document
  factory FuelEntry.fromFirestore(Map<String, dynamic> map) {
    return FuelEntry(
      id: map['id'] as String,
      vehicleId: map['vehicle_id'] as String,
      date: DateTime.parse(map['date'] as String),
      odometer: (map['odometer'] as num).toDouble(),
      liters: (map['liters'] as num).toDouble(),
      pricePerLiter: (map['price_per_liter'] as num).toDouble(),
      totalCost: (map['total_cost'] as num).toDouble(),
      stationName: map['station_name'] as String?,
      stationLat: map['station_lat'] != null ? (map['station_lat'] as num).toDouble() : null,
      stationLon: map['station_lon'] != null ? (map['station_lon'] as num).toDouble() : null,
      fuelType: map['fuel_type'] as String?,
      isFull: map['is_full'] as bool? ?? true,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// CopyWith
  FuelEntry copyWith({
    DateTime? date,
    double? odometer,
    double? liters,
    double? pricePerLiter,
    double? totalCost,
    String? stationName,
    double? stationLat,
    double? stationLon,
    String? fuelType,
    bool? isFull,
    String? note,
  }) {
    return FuelEntry(
      id: id,
      vehicleId: vehicleId,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      liters: liters ?? this.liters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      totalCost: totalCost,
      stationName: stationName ?? this.stationName,
      stationLat: stationLat ?? this.stationLat,
      stationLon: stationLon ?? this.stationLon,
      fuelType: fuelType ?? this.fuelType,
      isFull: isFull ?? this.isFull,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }

  /// Tính tiêu hao nhiên liệu với lần trước (L/100km)
  double? consumptionWith(FuelEntry? previous) {
    if (previous == null) return null;
    final distance = odometer - previous.odometer;
    if (distance <= 0) return null;
    return (liters / distance) * 100;
  }

  @override
  bool operator ==(Object other) => other is FuelEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
