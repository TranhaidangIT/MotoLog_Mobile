import 'dart:io';

const packageName = 'motolog_mobile';

// Fix all wrong "features/XXX" prefixes on paths that should be something else
// Pattern: package:motolog/features/<FEATURE>/<CORRECT_PATH> -> package:motolog/<CORRECT_PATH>
// where CORRECT_PATH doesn't belong in features/

const corrections = {
  // DAO paths
  'features/export/local/dao/vehicle_dao': 'shared/database/dao/vehicle_dao',
  'features/export/local/dao/fuel_dao': 'shared/database/dao/fuel_dao',
  'features/export/local/dao/maintenance_dao': 'shared/database/dao/maintenance_dao',
  'features/export/local/dao/custom_reminder_dao': 'shared/database/dao/custom_reminder_dao',
  'features/fuel/local/dao/fuel_dao': 'shared/database/dao/fuel_dao',
  'features/fuel/local/dao/vehicle_dao': 'shared/database/dao/vehicle_dao',
  'features/maintenance/local/dao/maintenance_dao': 'shared/database/dao/maintenance_dao',
  'features/vehicle/local/dao/vehicle_dao': 'shared/database/dao/vehicle_dao',
  
  // Theme paths
  'features/export/theme/app_theme': 'theme/app_theme',
  'features/fuel/theme/app_theme': 'theme/app_theme',
  'features/maintenance/theme/app_theme': 'theme/app_theme',
  'features/vehicle/theme/app_theme': 'theme/app_theme',
  'features/reminder/theme/app_theme': 'theme/app_theme',
  'features/profile/theme/app_theme': 'theme/app_theme',
  'features/statistics/theme/app_theme': 'theme/app_theme',
  'features/home/theme/app_theme': 'theme/app_theme',
  'features/garage/theme/app_theme': 'theme/app_theme',

  // Models paths
  'features/fuel/data/models/fuel_entry': 'data/models/fuel_entry',
  'features/fuel/models/fuel_entry': 'data/models/fuel_entry',
  'features/maintenance/data/models/maintenance_entry': 'data/models/maintenance_entry',
  'features/maintenance/models/maintenance_entry': 'data/models/maintenance_entry',
  'features/vehicle/data/models/vehicle': 'data/models/vehicle',
  'features/vehicle/models/vehicle': 'data/models/vehicle',
  'features/reminder/data/models/custom_reminder': 'data/models/custom_reminder',
  'features/reminder/models/custom_reminder': 'data/models/custom_reminder',
  'features/export/data/models': 'data/models',
  'features/export/models': 'data/models',
  
  // Provider paths that may be wrong
  'features/fuel/vehicle/providers/vehicle_provider': 'features/vehicle/providers/vehicle_provider',
  'features/maintenance/vehicle/providers/vehicle_provider': 'features/vehicle/providers/vehicle_provider',
  'features/statistics/vehicle/providers/vehicle_provider': 'features/vehicle/providers/vehicle_provider',
  'features/statistics/fuel/providers/fuel_provider': 'features/fuel/providers/fuel_provider',
  'features/statistics/maintenance/providers/maintenance_provider': 'features/maintenance/providers/maintenance_provider',
  
  // Services paths
  'features/vehicle/data/services/storage_service': 'features/vehicle/data/firebase/storage_service',
  'features/fuel/services/location_service': 'shared/location/location_service',
  'features/fuel/services/notification_service': 'shared/notifications/notification_service',
  'features/reminder/services/notification_service': 'shared/notifications/notification_service',
  
  // Firestore service
  'features/vehicle/data/services/firestore_service': 'shared/firebase/firestore_service',
  'features/fuel/data/services/firestore_service': 'shared/firebase/firestore_service',
  'features/maintenance/data/services/firestore_service': 'shared/firebase/firestore_service',
  'features/export/data/services/data_export_service': 'features/export/data/data_export_service',
  
  // backup service
  'features/vehicle/data/services/backup_delete_service': 'shared/firebase/backup_delete_service',
  
  // shared_preferences_provider
  'features/auth/providers/shared_preferences_provider': 'providers/shared_preferences_provider',
  'features/vehicle/providers/shared_preferences_provider': 'providers/shared_preferences_provider',
};

void main() {
  var count = 0;
  var updated = 0;

  final libDir = Directory('lib');
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    count++;
    var content = entity.readAsStringSync();
    final original = content;

    for (final entry in corrections.entries) {
      final wrong = 'package:$packageName/${entry.key}';
      final correct = 'package:$packageName/${entry.value}';
      content = content.replaceAll(wrong, correct);
    }

    if (content != original) {
      entity.writeAsStringSync(content);
      updated++;
      print('Fixed: ${entity.path}');
    }
  }

  print('\nScanned $count files, fixed $updated files.');
}
