class AppConstants {
  AppConstants._();

  static String appName = 'MotoLog';
  static String appTagline = 'Nhật ký xe cá nhân';
  static String appVersion = '1.0.0';

  // Database
  static String dbName = 'motolog.db';
  static const int dbVersion = 12;

  // Tables
  static String tableVehicles = 'vehicles';
  static String tableFuelEntries = 'fuel_entries';
  static String tableMaintenanceEntries = 'maintenance_entries';
  static String tableMaintenanceItems = 'maintenance_items';
  static String tableCustomReminders = 'custom_reminders';

  // Shared Preferences Keys
  static String keyThemeMode = 'theme_mode';
  static String keySelectedVehicleId = 'selected_vehicle_id';
  static String keyOnboardingDone = 'onboarding_done';
  static String keyUserId = 'user_id';

  // Fuel Types
  static String fuelGasoline = 'Xăng';
  static String fuelElectric = 'Điện';
  static String fuelDiesel = 'Diesel';
  static List<String> fuelTypes = [
    fuelGasoline,
    fuelElectric,
    fuelDiesel
  ];

  // Maintenance Types
  static String maintenanceRoutine = 'ROUTINE';
  static String maintenanceRepair = 'REPAIR';
  static String maintenanceParts = 'PARTS';

  static Map<String, String> maintenanceTypeLabels = {
    maintenanceRoutine: 'Bảo dưỡng định kỳ',
    maintenanceRepair: 'Sửa chữa',
    maintenanceParts: 'Thay phụ tùng',
  };

  // Animation durations
  static Duration animFast = const Duration(milliseconds: 200);
  static Duration animNormal = const Duration(milliseconds: 350);
  static Duration animSlow = const Duration(milliseconds: 500);

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
