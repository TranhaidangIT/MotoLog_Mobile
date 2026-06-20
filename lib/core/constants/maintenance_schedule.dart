

class ScheduleItem {
  final String id;
  final String title;
  final String imageAsset;
  final double defaultDueKm; // Số km định kỳ khuyến nghị (dùng mốc max)
  final String frequencyLabel; // Nhãn hiển thị định kỳ
  final List<String> keywords;

  const ScheduleItem({
    required this.id,
    required this.title,
    required this.imageAsset,
    required this.defaultDueKm,
    required this.frequencyLabel,
    required this.keywords,
  });
}

class MaintenanceSchedule {
  MaintenanceSchedule._();

  static const List<ScheduleItem> items = [
    ScheduleItem(
      id: 'thay_nhot_may',
      title: 'Thay nhớt máy',
      imageAsset: 'img/phu-tung/thay_nhot_may.png',
      defaultDueKm: 2000,
      frequencyLabel: 'Định kỳ sau mỗi 1.500 - 2.000 km',
      keywords: ['nhớt', 'dầu máy', 'nhớt máy', 'oil'],
    ),
    ScheduleItem(
      id: 've_sinh_noi_cvt',
      title: 'Vệ sinh nồi (CVT)',
      imageAsset: 'img/phu-tung/ve_sinh_noi_cvt.png',
      defaultDueKm: 10000,
      frequencyLabel: 'Định kỳ sau mỗi 8.000 - 10.000 km',
      keywords: ['nồi', 'côn', 'cvt', 'clutch'],
    ),
    ScheduleItem(
      id: 'thay_bugi',
      title: 'Thay bugi',
      imageAsset: 'img/phu-tung/thay_bugi.png',
      defaultDueKm: 10000,
      frequencyLabel: 'Định kỳ sau mỗi 8.000 - 10.000 km',
      keywords: ['bugi', 'spark plug'],
    ),
    ScheduleItem(
      id: 'thay_loc_gio',
      title: 'Thay lọc gió',
      imageAsset: 'img/phu-tung/thay_loc_gio.png',
      defaultDueKm: 12000,
      frequencyLabel: 'Định kỳ sau mỗi 10.000 - 12.000 km',
      keywords: ['lọc gió', 'air filter'],
    ),
    ScheduleItem(
      id: 'thay_dau_hop_so',
      title: 'Thay dầu hộp số',
      imageAsset: 'img/phu-tung/thay_dau_hop_so.png',
      defaultDueKm: 15000,
      frequencyLabel: 'Định kỳ sau mỗi 10.000 - 15.000 km',
      keywords: ['dầu láp', 'nhớt láp', 'dầu hộp số', 'gear oil'],
    ),
    ScheduleItem(
      id: 'thay_nuoc_lam_mat',
      title: 'Thay nước làm mát',
      imageAsset: 'img/phu-tung/thay_nuoc_lam_mat.png',
      defaultDueKm: 15000,
      frequencyLabel: 'Định kỳ sau mỗi 12.000 - 15.000 km',
      keywords: ['nước mát', 'làm mát', 'coolant'],
    ),
    ScheduleItem(
      id: 'thay_ma_phanh',
      title: 'Thay má phanh',
      imageAsset: 'img/phu-tung/thay_ma_phanh.png',
      defaultDueKm: 20000,
      frequencyLabel: 'Định kỳ sau mỗi 15.000 - 20.000 km',
      keywords: ['má phanh', 'bố thắng', 'brake pad'],
    ),
    ScheduleItem(
      id: 'thay_xich_tai',
      title: 'Thay xích tải',
      imageAsset: 'img/phu-tung/thay_xich_tai.png',
      defaultDueKm: 20000,
      frequencyLabel: 'Định kỳ sau mỗi 15.000 - 20.000 km',
      keywords: ['nhông sên đĩa', 'nsd', 'xích', 'chain'],
    ),
    ScheduleItem(
      id: 'thay_lop',
      title: 'Thay lốp xe',
      imageAsset: 'img/phu-tung/thay_lop.png',
      defaultDueKm: 30000,
      frequencyLabel: 'Định kỳ sau mỗi 20.000 - 30.000 km',
      keywords: ['lốp', 'vỏ xe', 'tire'],
    ),
    ScheduleItem(
      id: 'thay_ac_quy',
      title: 'Thay ắc quy',
      imageAsset: 'img/phu-tung/thay_ac_quy.png',
      defaultDueKm: 36000,
      frequencyLabel: 'Định kỳ sau mỗi 24.000 - 36.000 km',
      keywords: ['ắc quy', 'bình điện', 'battery'],
    ),
  ];
}
