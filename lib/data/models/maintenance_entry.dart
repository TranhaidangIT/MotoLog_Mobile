import 'package:uuid/uuid.dart';

/// Loại bảo dưỡng
enum MaintenanceType {
  routine, // Bảo dưỡng định kỳ
  repair,  // Sửa chữa
  parts,   // Thay phụ tùng
}

extension MaintenanceTypeExt on MaintenanceType {
  String get label {
    switch (this) {
      case MaintenanceType.routine:
        return 'Bảo dưỡng định kỳ';
      case MaintenanceType.repair:
        return 'Sửa chữa';
      case MaintenanceType.parts:
        return 'Thay phụ tùng';
    }
  }

  String get code {
    switch (this) {
      case MaintenanceType.routine:
        return 'ROUTINE';
      case MaintenanceType.repair:
        return 'REPAIR';
      case MaintenanceType.parts:
        return 'PARTS';
    }
  }

  static MaintenanceType fromCode(String code) {
    switch (code) {
      case 'REPAIR':
        return MaintenanceType.repair;
      case 'PARTS':
        return MaintenanceType.parts;
      default:
        return MaintenanceType.routine;
    }
  }
}

/// Model đại diện cho một lần bảo dưỡng/sửa chữa
class MaintenanceEntry {
  final String id;
  final String vehicleId;
  final MaintenanceType type;
  final String title;
  final DateTime date;
  final double odometer;
  final double cost;
  final String? garageName;
  final DateTime? nextDueDate;
  final double? nextDueKm;
  final String? note;
  final DateTime createdAt;

  MaintenanceEntry({
    String? id,
    required this.vehicleId,
    required this.type,
    required this.title,
    required this.date,
    required this.odometer,
    required this.cost,
    this.garageName,
    this.nextDueDate,
    this.nextDueKm,
    this.note,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Tạo từ Map (SQLite row)
  factory MaintenanceEntry.fromMap(Map<String, dynamic> map) {
    return MaintenanceEntry(
      id: map['id'] as String,
      vehicleId: map['vehicle_id'] as String,
      type: MaintenanceTypeExt.fromCode(map['type'] as String),
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      odometer: (map['odometer'] as num).toDouble(),
      cost: (map['cost'] as num).toDouble(),
      garageName: map['garage_name'] as String?,
      nextDueDate: map['next_due_date'] != null
          ? DateTime.parse(map['next_due_date'] as String)
          : null,
      nextDueKm: map['next_due_km'] != null
          ? (map['next_due_km'] as num).toDouble()
          : null,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Chuyển thành Map để lưu SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'type': type.code,
      'title': title,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'cost': cost,
      'garage_name': garageName,
      'next_due_date': nextDueDate?.toIso8601String(),
      'next_due_km': nextDueKm,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Chuyển thành Map để lưu Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'type': type.code,
      'title': title,
      'date': date.toIso8601String(),
      'odometer': odometer,
      'cost': cost,
      'garage_name': garageName,
      'next_date': nextDueDate?.toIso8601String(),
      'next_due_km': nextDueKm,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Tạo từ Firestore document
  factory MaintenanceEntry.fromFirestore(Map<String, dynamic> map) {
    return MaintenanceEntry(
      id: map['id'] as String,
      vehicleId: map['vehicle_id'] as String,
      type: MaintenanceTypeExt.fromCode(map['type'] as String),
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      odometer: (map['odometer'] as num).toDouble(),
      cost: (map['cost'] as num).toDouble(),
      garageName: map['garage_name'] as String?,
      nextDueDate: map['next_date'] != null
          ? DateTime.parse(map['next_date'] as String)
          : null,
      nextDueKm: map['next_due_km'] != null
          ? (map['next_due_km'] as num).toDouble()
          : null,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// CopyWith
  MaintenanceEntry copyWith({
    MaintenanceType? type,
    String? title,
    DateTime? date,
    double? odometer,
    double? cost,
    String? garageName,
    DateTime? nextDueDate,
    double? nextDueKm,
    String? note,
  }) {
    return MaintenanceEntry(
      id: id,
      vehicleId: vehicleId,
      type: type ?? this.type,
      title: title ?? this.title,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      cost: cost ?? this.cost,
      garageName: garageName ?? this.garageName,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      nextDueKm: nextDueKm ?? this.nextDueKm,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }

  /// Kiểm tra đã đến hạn bảo dưỡng chưa
  bool get isOverdue {
    if (nextDueDate == null) return false;
    return DateTime.now().isAfter(nextDueDate!);
  }

  /// Kiểm tra sắp đến hạn (trong 7 ngày)
  bool get isDueSoon {
    if (nextDueDate == null) return false;
    final daysLeft = nextDueDate!.difference(DateTime.now()).inDays;
    return daysLeft >= 0 && daysLeft <= 7;
  }

  @override
  bool operator ==(Object other) => other is MaintenanceEntry && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
