class FuelPriceService {
  static const Map<String, int> _mockPrices = {
    'RON 95-IV': 21310,
    'RON 95-III': 20800,
    'E5 RON 92': 20050,
    'Dầu diesel': 18950,
  };

  // TODO: Fetch từ Firebase Remote Config hoặc crawler Petrolimex
  Future<Map<String, int>> getCurrentPrices() async {
    // Giả lập delay mạng
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPrices;
  }
}
