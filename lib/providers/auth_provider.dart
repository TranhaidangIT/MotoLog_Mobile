import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/local/database_helper.dart';
import '../data/services/firestore_service.dart';
import '../firebase_options.dart';
import 'vehicle_provider.dart';

// ─── Firebase Auth instance ───────────────────────────────────────────────────
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// ─── Auth state stream ────────────────────────────────────────────────────────
/// Stream theo dõi trạng thái đăng nhập: User? (null = chưa đăng nhập)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// ─── Current user ─────────────────────────────────────────────────────────────
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

// ─── Auth Notifier ────────────────────────────────────────────────────────────
/// Trạng thái quản lý toàn bộ các luồng Đăng nhập, Đăng xuất, Đăng ký bằng Email và Google
class AuthNotifier extends AsyncNotifier<void> {
  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);

  @override
  Future<void> build() async {}

  /// Đăng nhập bằng Email + Password
  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = _auth.currentUser;
      if (user != null) {
        final firestore = ref.read(firestoreProvider);
        final firestoreService = FirestoreService(firestore, user.uid);
        await firestoreService.saveUserProfile(user);
        // Đồng bộ dữ liệu từ Cloud về Local SQLite
        try {
          await firestoreService.syncCloudToLocal();
          // Invalidate các provider liên quan đến dữ liệu để UI cập nhật mới
          ref.invalidate(selectedVehicleIdProvider);
          ref.invalidate(vehicleNotifierProvider);
        } catch (e) {
          debugPrint('Lỗi đồng bộ dữ liệu lúc đăng nhập: $e');
        }
      }
    });
  }

  /// Đăng ký tài khoản mới bằng Email + Password
  Future<void> registerWithEmail(
      String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Cập nhật displayName
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      final user = _auth.currentUser;
      if (user != null) {
        final firestore = ref.read(firestoreProvider);
        await FirestoreService(firestore, user.uid).saveUserProfile(user);
      }
    });
  }

  /// Đăng nhập bằng Google
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final googleSignIn = GoogleSignIn(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? DefaultFirebaseOptions.ios.iosClientId
            : null,
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Đăng nhập Google bị huỷ');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      final user = _auth.currentUser;
      if (user != null) {
        final firestore = ref.read(firestoreProvider);
        final firestoreService = FirestoreService(firestore, user.uid);
        await firestoreService.saveUserProfile(user);
        // Đồng bộ dữ liệu từ Cloud về Local SQLite
        try {
          await firestoreService.syncCloudToLocal();
          // Invalidate các provider liên quan đến dữ liệu để UI cập nhật mới
          ref.invalidate(selectedVehicleIdProvider);
          ref.invalidate(vehicleNotifierProvider);
        } catch (e) {
          debugPrint('Lỗi đồng bộ dữ liệu lúc đăng nhập: $e');
        }
      }
    });
  }

  /// Gửi email đặt lại mật khẩu
  Future<void> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _auth.sendPasswordResetEmail(email: email.trim());
    });
  }

  /// Đăng xuất
  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final googleSignIn = GoogleSignIn(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? DefaultFirebaseOptions.ios.iosClientId
            : null,
      );
      await googleSignIn.signOut();
      await _auth.signOut();
      
      // Clear local database cache & selected vehicle ID on sign out
      await ref.read(selectedVehicleIdProvider.notifier).select(null);
      await DatabaseHelper.instance.clearAll();
      
      // Invalidate providers to force UI reload with clean state
      ref.invalidate(selectedVehicleIdProvider);
      ref.invalidate(vehicleNotifierProvider);
    });
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(() {
  return AuthNotifier();
});

// ─── Error message helper ────────────────────────────────────────────────────
String getAuthErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không đúng';
      case 'email-already-in-use':
        return 'Email này đã được đăng ký';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hoá';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng';
      default:
        return error.message ?? 'Đã có lỗi xảy ra';
    }
  }
  if (error.toString().contains('Đăng nhập Google bị huỷ')) {
    return 'Đăng nhập Google bị huỷ';
  }
  return 'Đã có lỗi xảy ra. Vui lòng thử lại';
}
