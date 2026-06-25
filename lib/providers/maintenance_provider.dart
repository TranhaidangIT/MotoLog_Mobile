import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/local/dao/maintenance_dao.dart';
import '../data/models/maintenance_entry.dart';
import '../data/services/firestore_service.dart';
import 'vehicle_provider.dart';

// ── Danh sách bảo dưỡng ────────────────────────────────────────────────────

/// Lấy toàn bộ lịch sử bảo dưỡng của xe đang được chọn.
final maintenanceListProvider =
    FutureProvider.autoDispose<List<MaintenanceEntry>>((ref) async {
  final vehicleId = ref.watch(selectedVehicleIdProvider);
  if (vehicleId == null) return [];
  return MaintenanceDao.instance.getByVehicle(vehicleId);
});

/// Các mục bảo dưỡng sắp đến hạn trong 7 ngày tới.
final upcomingMaintenanceProvider =
    FutureProvider.autoDispose<List<MaintenanceEntry>>((ref) async {
  final vehicleId = ref.watch(selectedVehicleIdProvider);
  return MaintenanceDao.instance.getUpcomingDue(vehicleId: vehicleId);
});

/// Lấy danh sách bảo dưỡng trong khoảng thời gian (dùng cho biểu đồ thống kê).
final maintenanceListByMonthProvider = FutureProvider.family.autoDispose<
    List<MaintenanceEntry>, ({String vehicleId, DateTime from, DateTime to})>(
  (ref, args) async {
    ref.watch(maintenanceNotifierProvider);
    return MaintenanceDao.instance.getByVehicle(
      args.vehicleId,
      from: args.from,
      to: args.to,
    );
  },
);

/// Chi phí bảo dưỡng theo tháng (dữ liệu raw cho biểu đồ).
final maintenanceMonthlyCostsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, vehicleId) async {
  return MaintenanceDao.instance.monthlyCosts(vehicleId);
});

// ── CRUD bảo dưỡng ─────────────────────────────────────────────────────────

/// Provider quản lý danh sách và trạng thái các lần Bảo dưỡng / Sửa chữa của xe
final maintenanceNotifierProvider = AsyncNotifierProvider.autoDispose<
    MaintenanceNotifier, List<MaintenanceEntry>>(
  MaintenanceNotifier.new,
);

/// Trạng thái quản lý Logic Thêm, Cập nhật, Xoá dữ liệu Bảo dưỡng và Đồng bộ dữ liệu lên Firestore
class MaintenanceNotifier
    extends AutoDisposeAsyncNotifier<List<MaintenanceEntry>> {
  @override
  Future<List<MaintenanceEntry>> build() async {
    final vehicleId = ref.watch(selectedVehicleIdProvider);
    if (vehicleId == null) return [];
    return MaintenanceDao.instance.getByVehicle(vehicleId);
  }

  Future<void> add(MaintenanceEntry entry) async {
    await MaintenanceDao.instance.insert(entry);
    _syncToFirestore(
      () => ref.read(firestoreServiceProvider)?.saveMaintenanceEntry(entry),
      onFail: () async {
        await MaintenanceDao.instance.update(entry.copyWith(isSynced: 0));
      },
    );

    // Cập nhật odometer xe nếu lần này đi xa hơn
    await ref.read(vehicleNotifierProvider.notifier)
        .updateOdometer(entry.vehicleId, entry.odometer);
    ref.invalidateSelf();
  }

  Future<void> updateEntry(MaintenanceEntry entry) async {
    await MaintenanceDao.instance.update(entry);
    _syncToFirestore(
      () => ref.read(firestoreServiceProvider)?.saveMaintenanceEntry(entry),
      onFail: () async {
        await MaintenanceDao.instance.update(entry.copyWith(isSynced: 0));
      },
    );
    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    _syncToFirestore(() => ref.read(firestoreServiceProvider)?.deleteMaintenanceEntry(id));
    await MaintenanceDao.instance.delete(id);
    ref.invalidateSelf();
  }

  /// Gọi Firestore sync trong try-catch để lỗi mạng không ảnh hưởng UI.
  Future<void> _syncToFirestore(
    Future<void>? Function() action, {
    Future<void> Function()? onFail,
  }) async {
    try {
      await action();
    } catch (e) {
      debugPrint('[MaintenanceNotifier] Firestore sync error: $e');
      if (onFail != null) {
        await onFail();
      }
    }
  }
}

// ── Thống kê tháng này ──────────────────────────────────────────────────────

/// Tổng chi phí bảo dưỡng tháng hiện tại.
final maintenanceCostThisMonthProvider = FutureProvider.family<double, String>(
  (ref, vehicleId) async {
    ref.watch(maintenanceNotifierProvider);
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final to = nextMonth.subtract(const Duration(seconds: 1));
    return MaintenanceDao.instance.totalCostInRange(vehicleId, from: from, to: to);
  },
);
