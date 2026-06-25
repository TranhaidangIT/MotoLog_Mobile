import 'package:flutter/material.dart';

/// Model đại diện cho một Hạng mục Bảo dưỡng (Nhớt máy, Nhớt láp, Nước mát, v.v.)
class MaintenanceItem {
  /// Mã định danh duy nhất của hạng mục bảo dưỡng
  final String id;
  /// Mã ID của xe đang sở hữu hạng mục này
  final String vehicleId;
  /// Tên hạng mục (VD: Nhớt máy, Nhớt láp)
  final String name;            
  /// Mã icon hiển thị trên UI
  final String iconCode; 
  /// Chu kỳ bảo dưỡng tính theo Số Km (VD: 2000 km)
  final int intervalKm;         
  /// Số ODO tại thời điểm thực hiện bảo dưỡng lần cuối cùng
  final int lastDoneOdo;        
  /// Cờ bật/tắt tính năng gửi thông báo nhắc nhở
  final bool isReminderOn;      

  MaintenanceItem({
    required this.id,
    required this.vehicleId,
    required this.name,
    required this.iconCode,
    required this.intervalKm,
    required this.lastDoneOdo,
    this.isReminderOn = true,
  });
  
  Map<String, dynamic> toMap() => {
        'id': id,
        'vehicle_id': vehicleId,
        'name': name,
        'icon_code': iconCode,
        'interval_km': intervalKm,
        'last_done_odo': lastDoneOdo,
        'is_reminder_on': isReminderOn ? 1 : 0,
      };

  factory MaintenanceItem.fromMap(Map<String, dynamic> map) => MaintenanceItem(
        id: map['id'] as String,
        vehicleId: map['vehicle_id'] as String,
        name: map['name'] as String,
        iconCode: map['icon_code'] as String,
        intervalKm: map['interval_km'] as int,
        lastDoneOdo: map['last_done_odo'] as int,
        isReminderOn: (map['is_reminder_on'] as int) == 1,
      );

  IconData get icon {
    switch(iconCode) {
      case 'opacity': return Icons.opacity;
      case 'settings': return Icons.settings;
      case 'electrical_services': return Icons.electrical_services;
      case 'air': return Icons.air;
      case 'water_drop': return Icons.water_drop;
      case 'battery_full': return Icons.battery_full;
      default: return Icons.build;
    }
  }

  int kmUntilDue(int currentOdo) {
    final used = currentOdo - lastDoneOdo;
    return intervalKm - used; 
  }

  bool isOverdue(int currentOdo) => kmUntilDue(currentOdo) < 0;

  int remainingKm(int currentOdo) {
    final v = kmUntilDue(currentOdo);
    return v < 0 ? 0 : v;
  }

  int overdueKm(int currentOdo) {
    final v = kmUntilDue(currentOdo);
    return v < 0 ? -v : 0;
  }

  double progress(int currentOdo) {
    final used = currentOdo - lastDoneOdo;
    final p = used / intervalKm;
    return p.clamp(0.0, 1.0);
  }

  String urgency(int currentOdo) {
    if (isOverdue(currentOdo)) return 'overdue';
    final p = progress(currentOdo);
    if (p >= 0.85) return 'soon';
    return 'normal';
  }

  MaintenanceItem copyWith({int? lastDoneOdo, bool? isReminderOn}) {
    return MaintenanceItem(
      id: id, vehicleId: vehicleId, name: name, iconCode: iconCode, intervalKm: intervalKm,
      lastDoneOdo: lastDoneOdo ?? this.lastDoneOdo,
      isReminderOn: isReminderOn ?? this.isReminderOn,
    );
  }
}
