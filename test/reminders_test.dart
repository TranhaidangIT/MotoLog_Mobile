import 'package:flutter_test/flutter_test.dart';
import 'package:motolog_mobile/core/utils/reminder_calculator.dart';
import 'package:motolog_mobile/data/models/maintenance_entry.dart';

void main() {
  group('Maintenance Reminders Tests', () {
    final now = DateTime.now();

    // NOT-001: Nhắc nhở bảo dưỡng theo mốc KM chuẩn (Sắp đến hạn)
    test('NOT-001: Nhắc nhở thay nhớt (Sắp đến hạn - Còn 100 KM)', () {
      final maintenanceList = <MaintenanceEntry>[
        MaintenanceEntry(
          id: '1',
          vehicleId: 'v1',
          type: MaintenanceType.routine,
          title: 'Thay nhớt máy',
          date: now.subtract(const Duration(days: 30)),
          odometer: 3100,
          cost: 120000,
          nextDueDate: now.add(const Duration(days: 60)),
          nextDueKm: 5100, // Hạn KM tiếp theo
          createdAt: now.subtract(const Duration(days: 30)),
        )
      ];

      final currentOdo = 5000.0;
      final stats = ReminderCalculator.calculateOilReminder(
        maintenanceList: maintenanceList,
        currentOdometer: currentOdo,
      );

      expect(stats.targetKm, equals(5100.0));
      expect(stats.remainingKm, equals(100.0)); // 5100 - 5000
    });

    // NOT-002: Vượt mốc bảo dưỡng (Overdue)
    test('NOT-002: Vượt mốc bảo dưỡng (Quá hạn 400 KM)', () {
      final maintenanceList = <MaintenanceEntry>[
        MaintenanceEntry(
          id: '1',
          vehicleId: 'v1',
          type: MaintenanceType.routine,
          title: 'Thay nhớt máy',
          date: now.subtract(const Duration(days: 45)),
          odometer: 3100,
          cost: 120000,
          nextDueDate: now.add(const Duration(days: 45)),
          nextDueKm: 5100,
          createdAt: now.subtract(const Duration(days: 45)),
        )
      ];

      final currentOdo = 5500.0;
      final stats = ReminderCalculator.calculateOilReminder(
        maintenanceList: maintenanceList,
        currentOdometer: currentOdo,
      );

      expect(stats.targetKm, equals(5100.0));
      expect(stats.remainingKm, equals(-400.0)); // Quá hạn 400 KM
    });

    // NOT-003: Khởi tạo nhắc nhở mới khi hoàn thành bảo dưỡng
    test('NOT-003: Khởi tạo nhắc nhở mới khi lưu bảo dưỡng mới', () {
      // 1. Lịch sử bảo dưỡng cũ
      final oldMaint = MaintenanceEntry(
        id: '1',
        vehicleId: 'v1',
        type: MaintenanceType.routine,
        title: 'Thay nhớt cũ',
        date: now.subtract(const Duration(days: 60)),
        odometer: 3100,
        cost: 0,
        nextDueKm: 5100,
        createdAt: now.subtract(const Duration(days: 60)),
      );

      // 2. Thêm bảo dưỡng mới (Thay nhớt tại 5500, set hạn mới là 7500)
      final newMaint = MaintenanceEntry(
        id: '2',
        vehicleId: 'v1',
        type: MaintenanceType.routine,
        title: 'Thay nhớt máy mới',
        date: now,
        odometer: 5500,
        cost: 150000,
        nextDueKm: 7500, // Hạn mới
        createdAt: now,
      );

      // Danh sách lịch sử cập nhật (mới nhất xếp trước)
      final list = <MaintenanceEntry>[newMaint, oldMaint];
      
      final currentOdo = 5500.0;
      final stats = ReminderCalculator.calculateOilReminder(
        maintenanceList: list,
        currentOdometer: currentOdo,
      );

      expect(stats.targetKm, equals(7500.0));
      expect(stats.remainingKm, equals(2000.0)); // 7500 - 5500 (an toàn trở lại)
    });

    // NOT-004: Nhắc nhở theo Thời gian (Tháng)
    test('NOT-004: Nhắc nhở theo thời gian quá hạn (6 tháng)', () {
      final lastMaintenanceDate = DateTime(2026, 1, 1);
      final currentTestingDate = DateTime(2026, 7, 1); // 6 tháng sau
      
      bool isTimeDue(DateTime lastDate, DateTime currentDate, int limitMonths) {
        final diffDays = currentDate.difference(lastDate).inDays;
        // Khoảng 6 tháng = 180 ngày
        return diffDays >= (limitMonths * 30);
      }
      
      expect(isTimeDue(lastMaintenanceDate, currentTestingDate, 6), isTrue);
      expect(isTimeDue(lastMaintenanceDate, lastMaintenanceDate.add(const Duration(days: 30)), 6), isFalse);
    });
  });
}
