import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/dao/fuel_dao.dart';
import '../data/models/fuel_entry.dart';
import '../data/services/firestore_service.dart';
import 'vehicle_provider.dart';

// ===== FUEL LIST PROVIDER =====

/// Provider lấy danh sách đổ xăng theo xe đang chọn
final fuelListProvider = FutureProvider.autoDispose<List<FuelEntry>>((ref) async {
  final vehicleId = ref.watch(selectedVehicleIdProvider);
  if (vehicleId == null) return [];
  return FuelDao.instance.getByVehicle(vehicleId);
});

/// Provider lấy fuel entries theo tháng (cho statistics)
final fuelListByMonthProvider = FutureProvider.family.autoDispose<
    List<FuelEntry>, ({String vehicleId, DateTime from, DateTime to})>(
  (ref, args) async {
    return FuelDao.instance.getByVehicle(
      args.vehicleId,
      from: args.from,
      to: args.to,
    );
  },
);

/// Monthly fuel cost data for chart
final fuelMonthlyCostsProvider = FutureProvider.family<
    List<Map<String, dynamic>>, String>((ref, vehicleId) async {
  return FuelDao.instance.monthlyCosts(vehicleId);
});

// ===== FUEL NOTIFIER (CRUD) =====

final fuelNotifierProvider = AsyncNotifierProvider.autoDispose<FuelNotifier, List<FuelEntry>>(
  FuelNotifier.new,
);

class FuelNotifier extends AutoDisposeAsyncNotifier<List<FuelEntry>> {
  @override
  Future<List<FuelEntry>> build() async {
    final vehicleId = ref.watch(selectedVehicleIdProvider);
    if (vehicleId == null) return [];
    return FuelDao.instance.getByVehicle(vehicleId);
  }

  /// Thêm lần đổ xăng mới
  Future<void> add(FuelEntry entry) async {
    await FuelDao.instance.insert(entry);

    // Sync to Firestore
    final firestoreService = ref.read(firestoreServiceProvider);
    if (firestoreService != null) {
      try {
        await firestoreService.saveFuelEntry(entry);
      } catch (e) {
        print('Firestore sync add fuel entry error: $e');
      }
    }

    // Cập nhật odometer xe (hàm updateOdometer bên trong đã có sync vehicle lên Firestore)
    await ref
        .read(vehicleNotifierProvider.notifier)
        .updateOdometer(entry.vehicleId, entry.odometer);
    ref.invalidateSelf();
  }

  /// Cập nhật
  Future<void> updateEntry(FuelEntry entry) async {
    await FuelDao.instance.update(entry);

    // Sync to Firestore
    final firestoreService = ref.read(firestoreServiceProvider);
    if (firestoreService != null) {
      try {
        await firestoreService.saveFuelEntry(entry);
      } catch (e) {
        print('Firestore sync update fuel entry error: $e');
      }
    }

    ref.invalidateSelf();
  }

  /// Xóa
  Future<void> delete(String id) async {
    // Sync to Firestore (delete from Firestore first while we still have access to it or we can do it after local delete)
    final firestoreService = ref.read(firestoreServiceProvider);
    if (firestoreService != null) {
      try {
        await firestoreService.deleteFuelEntry(id);
      } catch (e) {
        print('Firestore sync delete fuel entry error: $e');
      }
    }

    await FuelDao.instance.delete(id);
    ref.invalidateSelf();
  }
}

// ===== STATISTICS PROVIDERS =====

/// Tổng tiền xăng tháng này
final fuelCostThisMonthProvider = FutureProvider.family<double, String>(
  (ref, vehicleId) async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0);
    return FuelDao.instance.totalCostInRange(vehicleId, from: from, to: to);
  },
);

/// Tổng lít xăng tháng này
final fuelLitersThisMonthProvider = FutureProvider.family<double, String>(
  (ref, vehicleId) async {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final to = DateTime(now.year, now.month + 1, 0);
    return FuelDao.instance.totalLitersInRange(vehicleId, from: from, to: to);
  },
);
