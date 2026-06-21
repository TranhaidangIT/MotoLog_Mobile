import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/maintenance_item.dart';
import '../data/local/maintenance_item_dao.dart';
import 'vehicle_provider.dart';

final maintenanceItemNotifierProvider = StateNotifierProvider<MaintenanceItemNotifier, List<MaintenanceItem>>((ref) {
  final vehicleId = ref.watch(selectedVehicleIdProvider);
  return MaintenanceItemNotifier(vehicleId);
});

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
