import 'dart:io';

const packageName = 'motolog_mobile';

// Short filename-only imports that need full paths
const shortNames = {
  'export_data_screen.dart': 'features/export/screens/export_data_screen.dart',
  'maintenance_setup_screen.dart': 'features/maintenance/screens/maintenance_setup_screen.dart',
  'document_edit_screen.dart': 'features/documents/screens/document_edit_screen.dart',
};

// More path fixes
const pathFixes = {
  // custom_reminder_dao
  "shared/database/custom_reminder_dao": "data/local/custom_reminder_dao",
  
  // statistics models
  "features/statistics/data/models/maintenance_entry": "data/models/maintenance_entry",
  "features/statistics/models/maintenance_entry": "data/models/maintenance_entry",
  "features/statistics/data/models/fuel_entry": "data/models/fuel_entry",
  
  // vehicle core constants
  "features/vehicle/core/constants/vehicle_catalog_data": "core/constants/vehicle_catalog_data",
  "features/vehicle/core/constants/app_constants": "core/constants/app_constants",
  "features/vehicle/core/constants/maintenance_schedule": "core/constants/maintenance_schedule",
  "features/fuel/core/constants": "core/constants",
  "features/maintenance/core/constants": "core/constants",
  "features/reminder/core/constants": "core/constants",
  "features/statistics/core/constants": "core/constants",
  "features/export/core/constants": "core/constants",
  
  // maintenance_setup_screen across features
  "features/vehicle/maintenance_setup_screen": "features/maintenance/screens/maintenance_setup_screen",
  "features/profile/maintenance_setup_screen": "features/maintenance/screens/maintenance_setup_screen",
  
  // core utils 
  "features/vehicle/core/utils": "core/utils",
  "features/fuel/core/utils": "core/utils",
  "features/maintenance/core/utils": "core/utils",
  
  // core router
  "features/vehicle/core/router": "core/router",
  
  // data models shortcuts
  "features/maintenance/data/models/maintenance_entry": "data/models/maintenance_entry",
  "features/vehicle/data/models/vehicle": "data/models/vehicle",
};

void main() {
  var totalFixed = 0;
  final libDir = Directory('lib');
  
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    var content = entity.readAsStringSync();
    final original = content;

    // Fix short filename-only imports
    for (final entry in shortNames.entries) {
      final pattern = RegExp("import '${RegExp.escape(entry.key)}';");
      content = content.replaceAll(
        pattern, "import 'package:$packageName/${entry.value}';");
    }
    
    // Fix path corrections
    for (final entry in pathFixes.entries) {
      content = content.replaceAll(
        'package:$packageName/${entry.key}',
        'package:$packageName/${entry.value}'
      );
    }
    
    if (content != original) {
      entity.writeAsStringSync(content);
      totalFixed++;
      print('Fixed: ${entity.path}');
    }
  }
  
  print('\nFixed $totalFixed files.');
}
