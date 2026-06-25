import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider cung cấp đối tượng SharedPreferences toàn cục cho ứng dụng
/// Dùng để truy xuất dữ liệu nhẹ gọn như Cài đặt (Settings), Giao diện (Theme).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  // Provider này bắt buộc phải được override giá trị ở ProviderScope bên trong file main.dart
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});
