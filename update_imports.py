import os
import re

# Mapping: old import pattern -> new import path (relative to package)
REPLACEMENTS = [
    # shared/database
    ("data/local/database_helper", "shared/database/database_helper"),
    # shared/firebase
    ("data/services/firestore_service", "shared/firebase/firestore_service"),
    ("data/services/backup_delete_service", "shared/firebase/backup_delete_service"),
    # shared/location
    ("services/location_service", "shared/location/location_service"),
    # shared/notifications
    ("services/notification_service", "shared/notifications/notification_service"),
    # features/auth
    ("screens/auth/login_screen", "features/auth/screens/login_screen"),
    ("screens/auth/register_screen", "features/auth/screens/register_screen"),
    ("providers/auth_provider", "features/auth/providers/auth_provider"),
    # features/vehicle
    ("screens/my_vehicle_screen", "features/vehicle/screens/my_vehicle_screen"),
    ("screens/document_edit_screen", "features/documents/screens/document_edit_screen"),
    ("screens/vehicle/add_edit_vehicle_screen", "features/vehicle/screens/add_edit_vehicle_screen"),
    ("screens/vehicle/add_vehicle_method_screen", "features/vehicle/screens/add_vehicle_method_screen"),
    ("screens/vehicle/quick_setup_vehicle_screen", "features/vehicle/screens/quick_setup_vehicle_screen"),
    ("screens/vehicle/vehicle_detail_screen", "features/vehicle/screens/vehicle_detail_screen"),
    ("screens/vehicle/widgets/vehicle_card", "features/vehicle/widgets/vehicle_card"),
    ("providers/vehicle_provider", "features/vehicle/providers/vehicle_provider"),
    ("data/services/storage_service", "features/vehicle/data/firebase/storage_service"),
    ("data/services/vehicle_image_service", "features/vehicle/data/images/vehicle_image_service"),
    # features/fuel
    ("screens/fuel/add_edit_fuel_screen", "features/fuel/screens/add_edit_fuel_screen"),
    ("screens/fuel/fuel_list_screen", "features/fuel/screens/fuel_list_screen"),
    ("screens/fuel_log_screen", "features/fuel/screens/fuel_log_screen"),
    ("screens/fuel_history_screen", "features/fuel/screens/fuel_history_screen"),
    ("providers/fuel_provider", "features/fuel/providers/fuel_provider"),
    ("services/fuel_price_service", "features/fuel/api/fuel_price_service"),
    # features/maintenance
    ("screens/maintenance/add_edit_maintenance_screen", "features/maintenance/screens/add_edit_maintenance_screen"),
    ("screens/maintenance/maintenance_list_screen", "features/maintenance/screens/maintenance_list_screen"),
    ("screens/maintenance_screen", "features/maintenance/screens/maintenance_screen"),
    ("screens/maintenance_item_detail_screen", "features/maintenance/screens/maintenance_item_detail_screen"),
    ("screens/maintenance_setup_screen", "features/maintenance/screens/maintenance_setup_screen"),
    ("screens/add_maintenance_screen", "features/maintenance/screens/add_maintenance_screen"),
    ("providers/maintenance_provider", "features/maintenance/providers/maintenance_provider"),
    ("providers/maintenance_item_provider", "features/maintenance/providers/maintenance_item_provider"),
    ("screens/add_part_screen", "features/maintenance/screens/add_part_screen"),
    ("screens/part_detail_screen", "features/maintenance/screens/part_detail_screen"),
    ("screens/parts_screen", "features/maintenance/screens/parts_screen"),
    # features/statistics
    ("screens/statistics/statistics_screen", "features/statistics/screens/statistics_screen"),
    ("screens/expense_screen", "features/statistics/screens/expense_screen"),
    ("screens/category_detail_screen", "features/statistics/screens/category_detail_screen"),
    # features/reminder
    ("screens/reminder_screen", "features/reminder/screens/reminder_screen"),
    ("screens/add_reminder_screen", "features/reminder/screens/add_reminder_screen"),
    ("providers/custom_reminder_provider", "features/reminder/providers/custom_reminder_provider"),
    # features/export
    ("screens/export_data_screen", "features/export/screens/export_data_screen"),
    ("data/services/data_export_service", "features/export/data/data_export_service"),
    # features/profile
    ("screens/profile_screen", "features/profile/screens/profile_screen"),
    ("screens/edit_profile_screen", "features/profile/screens/edit_profile_screen"),
    ("screens/app_settings_screen", "features/profile/screens/app_settings_screen"),
    ("screens/help_center_screen", "features/profile/screens/help_center_screen"),
    # home/onboarding/garage
    ("screens/home_screen", "features/home_screen"),
    ("screens/onboarding_screen", "features/onboarding_screen"),
    ("screens/garage_screen", "features/garage_screen"),
    ("screens/garage/garage_screen", "features/vehicle/screens/garage_screen"),
    # DAO
    ("data/local/dao/vehicle_dao", "shared/database/dao/vehicle_dao"),
    ("data/local/dao/fuel_dao", "shared/database/dao/fuel_dao"),
    ("data/local/dao/maintenance_dao", "shared/database/dao/maintenance_dao"),
]

PACKAGE_NAME = "motolog_mobile"

def update_file(filepath, replacements):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    for old, new in replacements:
        # Match package imports: package:motolog_mobile/...old...
        content = content.replace(
            f"package:{PACKAGE_NAME}/{old}",
            f"package:{PACKAGE_NAME}/{new}"
        )
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated: {filepath}")

count = 0
for root, dirs, files in os.walk('lib'):
    # Skip hidden dirs
    dirs[:] = [d for d in dirs if not d.startswith('.')]
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            update_file(path, REPLACEMENTS)
            count += 1

# Also update core/router which uses routes
for root, dirs, files in os.walk('lib'):
    dirs[:] = [d for d in dirs if not d.startswith('.')]
    for file in files:
        if file.endswith('.dart'):
            path = os.path.join(root, file)
            with open(path, 'r', encoding='utf-8') as f:
                content = f.read()
            original = content
            # Relative import updates for files that moved
            for old, new in REPLACEMENTS:
                old_file = old.split('/')[-1]
                new_file = new.split('/')[-1]
                if old_file == new_file:
                    pass  # Same filename, path change handled by package import above
            if content != original:
                with open(path, 'w', encoding='utf-8') as f:
                    f.write(content)

print(f"Scanned {count} dart files")
print("Import update complete!")
