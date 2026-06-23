import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Firebase Storage instance ───────────────────────────────────────────────
final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// ─── Storage Service ──────────────────────────────────────────────────────────
class StorageService {
  final FirebaseStorage _storage;
  final String _uid;

  StorageService(this._storage, this._uid);

  /// Upload ảnh giấy tờ xe lên Firebase Storage và trả về URL public
  /// [docType] có thể là: 'registration', 'inspection', 'insurance', 'avatar'
  Future<String?> uploadVehicleImage(String vehicleId, String docType, File file) async {
    try {
      // Đường dẫn: users/{uid}/vehicles/{vehicleId}/{docType}.jpg
      final ref = _storage
          .ref()
          .child('users')
          .child(_uid)
          .child('vehicles')
          .child(vehicleId)
          .child('$docType.jpg');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  /// Xoá toàn bộ thư mục ảnh của một xe khi xe bị xoá
  Future<void> deleteVehicleImages(String vehicleId) async {
    try {
      final ref = _storage
          .ref()
          .child('users')
          .child(_uid)
          .child('vehicles')
          .child(vehicleId);

      // Lấy danh sách các file trong thư mục xe này
      final listResult = await ref.listAll();
      for (var item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      debugPrint('Error deleting vehicle images from Firebase Storage: $e');
    }
  }
}

// ─── StorageService Provider ──────────────────────────────────────────────────
final storageServiceProvider = Provider<StorageService?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  final storage = ref.watch(firebaseStorageProvider);
  return StorageService(storage, user.uid);
});
