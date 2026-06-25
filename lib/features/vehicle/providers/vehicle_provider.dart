import 'dart:io' as java_io;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motolog_mobile/core/constants/app_constants.dart';
import 'package:motolog_mobile/shared/database/dao/vehicle_dao.dart';
import 'package:motolog_mobile/data/models/vehicle.dart';
import 'package:motolog_mobile/shared/firebase/firestore_service.dart';
import 'package:motolog_mobile/features/vehicle/data/firebase/storage_service.dart';
import 'package:motolog_mobile/features/vehicle/data/images/vehicle_image_service.dart';

// ── Xe đang được chọn ──────────────────────────────────────────────────────

/// Lưu giữ ID của xe đang được chọn, lấy từ cache
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

// ── Danh sách xe ───────────────────────────────────────────────────────────

/// Lấy toàn bộ danh sách xe thuộc về user đang đăng nhập.
final vehicleListProvider = FutureProvider<List<Vehicle>>((ref) async {
  final user = ref.watch(authStateStreamProvider).valueOrNull;
  if (user == null) return [];
  return VehicleDao.instance.getAll(userId: user.uid);
});

/// Dữ liệu của xe đang được chọn (dùng để hiển thị lên Header / Title)
final selectedVehicleProvider = FutureProvider<Vehicle?>((ref) async {
  final id = ref.watch(selectedVehicleIdProvider);
  if (id == null) return null;
  return VehicleDao.instance.getById(id);
});

// ── CRUD Xe ────────────────────────────────────────────────────────────────
/// Provider quản lý danh sách Xe theo User hiện tại
final vehicleNotifierProvider =
    AsyncNotifierProvider<VehicleNotifier, List<Vehicle>>(
  VehicleNotifier.new,
);

/// Trạng thái quản lý Logic Thêm, Cập nhật, Xoá Xe và Đồng bộ dữ liệu lên Firestore
class VehicleNotifier extends AsyncNotifier<List<Vehicle>> {
  @override
  Future<List<Vehicle>> build() async {
    final user = ref.watch(authStateStreamProvider).valueOrNull;
    if (user == null) return [];
    return VehicleDao.instance.getAll(userId: user.uid);
  }

  Future<void> add(Vehicle vehicle) async {
    final user = ref.read(authStateStreamProvider).valueOrNull;
    
    // Tra cứu link ảnh từ Firebase Catalog
    final imageUrl = await VehicleImageService.instance.resolveImageUrl(
      brand: vehicle.brand,
      model: vehicle.model,
      type: (vehicle.engineCapacity?.toLowerCase().contains('ga') ?? false) ? 'tay_ga' : 'xe_so',
      year: vehicle.year,
    );
    
    final storage = ref.read(storageServiceProvider);

    String? regUrl = vehicle.registrationImageUrl;
    if (regUrl != null && !regUrl.startsWith('http')) {
      final url = await storage?.uploadVehicleImage(vehicle.id, 'registration', java_io.File(regUrl));
      if (url != null) regUrl = url;
    }

    String? inspUrl = vehicle.inspectionImageUrl;
    if (inspUrl != null && !inspUrl.startsWith('http')) {
      final url = await storage?.uploadVehicleImage(vehicle.id, 'inspection', java_io.File(inspUrl));
      if (url != null) inspUrl = url;
    }

    String? insuUrl = vehicle.insuranceImageUrl;
    if (insuUrl != null && !insuUrl.startsWith('http')) {
      final url = await storage?.uploadVehicleImage(vehicle.id, 'insurance', java_io.File(insuUrl));
      if (url != null) insuUrl = url;
    }

    String? avatarUrl = vehicle.imageUrl;
    if (avatarUrl != null && !avatarUrl.startsWith('http') && !avatarUrl.startsWith('assets/')) {
      final url = await storage?.uploadVehicleImage(vehicle.id, 'avatar', java_io.File(avatarUrl));
      if (url != null) avatarUrl = url;
    }

    final vehicleWithUser = vehicle.copyWith(
      userId: user?.uid, 
      cachedImageUrl: imageUrl,
      registrationImageUrl: regUrl,
      inspectionImageUrl: inspUrl,
      insuranceImageUrl: insuUrl,
      imageUrl: avatarUrl,
    );
    await VehicleDao.instance.insert(vehicleWithUser);

    _syncToFirestore(
      () => ref.read(firestoreServiceProvider)?.saveVehicle(vehicleWithUser),
      onFail: () async {
        await VehicleDao.instance.update(vehicleWithUser.copyWith(isSynced: 0));
      },
    );

    // Tự động chọn xe này nếu là chiếc xe đầu tiên của user
    final vehicles = await VehicleDao.instance.getAll(userId: user?.uid);
    if (vehicles.length == 1) {
      ref.read(selectedVehicleIdProvider.notifier).select(vehicleWithUser.id);
    }
    ref.invalidateSelf();
  }

