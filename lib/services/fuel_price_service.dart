/// Dịch vụ cung cấp thông tin giá xăng dầu hiện tại
class FuelPriceService {
  /// Danh sách giá xăng dầu mặc định (đơn vị: VNĐ)
  static const Map<String, int> _defaultPrices = {
    'RON 95-III': 22320,
    'E5 RON 92-II': 21310,
    'Dầu diesel': 18950,
  };

  /// Lấy giá xăng dầu hiện tại
  /// Lưu ý: Có thể mở rộng để lấy dữ liệu động từ Firebase Remote Config hoặc API Petrolimex sau này.
  Future<Map<String, int>> getCurrentPrices() async {
    // Giả lập độ trễ mạng để UI hiển thị loading mượt mà
    await Future.delayed(const Duration(milliseconds: 300));
    return _defaultPrices;
  }
}
