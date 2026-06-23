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
  final String? engineCapacity;
  final DateTime? inspectionDate;
  final DateTime? insuranceDate;
  final bool? isRegistered;
  final String? registrationImageUrl;
  final String? inspectionImageUrl;
  final String? insuranceImageUrl;
  final String? userId;
  final String? cachedImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int isSynced;

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
    this.engineCapacity,
    this.inspectionDate,
    this.insuranceDate,
    this.isRegistered,
    this.registrationImageUrl,
    this.inspectionImageUrl,
    this.insuranceImageUrl,
    this.userId,
    this.cachedImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isSynced = 1,
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
      engineCapacity: map['engine_capacity'] as String?,
      inspectionDate: map['inspection_date'] != null ? DateTime.parse(map['inspection_date'] as String) : null,
      insuranceDate: map['insurance_date'] != null ? DateTime.parse(map['insurance_date'] as String) : null,
      isRegistered: map['is_registered'] != null ? (map['is_registered'] as int) == 1 : null,
      registrationImageUrl: map['registration_image_url'] as String?,
      inspectionImageUrl: map['inspection_image_url'] as String?,
      insuranceImageUrl: map['insurance_image_url'] as String?,
      userId: map['user_id'] as String?,
      cachedImageUrl: map['cached_image_url'] as String?,
      isSynced: map['is_synced'] as int? ?? 1,
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
      'engine_capacity': engineCapacity,
      'inspection_date': inspectionDate?.toIso8601String(),
      'insurance_date': insuranceDate?.toIso8601String(),
      'is_registered': isRegistered != null ? (isRegistered! ? 1 : 0) : null,
      'registration_image_url': registrationImageUrl,
      'inspection_image_url': inspectionImageUrl,
      'insurance_image_url': insuranceImageUrl,
      'user_id': userId,
      'cached_image_url': cachedImageUrl,
      'is_synced': isSynced,
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
      'engine_capacity': engineCapacity,
      'inspection_date': inspectionDate?.toIso8601String(),
      'insurance_date': insuranceDate?.toIso8601String(),
      'is_registered': isRegistered != null ? (isRegistered! ? 1 : 0) : null,
      'registration_image_url': registrationImageUrl,
      'inspection_image_url': inspectionImageUrl,
      'insurance_image_url': insuranceImageUrl,
      'user_id': userId,
      'cached_image_url': cachedImageUrl,
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
    String? engineCapacity,
    DateTime? inspectionDate,
    DateTime? insuranceDate,
    bool? isRegistered,
    String? registrationImageUrl,
    String? inspectionImageUrl,
    String? insuranceImageUrl,
    String? userId,
    String? cachedImageUrl,
    int? isSynced,
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
      engineCapacity: engineCapacity ?? this.engineCapacity,
      inspectionDate: inspectionDate ?? this.inspectionDate,
      insuranceDate: insuranceDate ?? this.insuranceDate,
      isRegistered: isRegistered ?? this.isRegistered,
      registrationImageUrl: registrationImageUrl ?? this.registrationImageUrl,
      inspectionImageUrl: inspectionImageUrl ?? this.inspectionImageUrl,
      insuranceImageUrl: insuranceImageUrl ?? this.insuranceImageUrl,
      userId: userId ?? this.userId,
      cachedImageUrl: cachedImageUrl ?? this.cachedImageUrl,
      isSynced: isSynced ?? this.isSynced,
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
