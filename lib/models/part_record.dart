class PartRecord {
  final String name;
  final DateTime date;
  final int odo;
  final int cost;
  final String? beforePhotoPath;
  final String? afterPhotoPath;
  final String? note;

  PartRecord({
    required this.name,
    required this.date,
    required this.odo,
    required this.cost,
    this.beforePhotoPath,
    this.afterPhotoPath,
    this.note,
  });

  String get dateText => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  String get costText => '${cost.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ';
}
