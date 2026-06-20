class MaintenanceUtils {
  static const Map<String, String> itemIcons = {
    'Thay nhớt máy': 'img/phu-tung/thay_nhot_may.png',
    'Vệ sinh nồi (CVT)': 'img/phu-tung/ve_sinh_noi_cvt.png',
    'Thay bugi': 'img/phu-tung/thay_bugi.png',
    'Thay lọc gió': 'img/phu-tung/thay_loc_gio.png',
    'Thay nước làm mát': 'img/phu-tung/thay_nuoc_lam_mat.png',
    'Thay ắc quy': 'img/phu-tung/thay_ac_quy.png',
    'Thay dầu hộp số': 'img/phu-tung/thay_dau_hop_so.png',
    'Thay lốp': 'img/phu-tung/thay_lop.png',
    'Thay má phanh': 'img/phu-tung/thay_ma_phanh.png',
    'Thay xích tải': 'img/phu-tung/thay_xich_tai.png',
  };

  static String getIcon(String title) {
    return itemIcons[title] ?? 'img/phu-tung/thay_nhot_may.png';
  }

  static List<String> get allItems => itemIcons.keys.toList();
}
