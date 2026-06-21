class AppConstants {
  AppConstants._();

  static const String appName = 'MotoLog';
  static const String appTagline = 'Nhật ký xe cá nhân';
  static const String appVersion = '1.0.0';

  // Database
  static const String dbName = 'motolog.db';
  static const int dbVersion = 7;

  // Tables
  static const String tableVehicles = 'vehicles';
  static const String tableFuelEntries = 'fuel_entries';
  static const String tableMaintenanceEntries = 'maintenance_entries';
  static const String tableMaintenanceItems = 'maintenance_items';
  static const String tableCustomReminders = 'custom_reminders';

  // Shared Preferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keySelectedVehicleId = 'selected_vehicle_id';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyUserId = 'user_id';

  // Fuel Types
  static const String fuelGasoline = 'Xăng';
  static const String fuelElectric = 'Điện';
  static const String fuelDiesel = 'Diesel';
  static const List<String> fuelTypes = [
    fuelGasoline,
    fuelElectric,
    fuelDiesel
  ];

  // Maintenance Types
  static const String maintenanceRoutine = 'ROUTINE';
  static const String maintenanceRepair = 'REPAIR';
  static const String maintenanceParts = 'PARTS';

  static const Map<String, String> maintenanceTypeLabels = {
    maintenanceRoutine: 'Bảo dưỡng định kỳ',
    maintenanceRepair: 'Sửa chữa',
    maintenanceParts: 'Thay phụ tùng',
  };

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);

  // Border radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 100.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXL = 48.0;
}
