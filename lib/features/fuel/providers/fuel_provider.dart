import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motolog_mobile/shared/database/dao/fuel_dao.dart';
import 'package:motolog_mobile/data/models/fuel_entry.dart';
import 'package:motolog_mobile/shared/firebase/firestore_service.dart';
import 'package:motolog_mobile/features/vehicle/providers/vehicle_provider.dart';

// ── Danh sách đổ xăng ──────────────────────────────────────────────────────

/// Lấy tất cả lần đổ xăng của xe đang được chọn.
final fuelListProvider = FutureProvider.autoDispose<List<FuelEntry>>((ref) async {
  final vehicleId = ref.watch(selectedVehicleIdProvider);
  if (vehicleId == null) return [];
  return FuelDao.instance.getByVehicle(vehicleId);
});

/// Lấy danh sách đổ xăng trong khoảng thời gian (dùng cho biểu đồ thống kê).
final fuelListByMonthProvider = FutureProvider.family.autoDispose<
    List<FuelEntry>, ({String vehicleId, DateTime from, DateTime to})>(
  (ref, args) async {
    ref.watch(fuelNotifierProvider);
    return FuelDao.instance.getByVehicle(
      args.vehicleId,
      from: args.from,
      to: args.to,
    );
  },
);

/// Chi phí đổ xăng theo tháng (dữ liệu raw cho biểu đồ).
final fuelMonthlyCostsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, vehicleId) async {
  return FuelDao.instance.monthlyCosts(vehicleId);
});

// ── CRUD đổ xăng ───────────────────────────────────────────────────────────

/// Provider quản lý danh sách và trạng thái của các lần Đổ xăng theo xe
final fuelNotifierProvider =
    AsyncNotifierProvider.autoDispose<FuelNotifier, List<FuelEntry>>(
  FuelNotifier.new,
);

/// Trạng thái quản lý Logic Thêm, Cập nhật, Xoá dữ liệu Đổ xăng và Đồng bộ dữ liệu lên Firestore
class FuelNotifier extends AutoDisposeAsyncNotifier<List<FuelEntry>> {
  @override
  Future<List<FuelEntry>> build() async {
    final vehicleId = ref.watch(selectedVehicleIdProvider);
    if (vehicleId == null) return [];
    return FuelDao.instance.getByVehicle(vehicleId);
  }

  Future<void> add(FuelEntry entry) async {
    await FuelDao.instance.insert(entry);
    _syncToFirestore(
      () => ref.read(firestoreServiceProvider)?.saveFuelEntry(entry),
      onFail: () async {
        await FuelDao.instance.update(entry.copyWith(isSynced: 0));
      },
    );

    // Cập nhật odometer xe nếu lần này đi xa hơn
    await ref.read(vehicleNotifierProvider.notifier)
        .updateOdometer(entry.vehicleId, entry.odometer);
    ref.invalidateSelf();
  }

  Future<void> updateEntry(FuelEntry entry) async {
    await FuelDao.instance.update(entry);
    _syncToFirestore(
      () => ref.read(firestoreServiceProvider)?.saveFuelEntry(entry),
      onFail: () async {
        await FuelDao.instance.update(entry.copyWith(isSynced: 0));
      },
    );
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    _syncToFirestore(() => ref.read(firestoreServiceProvider)?.deleteFuelEntry(id));
    await FuelDao.instance.delete(id);
    ref.invalidateSelf();
  }

  /// Gọi Firestore sync trong try-catch để lỗi mạng không ảnh hưởng UI.
  Future<void> _syncToFirestore(
    Future<void>? Function() action, {
    Future<void> Function()? onFail,
  }) async {
    try {
      await action();
      // Nếu là lần đầu tiên có mạng lại, có thể kích hoạt retry, nhưng sẽ do hàm app load làm.
    } catch (e) {
      debugPrint('[FuelNotifier] Firestore sync error: $e');
      if (onFail != null) {
        await onFail();
      }
    }
  }
}

// ── Thống kê tháng này ──────────────────────────────────────────────────────

/// Tổng tiền xăng tháng hiện tại.
final fuelCostThisMonthProvider = FutureProvider.family<double, String>(
  (ref, vehicleId) async {
    ref.watch(fuelNotifierProvider);
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final to = nextMonth.subtract(const Duration(seconds: 1));
    return FuelDao.instance.totalCostInRange(vehicleId, from: from, to: to);
  },
);

/// Tổng lít xăng tháng hiện tại.
final fuelLitersThisMonthProvider = FutureProvider.family<double, String>(
  (ref, vehicleId) async {
    ref.watch(fuelNotifierProvider);
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final to = nextMonth.subtract(const Duration(seconds: 1));
    return FuelDao.instance.totalLitersInRange(vehicleId, from: from, to: to);
  },
);
