import 'package:uuid/uuid.dart';

/// Model đại diện cho một chiếc xe
class Vehicle {
  final String id;
  final String name;
  final String brand;
  final String model;
  final String plateNumber;
  final int year;
  final double odometer;
  final String fuelType;
  final String? imageUrl;
  final String color;
  final String? userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    String? id,
    required this.name,
    required this.brand,
    required this.model,
    required this.plateNumber,
    required this.year,
    required this.odometer,
    required this.fuelType,
    this.imageUrl,
    this.color = '#FF6B00',
    this.userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Tạo từ Map (SQLite row)
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      plateNumber: map['plate_number'] as String,
      year: map['year'] as int,
      odometer: (map['odometer'] as num).toDouble(),
      fuelType: map['fuel_type'] as String,
      imageUrl: map['image_url'] as String?,
      color: map['color'] as String? ?? '#FF6B00',
      userId: map['user_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Chuyển thành Map để lưu SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'plate_number': plateNumber,
      'year': year,
      'odometer': odometer,
      'fuel_type': fuelType,
      'image_url': imageUrl,
      'color': color,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Chuyển thành Map để lưu Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'plate_number': plateNumber,
      'year': year,
      'odometer': odometer,
      'fuel_type': fuelType,
      'image_url': imageUrl,
      'color': color,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Tạo từ Firestore document
  factory Vehicle.fromFirestore(Map<String, dynamic> map) {
    return Vehicle.fromMap(map);
  }

  /// CopyWith
  Vehicle copyWith({
    String? name,
    String? brand,
    String? model,
    String? plateNumber,
    int? year,
    double? odometer,
    String? fuelType,
    String? imageUrl,
    String? color,
    String? userId,
  }) {
    return Vehicle(
      id: id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plateNumber: plateNumber ?? this.plateNumber,
      year: year ?? this.year,
      odometer: odometer ?? this.odometer,
      fuelType: fuelType ?? this.fuelType,
      imageUrl: imageUrl ?? this.imageUrl,
      color: color ?? this.color,
      userId: userId ?? this.userId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Tên hiển thị đầy đủ
  String get displayName => '$brand $model ($year)';

  @override
  bool operator ==(Object other) => other is Vehicle && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Vehicle(id: $id, name: $name, plate: $plateNumber)';
}
