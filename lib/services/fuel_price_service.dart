class FuelPriceService {
  static const Map<String, int> _defaultPrices = {
    'RON 95-III': 22320,
    'E5 RON 92-II': 21310,
    'Dầu diesel': 18950,
  };

  // Có thể mở rộng để Fetch dữ liệu động từ Firebase Remote Config hoặc API Petrolimex sau này.
  Future<Map<String, int>> getCurrentPrices() async {
    // Giả lập delay mạng
    await Future.delayed(const Duration(milliseconds: 300));
    return _defaultPrices;
  }
}
