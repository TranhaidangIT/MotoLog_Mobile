import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../data/local/dao/vehicle_dao.dart';
import '../data/models/vehicle.dart';
import '../data/services/firestore_service.dart';

// ===== SELECTED VEHICLE =====

/// ID của xe đang được chọn
final selectedVehicleIdProvider =
    StateNotifierProvider<SelectedVehicleIdNotifier, String?>(
  (ref) => SelectedVehicleIdNotifier(),
);

class SelectedVehicleIdNotifier extends StateNotifier<String?> {
  SelectedVehicleIdNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(AppConstants.keySelectedVehicleId);
  }

  Future<void> select(String? id) async {
    state = id;
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setString(AppConstants.keySelectedVehicleId, id);
    } else {
      await prefs.remove(AppConstants.keySelectedVehicleId);
    }
  }
}

// ===== ALL VEHICLES =====

/// Provider lấy danh sách tất cả xe từ DB
final vehicleListProvider = FutureProvider<List<Vehicle>>((ref) async {
  return VehicleDao.instance.getAll();
});

/// Provider lấy xe đang được chọn
final selectedVehicleProvider = FutureProvider<Vehicle?>((ref) async {
  final id = ref.watch(selectedVehicleIdProvider);
  if (id == null) return null;
  return VehicleDao.instance.getById(id);
});

// ===== VEHICLE NOTIFIER (CRUD) =====

final vehicleNotifierProvider =
    AsyncNotifierProvider<VehicleNotifier, List<Vehicle>>(
  VehicleNotifier.new,
);

class VehicleNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    return VehicleDao.instance.getAll();
  }

  /// Thêm xe mới
  Future<void> add(Vehicle vehicle) async {
    await VehicleDao.instance.insert(vehicle);

    // Sync to Firestore
    final firestoreService = ref.read(firestoreServiceProvider);
    if (firestoreService != null) {
      try {
        await firestoreService.saveVehicle(vehicle);
      } catch (e) {
        print('Firestore sync add vehicle error: $e');
      }
    }

    // Tự động chọn xe đầu tiên
    final vehicles = await VehicleDao.instance.getAll();
    if (vehicles.length == 1) {
      ref.read(selectedVehicleIdProvider.notifier).select(vehicle.id);
    }
    ref.invalidateSelf();
  }

  /// Cập nhật xe
  Future<void> updateEntry(Vehicle vehicle) async {
    await VehicleDao.instance.update(vehicle);

    // Sync to Firestore
    final firestoreService = ref.read(firestoreServiceProvider);
    if (firestoreService != null) {
      try {
        await firestoreService.saveVehicle(vehicle);
      } catch (e) {
        print('Firestore sync update vehicle error: $e');
      }
    }

    ref.invalidateSelf();
  }

  /// Xóa xe
  Future<void> delete(String id) async {
    await VehicleDao.instance.delete(id);

    // Sync to Firestore
    final firestoreService = ref.read(firestoreServiceProvider);
    if (firestoreService != null) {
      try {
        await firestoreService.deleteVehicle(id);
      } catch (e) {
        print('Firestore sync delete vehicle error: $e');
      }
    }

    // Nếu đang chọn xe bị xóa → reset selection
    final selectedId = ref.read(selectedVehicleIdProvider);
    if (selectedId == id) {
      ref.read(selectedVehicleIdProvider.notifier).select(null);
    }
    ref.invalidateSelf();
  }

  /// Cập nhật odometer
  Future<void> updateOdometer(String vehicleId, double odometer) async {
    await VehicleDao.instance.updateOdometer(vehicleId, odometer);

    // Sync to Firestore (get updated vehicle and sync it)
    final firestoreService = ref.read(firestoreServiceProvider);
    if (firestoreService != null) {
      try {
        final vehicle = await VehicleDao.instance.getById(vehicleId);
        if (vehicle != null) {
          await firestoreService.saveVehicle(vehicle);
        }
      } catch (e) {
        print('Firestore sync update odometer error: $e');
      }
    }

    ref.invalidateSelf();
  }

  Future<List<Vehicle>> get vehicles async => state.value ?? [];
}
