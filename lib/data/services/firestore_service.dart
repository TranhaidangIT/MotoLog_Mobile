import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/vehicle.dart';
import '../models/fuel_entry.dart';
import '../models/maintenance_entry.dart';
import '../local/dao/vehicle_dao.dart';
import '../local/dao/fuel_dao.dart';
import '../local/dao/maintenance_dao.dart';

// ─── Firestore instance ───────────────────────────────────────────────────────
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// ─── Firestore Service ────────────────────────────────────────────────────────
class FirestoreService {
  final FirebaseFirestore _db;
  final String _uid;

  FirestoreService(this._db, this._uid);

  // ── Vehicles ────────────────────────────────────────────────────────────────
  CollectionReference get _vehicles =>
      _db.collection('users').doc(_uid).collection('vehicles');

  CollectionReference get _fuelEntries =>
      _db.collection('users').doc(_uid).collection('fuel_entries');

  CollectionReference get _maintenanceEntries =>
      _db.collection('users').doc(_uid).collection('maintenance_entries');

  /// Lưu/cập nhật xe lên Firestore
  Future<void> saveVehicle(Vehicle vehicle) async {
    await _vehicles.doc(vehicle.id).set(vehicle.toFirestore());
  }

  /// Xoá xe khỏi Firestore
  Future<void> deleteVehicle(String vehicleId) async {
    await _vehicles.doc(vehicleId).delete();
  }

  /// Stream danh sách xe của user
  Stream<List<Vehicle>> vehiclesStream() {
    return _vehicles.orderBy('created_at', descending: true).snapshots().map(
        (snap) => snap.docs
            .map((doc) =>
                Vehicle.fromFirestore(doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Lưu bản ghi nhiên liệu
  Future<void> saveFuelEntry(FuelEntry entry) async {
    await _fuelEntries.doc(entry.id).set(entry.toFirestore());
  }

  /// Xoá bản ghi nhiên liệu
  Future<void> deleteFuelEntry(String id) async {
    await _fuelEntries.doc(id).delete();
  }

  /// Stream bản ghi nhiên liệu
  Stream<List<FuelEntry>> fuelEntriesStream({String? vehicleId}) {
    Query query = _fuelEntries.orderBy('date', descending: true);
    if (vehicleId != null) {
      query = query.where('vehicle_id', isEqualTo: vehicleId);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((doc) =>
            FuelEntry.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList());
  }

  /// Lưu bản ghi bảo dưỡng
  Future<void> saveMaintenanceEntry(MaintenanceEntry entry) async {
    await _maintenanceEntries.doc(entry.id).set(entry.toFirestore());
  }

  /// Xoá bản ghi bảo dưỡng
  Future<void> deleteMaintenanceEntry(String id) async {
    await _maintenanceEntries.doc(id).delete();
  }

  /// Stream bản ghi bảo dưỡng
  Stream<List<MaintenanceEntry>> maintenanceEntriesStream({String? vehicleId}) {
    Query query = _maintenanceEntries.orderBy('next_date', descending: false);
    if (vehicleId != null) {
      query = query.where('vehicle_id', isEqualTo: vehicleId);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((doc) =>
            MaintenanceEntry.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList());
  }

  /// Lưu thông tin profile user
  Future<void> saveUserProfile(User user) async {
    await _db.collection('users').doc(_uid).set({
      'uid': _uid,
      'email': user.email,
      'display_name': user.displayName,
      'photo_url': user.photoURL,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Đồng bộ toàn bộ dữ liệu từ Cloud Firestore về SQLite local (khi đăng nhập thiết bị mới)
  Future<void> syncCloudToLocal() async {
    try {
      // 1. Tải & lưu Vehicles
      final vehiclesSnap = await _vehicles.get();
      for (var doc in vehiclesSnap.docs) {
        if (doc.exists) {
          final vehicle =
              Vehicle.fromFirestore(doc.data() as Map<String, dynamic>);
          await VehicleDao.instance.insert(vehicle);
        }
      }

      // 2. Tải & lưu Fuel Entries
      final fuelSnap = await _fuelEntries.get();
      for (var doc in fuelSnap.docs) {
        if (doc.exists) {
          final entry =
              FuelEntry.fromFirestore(doc.data() as Map<String, dynamic>);
          await FuelDao.instance.insert(entry);
        }
      }

      // 3. Tải & lưu Maintenance Entries
      final maintSnap = await _maintenanceEntries.get();
      for (var doc in maintSnap.docs) {
        if (doc.exists) {
          final entry = MaintenanceEntry.fromFirestore(
              doc.data() as Map<String, dynamic>);
          await MaintenanceDao.instance.insert(entry);
        }
      }
    } catch (e) {
      print('Error syncing Firestore to SQLite local: $e');
      rethrow;
    }
  }
}

// ─── StreamProvider cho FirebaseAuth authStateChanges ──────────────────────────
final authStateStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ─── FirestoreService Provider ────────────────────────────────────────────────
final firestoreServiceProvider = Provider<FirestoreService?>((ref) {
  final user = ref.watch(authStateStreamProvider).valueOrNull;
  if (user == null) return null;
  final db = ref.watch(firestoreProvider);
  return FirestoreService(db, user.uid);
});
