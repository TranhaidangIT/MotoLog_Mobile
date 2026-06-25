import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:motolog_mobile/core/constants/vehicle_catalog_data.dart';

/// Model lưu trữ thông tin ảnh đại diện mặc định của một dòng xe từ CSDL (Firebase)
class VehicleImageEntry {
  /// Hãng xe (VD: Honda)
  final String brand;
  /// Dòng xe (VD: Air Blade)
  final String model;
  /// Phân loại (VD: xe_so, tay_ga, xe_con)
  final String type; 
  /// Năm sản xuất bắt đầu áp dụng mẫu thiết kế này
  final int yearFrom;
  /// Năm sản xuất kết thúc
  final int yearTo;
  /// Đường dẫn URL ảnh (Firebase Storage hoặc Public URL)
  final String imageUrl;

  VehicleImageEntry({
    required this.brand,
    required this.model,
    required this.type,
    required this.yearFrom,
    required this.yearTo,
    required this.imageUrl,
  });

  factory VehicleImageEntry.fromMap(Map<String, dynamic> map) => VehicleImageEntry(
    brand: map['brand'] ?? '',
    model: map['model'] ?? '',
    type: map['type'] ?? 'xe_so',
    yearFrom: map['yearFrom'] ?? 0,
    yearTo: map['yearTo'] ?? 9999,
    imageUrl: map['imageUrl'] ?? '',
  );
}

/// Dịch vụ tra cứu hình ảnh xe dựa trên Hãng, Dòng xe và Năm sản xuất
class VehicleImageService {
  static final VehicleImageService instance = VehicleImageService._();
  VehicleImageService._();

  final _db = FirebaseFirestore.instance;

  List<VehicleImageEntry>? _catalogCache;
  Map<String, String>? _fallbackCache;

  String _normalize(String s) => s.toLowerCase().trim();

  Future<List<VehicleImageEntry>> _loadCatalog() async {
    if (_catalogCache != null) return _catalogCache!;
    try {
      final snap = await _db.collection('vehicle_catalog').get();
      _catalogCache = snap.docs.map((d) => VehicleImageEntry.fromMap(d.data())).toList();
      return _catalogCache!;
    } catch (e) {
      debugPrint('Lỗi tải Catalog: $e');
      return [];
    }
  }

  Future<Map<String, String>> _loadFallback() async {
    if (_fallbackCache != null) return _fallbackCache!;
    try {
      final snap = await _db.collection('vehicle_fallback').get();
      _fallbackCache = {
        for (final d in snap.docs) (d.data()['type'] as String): (d.data()['imageUrl'] as String)
      };
      return _fallbackCache!;
    } catch (e) {
      debugPrint('Lỗi tải Fallback: $e');
      return {};
    }
  }

  /// Trả về URL ảnh phù hợp nhất cho 1 chiếc xe, theo thứ tự ưu tiên 4 tầng.
  Future<String> resolveImageUrl({
    required String brand,
    required String model,
    required String type, // 'xe_so' | 'tay_ga'
    required int year,
  }) async {
    final b = _normalize(brand);
    final m = _normalize(model);

    // Tầng 0: Quét Offline Data (Local Catalog)
    for (final e in localVehicleCatalog) {
      if (_normalize(e['brand']) == b && _normalize(e['model']) == m) {
        return e['image']; // Lấy thẳng ảnh local trong máy (ví dụ: img/honda/...)
      }
    }

    final catalog = await _loadCatalog();

    // Tầng 1: khớp chính xác brand + model + năm trong khoảng
    for (final e in catalog) {
      if (_normalize(e.brand) == b && _normalize(e.model) == m && year >= e.yearFrom && year <= e.yearTo) {
        return e.imageUrl;
      }
    }

    // Tầng 2: khớp brand + model, bỏ qua năm
    for (final e in catalog) {
      if (_normalize(e.brand) == b && _normalize(e.model) == m) {
        return e.imageUrl;
      }
    }

    // Tầng 3: khớp brand + type (loại xe)
    for (final e in catalog) {
      if (_normalize(e.brand) == b && e.type == type) {
        return e.imageUrl;
      }
    }

    // Tầng 4: fallback generic theo loại xe
    final fallback = await _loadFallback();
    return fallback[type] ?? fallback['xe_so'] ?? '';
  }
}