  Future<void> updateEntry(Vehicle vehicle) async {
    final user = ref.read(authStateStreamProvider).valueOrNull;
    
    // Tra cứu lại ảnh phòng khi người dùng đổi dòng xe
    final imageUrl = await VehicleImageService.instance.resolveImageUrl(
      brand: vehicle.brand,
      model: vehicle.model,
      type: (vehicle.engineCapacity?.toLowerCase().contains('ga') ?? false) ? 'tay_ga' : 'xe_so',
      year: vehicle.year,
    );
    
    final storage = ref.read(storageServiceProvider);

    String? regUrl = vehicle.registrationImageUrl;
    if (regUrl != null && !regUrl.startsWith('http')) {
      final url = await storage?.uploadVehicleImage(vehicle.id, 'registration', java_io.File(regUrl));
      if (url != null) regUrl = url;
    }

    String? inspUrl = vehicle.inspectionImageUrl;
    if (inspUrl != null && !inspUrl.startsWith('http')) {
      final url = await storage?.uploadVehicleImage(vehicle.id, 'inspection', java_io.File(inspUrl));
      if (url != null) inspUrl = url;
    }

    String? insuUrl = vehicle.insuranceImageUrl;
    if (insuUrl != null && !insuUrl.startsWith('http')) {
      final url = await storage?.uploadVehicleImage(vehicle.id, 'insurance', java_io.File(insuUrl));
      if (url != null) insuUrl = url;
    }

    String? avatarUrl = vehicle.imageUrl;
    if (avatarUrl != null && !avatarUrl.startsWith('http') && !avatarUrl.startsWith('assets/')) {
      final url = await storage?.uploadVehicleImage(vehicle.id, 'avatar', java_io.File(avatarUrl));
      if (url != null) avatarUrl = url;
    }

    final vehicleWithUser = vehicle.copyWith(
      userId: user?.uid, 
      cachedImageUrl: imageUrl,
      registrationImageUrl: regUrl,
      inspectionImageUrl: inspUrl,
      insuranceImageUrl: insuUrl,
      imageUrl: avatarUrl,
    );
    await VehicleDao.instance.update(vehicleWithUser);

    _syncToFirestore(
      () => ref.read(firestoreServiceProvider)?.saveVehicle(vehicleWithUser),
      onFail: () async {
        await VehicleDao.instance.update(vehicleWithUser.copyWith(isSynced: 0));
      },
    );

    ref.invalidateSelf();
  }

  Future<void> delete(String id) async {
    await VehicleDao.instance.delete(id);

    _syncToFirestore(() => ref.read(firestoreServiceProvider)?.deleteVehicle(id));

    // Nếu xe bị xóa chính là xe đang được chọn thì bỏ chọn
    final selectedId = ref.read(selectedVehicleIdProvider);
    if (selectedId == id) {
      ref.read(selectedVehicleIdProvider.notifier).select(null);
    }
    ref.invalidateSelf();
  }

  /// Hàm tiện ích dùng để cập nhật số km nhanh chóng khi đổ xăng / bảo dưỡng
  Future<void> updateOdometer(String vehicleId, double odometer) async {
    await VehicleDao.instance.updateOdometer(vehicleId, odometer);

    _syncToFirestore(
      () async {
        final vehicle = await VehicleDao.instance.getById(vehicleId);
        if (vehicle != null) {
          await ref.read(firestoreServiceProvider)?.saveVehicle(vehicle);
        }
      },
      onFail: () async {
        final vehicle = await VehicleDao.instance.getById(vehicleId);
        if (vehicle != null) {
          await VehicleDao.instance.update(vehicle.copyWith(isSynced: 0));
        }
      },
    );

    ref.invalidateSelf();
  }

  Future<List<Vehicle>> get vehicles async => state.value ?? [];

  /// Gọi Firestore sync trong try-catch để lỗi mạng không ảnh hưởng UI.
  Future<void> _syncToFirestore(
    Future<void>? Function() action, {
    Future<void> Function()? onFail,
  }) async {
    try {
      await action();
    } catch (e) {
      debugPrint('[VehicleNotifier] Firestore sync error: $e');
      if (onFail != null) {
        await onFail();
      }
    }
  }
}
