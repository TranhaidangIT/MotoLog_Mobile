class StatsCalculator {
  StatsCalculator._();

  /// Tính tổng chi phí cho các tháng được chọn
  static double calculateTotal(List<Map<String, dynamic>> data, List<String> months) {
    final map = {
      for (final d in data)
        d['month'] as String: (d['cost'] as num).toDouble()
    };
    double sum = 0;
    for (final m in months) {
      sum += map[m] ?? 0;
    }
    return sum;
  }

  /// Phát sinh danh sách chuỗi tháng dạng 'yyyy-MM'
  static List<String> generateMonths(DateTime baseDate, int count, {int offset = 0}) {
    final months = <String>[];
    for (int i = count - 1; i >= 0; i--) {
      final d = DateTime(baseDate.year, baseDate.month - i - offset, 1);
      months.add('${d.year}-${d.month.toString().padLeft(2, '0')}');
    }
    return months;
  }
}
