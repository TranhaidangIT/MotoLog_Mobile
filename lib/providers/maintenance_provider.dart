import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/dao/maintenance_dao.dart';
import '../data/models/maintenance_entry.dart';
import '../data/services/firestore_service.dart';
import 'vehicle_provider.dart';

// ===== MAINTENANCE LIST PROVIDER =====

final maintenanceListProvider = FutureProvider.autoDispose<List<MaintenanceEntry>>((ref) async {
  final vehicleId = ref.watch(selectedVehicleIdProvider);
  if (vehicleId == null) return [];
  return MaintenanceDao.instance.getByVehicle(vehicleId);
});

/// Lấy các bảo dưỡng sắp đến hạn (7 ngày)
final upcomingMaintenanceProvider = FutureProvider.autoDispose<List<MaintenanceEntry>>((ref) async {
  final vehicleId = ref.watch(selectedVehicleIdProvider);
  return MaintenanceDao.instance.getUpcomingDue(vehicleId: vehicleId);
});

/// Monthly maintenance costs for chart
final maintenanceMonthlyCostsProvider = FutureProvider.family<
    List<Map<String, dynamic>>, String>((ref, vehicleId) async {
  return MaintenanceDao.instance.monthlyCosts(vehicleId);
});

// ===== MAINTENANCE NOTIFIER (CRUD) =====

final maintenanceNotifierProvider =
    AsyncNotifierProvider.autoDispose<MaintenanceNotifier, List<MaintenanceEntry>>(
  MaintenanceNotifier.new,
);

class MaintenanceNotifier extends AutoDisposeAsyncNotifier<List<MaintenanceEntry>> {
  @override
  Future<List<MaintenanceEntry>> build() async {
    final vehicleId = ref.watch(selectedVehicleIdProvider);
    if (vehicleId == null) return [];
    return MaintenanceDao.instance.getByVehicle(vehicleId);
  }

  Future<void> add(MaintenanceEntry entry) async {
    await MaintenanceDao.instance.insert(entry);

    // Sync to Firestore
    final firestoreService = ref.read(firestoreServiceProvider);
    if (firestoreService != null) {
      try {
        await firestoreService.saveMaintenanceEntry(entry);
      } catch (e) {
        print('Firestore sync add maintenance error: $e');
      }
    }

    // Cập nhật odometer xe
    await ref
        .read(vehicleNotifierProvider.notifier)
        .updateOdometer(entry.vehicleId, entry.odometer);
    ref.invalidateSelf();
  }

  Future<void> updateEntry(MaintenanceEntry entry) async {
    await MaintenanceDao.instance.update(entry);

    // Sync to Firestore
    final firestoreService = ref.read(firestoreServiceProvider);
    if (firestoreService != null) {
      try {
        await firestoreService.saveMaintenanceEntry(entry);
      } catch (e) {
        print('Firestore sync update maintenance error: $e');
      }
    }

    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    // Sync to Firestore
    final firestoreService = ref.read(firestoreServiceProvider);
    if (firestoreService != null) {
      try {
        await firestoreService.deleteMaintenanceEntry(id);
      } catch (e) {
        print('Firestore sync delete maintenance error: $e');
      }
    }

    await MaintenanceDao.instance.delete(id);
    ref.invalidateSelf();
  }
}

// ===== STATISTICS =====

final maintenanceCostThisMonthProvider = FutureProvider.family<double, String>(
  (ref, vehicleId) async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0);
    return MaintenanceDao.instance.totalCostInRange(vehicleId, from: from, to: to);
  },
);
