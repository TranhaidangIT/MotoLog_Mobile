import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motolog_mobile/data/models/custom_reminder.dart';
import 'package:motolog_mobile/data/local/custom_reminder_dao.dart';
import 'package:motolog_mobile/features/vehicle/providers/vehicle_provider.dart';

/// Provider theo dõi và quản lý danh sách các Nhắc nhở tuỳ chỉnh của Xe đang được chọn
final customReminderNotifierProvider = StateNotifierProvider<CustomReminderNotifier, List<CustomReminder>>((ref) {
  final vehicleId = ref.watch(selectedVehicleIdProvider);
  return CustomReminderNotifier(vehicleId);
});

/// Trạng thái quản lý logic Thêm/Xoá/Sửa các Lịch nhắc nhở (CustomReminder)
class CustomReminderNotifier extends StateNotifier<List<CustomReminder>> {
  final String? vehicleId;
  final _dao = CustomReminderDao.instance;

  CustomReminderNotifier(this.vehicleId) : super([]) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (vehicleId == null) {
      state = [];
      return;
    }
    state = await _dao.getByVehicleId(vehicleId!);
  }

  Future<void> addReminder(CustomReminder item) async {
    await _dao.insert(item);
    state = [...state, item];
  }

  Future<void> deleteReminder(String id) async {
    await _dao.delete(id);
    state = state.where((e) => e.id != id).toList();
  }
}
