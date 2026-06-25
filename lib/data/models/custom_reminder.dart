/// Các loại nhắc nhở tuỳ chỉnh hỗ trợ trong ứng dụng
enum ReminderType { byKm, byDate, byFuelLevel }

/// Model đại diện cho một Lịch nhắc nhở (đến hạn bảo dưỡng, đóng phí, v.v.)
class CustomReminder {
  /// Mã định danh duy nhất của nhắc nhở (UUID)
  final String id;
  /// Mã ID của xe được gắn nhắc nhở này
  final String vehicleId;
  /// Tiêu đề nhắc nhở (VD: Hết hạn bảo hiểm)
  final String title;          
  /// Chi tiết nhắc nhở (VD: Ngày 15/10/2026)
  final String subtitle;       
  /// Phân loại nhắc nhở (theo ODO, theo Ngày, theo Mức xăng)
  final ReminderType type;
  /// Cờ hiệu bật/tắt nhắc nhở
  final bool isOn;

  CustomReminder({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.subtitle,
    required this.type,
    this.isOn = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'vehicle_id': vehicleId,
        'title': title,
        'subtitle': subtitle,
        'type': type.name,
        'is_on': isOn ? 1 : 0,
      };

  factory CustomReminder.fromMap(Map<String, dynamic> map) => CustomReminder(
        id: map['id'] as String,
        vehicleId: map['vehicle_id'] as String,
        title: map['title'] as String,
        subtitle: map['subtitle'] as String,
        type: ReminderType.values.firstWhere((e) => e.name == map['type']),
        isOn: (map['is_on'] as int) == 1,
      );
}
