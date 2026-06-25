import 'dart:io';

const packageName = 'motolog_mobile';

// These are single-filename imports (no path) that need full package paths
const shortImportFixes = {
  "'vehicle_provider.dart'": "'package:$packageName/features/vehicle/providers/vehicle_provider.dart'",
  "'fuel_provider.dart'": "'package:$packageName/features/fuel/providers/fuel_provider.dart'",
  "'maintenance_provider.dart'": "'package:$packageName/features/maintenance/providers/maintenance_provider.dart'",
  "'auth_provider.dart'": "'package:$packageName/features/auth/providers/auth_provider.dart'",
  "'database_helper.dart'": "'package:$packageName/shared/database/database_helper.dart'",
};

// More path corrections for remaining issues
const pathCorrections = {
  // widgets
  "features/fuel/widgets/bottom_nav_bar": "widgets/bottom_nav_bar",
  "features/maintenance/widgets/bottom_nav_bar": "widgets/bottom_nav_bar",
  "features/vehicle/widgets/bottom_nav_bar": "widgets/bottom_nav_bar",
  "features/reminder/widgets/bottom_nav_bar": "widgets/bottom_nav_bar",
  "features/statistics/widgets/bottom_nav_bar": "widgets/bottom_nav_bar",
  "features/export/widgets/bottom_nav_bar": "widgets/bottom_nav_bar",
  "features/profile/widgets/bottom_nav_bar": "widgets/bottom_nav_bar",
  "features/home/widgets/bottom_nav_bar": "widgets/bottom_nav_bar",
  
  // maintenance item model 
  "features/maintenance/data/models/maintenance_item": "data/models/maintenance_item",
  "features/maintenance/models/maintenance_item": "data/models/maintenance_item",
  
  // maintenance_item_dao
  "shared/database/maintenance_item_dao": "data/local/maintenance_item_dao",
  
  // reminder model
  "features/reminder/data/models/custom_reminder": "data/models/custom_reminder",
  "features/reminder/models/custom_reminder": "data/models/custom_reminder",
  
  // statistics providers
  "features/statistics/features/vehicle/providers/vehicle_provider": "features/vehicle/providers/vehicle_provider",
  "features/statistics/features/fuel/providers/fuel_provider": "features/fuel/providers/fuel_provider",
  "features/statistics/features/maintenance/providers/maintenance_provider": "features/maintenance/providers/maintenance_provider",
  
  // app_router
  "features/core/router": "core/router",
  "features/core/constants": "core/constants",
  "features/core/theme": "core/theme",
  "features/core/utils": "core/utils",
  
  // double features prefix cleanup
  "features/features/": "features/",
  
  // providers without features prefix
  "features/auth/providers/shared_preferences_provider": "providers/shared_preferences_provider",
  "features/vehicle/providers/settings_provider": "providers/settings_provider",
  "features/profile/providers/settings_provider": "providers/settings_provider",
  "features/fuel/providers/settings_provider": "providers/settings_provider",
  "features/profile/providers/theme_provider": "providers/theme_provider",
  "features/profile/providers/auth_provider": "features/auth/providers/auth_provider",
};

void main() {
  var totalFixed = 0;
  final libDir = Directory('lib');
  
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    var content = entity.readAsStringSync();
    final original = content;

    // Fix short imports
    for (final entry in shortImportFixes.entries) {
      // Only fix if it's a standalone import (starts with import and has no path separators)
      final pattern = RegExp("import ${RegExp.escape(entry.key)};");
      content = content.replaceAll(pattern, "import ${entry.value};");
    }
    
    // Fix path corrections
    for (final entry in pathCorrections.entries) {
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
