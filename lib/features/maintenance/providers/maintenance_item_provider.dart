import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motolog_mobile/data/models/maintenance_item.dart';
import 'package:motolog_mobile/data/local/maintenance_item_dao.dart';
import 'package:motolog_mobile/features/vehicle/providers/vehicle_provider.dart';

/// Provider theo dõi danh sách các Hạng mục bảo dưỡng (Nhớt máy, lọc gió...) của chiếc xe đang được chọn
final maintenanceItemNotifierProvider = StateNotifierProvider<MaintenanceItemNotifier, List<MaintenanceItem>>((ref) {
  final vehicleId = ref.watch(selectedVehicleIdProvider);
  return MaintenanceItemNotifier(vehicleId);
});

/// Trạng thái quản lý logic Tải/Cập nhật/Đánh dấu Hoàn thành Hạng mục bảo dưỡng
class MaintenanceItemNotifier extends StateNotifier<List<MaintenanceItem>> {
  final String? vehicleId;
  final _dao = MaintenanceItemDao.instance;

  MaintenanceItemNotifier(this.vehicleId) : super([]) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    if (vehicleId == null) {
      state = [];
      return;
    }
    
    // Đọc từ DB
    var items = await _dao.getByVehicleId(vehicleId!);
    
    // Nếu chưa có (xe mới), nạp danh sách mặc định
    if (items.isEmpty) {
      items = _dao.getDefaultItems(vehicleId!);
      await _dao.insertAll(items);
    }
    
    state = items;
  }

  Future<void> updateItem(MaintenanceItem item) async {
    await _dao.update(item);
    final index = state.indexWhere((e) => e.id == item.id);
    if (index != -1) {
      final newState = [...state];
      newState[index] = item;
      state = newState;
    }
  }

  Future<void> toggleReminder(String itemId, bool isOn) async {
    final item = state.firstWhere((e) => e.id == itemId);
    final updated = item.copyWith(isReminderOn: isOn);
    await updateItem(updated);
  }

  Future<void> markDone(String itemId, int odoAtDone) async {
    final item = state.firstWhere((e) => e.id == itemId);
    final updated = item.copyWith(lastDoneOdo: odoAtDone);
    await updateItem(updated);
  }
}
