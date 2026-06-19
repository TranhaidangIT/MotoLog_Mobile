import '../../data/models/maintenance_entry.dart';

class ReminderCalculator {
  ReminderCalculator._();

  /// Tính toán số KM còn lại và mốc KM đích tiếp theo cho thay nhớt
  static ({double remainingKm, double targetKm}) calculateOilReminder({
    required List<MaintenanceEntry> maintenanceList,
    required double currentOdometer,
  }) {
    final oilMaint = maintenanceList
        .where((e) =>
            e.title.toLowerCase().contains('nhớt') ||
            e.title.toLowerCase().contains('oil'))
        .firstOrNull;

    if (oilMaint != null && oilMaint.nextDueKm != null) {
      final diff = oilMaint.nextDueKm! - currentOdometer;
      return (
        remainingKm: diff,
        targetKm: oilMaint.nextDueKm!,
      );
    } else {
      final nextMilestone = (((currentOdometer / 2000).floor() + 1) * 2000).toDouble();
      return (
        remainingKm: nextMilestone - currentOdometer,
        targetKm: nextMilestone,
      );
    }
  }

  /// Tính toán số KM còn lại và mốc KM đích tiếp theo cho vệ sinh nồi
  static ({double remainingKm, double targetKm}) calculateClutchReminder({
    required List<MaintenanceEntry> maintenanceList,
    required double currentOdometer,
  }) {
    final clutchMaint = maintenanceList
        .where((e) =>
            e.title.toLowerCase().contains('nồi') ||
            e.title.toLowerCase().contains('clutch'))
        .firstOrNull;

    if (clutchMaint != null && clutchMaint.nextDueKm != null) {
      final diff = clutchMaint.nextDueKm! - currentOdometer;
      return (
        remainingKm: diff,
        targetKm: clutchMaint.nextDueKm!,
      );
    } else {
      final nextMilestone = (((currentOdometer / 5000).floor() + 1) * 5000).toDouble();
      return (
        remainingKm: nextMilestone - currentOdometer,
        targetKm: nextMilestone,
      );
    }
  }
}
