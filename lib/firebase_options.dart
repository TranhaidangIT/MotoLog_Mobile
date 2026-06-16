// File này được tạo từ google-services.json
// DO NOT edit manually nếu không cần thiết

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Firebase configuration options cho từng platform
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platform chưa được cấu hình. '
        'Hãy chạy flutterfire configure để thêm Web support.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS chưa được cấu hình. Hãy thêm GoogleService-Info.plist.',
        );
      default:
        throw UnsupportedError(
          'Platform $defaultTargetPlatform chưa được hỗ trợ.',
        );
    }
  }

  // ─── Android (lấy từ google-services.json) ──────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVERAmMkWCwxvoPQaes9smIffsjX1yoK0',
    appId: '1:430239783730:android:1281e72c9366246d29d52b',
    messagingSenderId: '430239783730',
    projectId: 'motolog-23f9f',
    storageBucket: 'motolog-23f9f.firebasestorage.app',
  );
}
