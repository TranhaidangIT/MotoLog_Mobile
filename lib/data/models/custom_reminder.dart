enum ReminderType { byKm, byDate, byFuelLevel }

class CustomReminder {
  final String id;
  final String vehicleId;
  final String title;          
  final String subtitle;       
  final ReminderType type;
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
