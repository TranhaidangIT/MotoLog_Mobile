import 'package:flutter_test/flutter_test.dart';
import 'package:motolog_mobile/core/utils/stats_calculator.dart';
import 'package:motolog_mobile/core/utils/formatters.dart';

void main() {
  group('Business Logic Tests (Statistics & Calculations)', () {
    
    // LOG-001: Tính toán tổng chi phí theo Quý (3 Tháng)
    test('LOG-001: Tính tổng chi phí theo Quý và trung bình tháng', () {
      final now = DateTime(2026, 6, 30); // Giả sử hôm nay là cuối tháng 6/2026
      
      // Các tháng trong quý 2 (tháng 4, 5, 6)
      final chartMonths = StatsCalculator.generateMonths(now, 3);
      expect(chartMonths, equals(['2026-04', '2026-05', '2026-06']));
      
      // Dữ liệu giả lập
      final fuelData = [
        {'month': '2026-04', 'cost': 100000.0},
        {'month': '2026-05', 'cost': 200000.0},
        {'month': '2026-06', 'cost': 300000.0},
      ];
      
      // 1. Tính tổng chi phí
      final totalCost = StatsCalculator.calculateTotal(fuelData, chartMonths);
      expect(totalCost, equals(600000.0));
      
      // 2. Tính trung bình tháng
      final monthlyAverage = totalCost / 3;
      expect(monthlyAverage, equals(200000.0));
    });

    // LOG-002: Tính tỷ lệ tăng trưởng phần trăm (%) - Tăng chi phí
    test('LOG-002: Tính phần trăm tăng trưởng (+20%)', () {
      final currentMonthCost = 600000.0;
      final previousMonthCost = 500000.0;
      
      final growth = AppFormatters.calcGrowthPercentage(currentMonthCost, previousMonthCost);
      expect(growth, equals(20.0));
    });

    // LOG-003: Tính tỷ lệ giảm chi tiêu (%) - Tiết kiệm
    test('LOG-003: Tính phần trăm giảm chi tiêu (-50%)', () {
      final currentMonthCost = 500000.0;
      final previousMonthCost = 1000000.0;
      
      final savings = AppFormatters.calcGrowthPercentage(currentMonthCost, previousMonthCost);
      expect(savings, equals(-50.0));
    });

    // LOG-004: Kiểm tra logic ngày tương lai
    test('LOG-004: Logic chặn ngày tương lai', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final yesterday = now.subtract(const Duration(days: 1));
      
      // Hàm kiểm tra ngày tương lai
      bool isFutureDate(DateTime date) {
        // Chỉ so sánh năm, tháng, ngày để tránh lệch giây/giờ
        final today = DateTime(now.year, now.month, now.day);
        final checkDate = DateTime(date.year, date.month, date.day);
        return checkDate.isAfter(today);
      }
      
      expect(isFutureDate(tomorrow), isTrue);
      expect(isFutureDate(now), isFalse);
      expect(isFutureDate(yesterday), isFalse);
    });
  });
}
