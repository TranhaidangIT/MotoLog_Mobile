# Kế Hoạch Sửa Lỗi: Đăng Nhập Google, Chụp Ảnh & Phân Tách Dữ Liệu Tài Khoản (iOS)

Tài liệu này lưu trữ kế hoạch giải quyết các lỗi trên môi trường iOS để triển khai sau khi hoàn tất các đợt kiểm thử kịch bản.

---

## Các vấn đề cần giải quyết:

### 1. Lỗi Google Sign-In trên iOS
- **Sự cố**: Đăng nhập bằng Google trên iPhone không phản hồi hoặc báo lỗi.
- **Nguyên nhân**: File `GoogleService-Info.plist` chưa được thêm vào Build Phases của Xcode dự án (thiếu tham chiếu trong `project.pbxproj`) và thiếu cấu hình tham số `clientId` cho iOS trong mã nguồn Dart.
- **Giải pháp**:
  - Chèn cấu hình tham chiếu `GoogleService-Info.plist` vào các phần `PBXBuildFile`, `PBXFileReference`, `PBXGroup`, `PBXResourcesBuildPhase` trong file [project.pbxproj](file:///d:/MotoLog_Mobile/ios/Runner.xcodeproj/project.pbxproj).
  - Cập nhật hàm `signInWithGoogle()` và `signOut()` trong [auth_provider.dart](file:///d:/MotoLog_Mobile/lib/providers/auth_provider.dart) để khởi tạo `GoogleSignIn(clientId: DefaultFirebaseOptions.ios.iosClientId)` dành riêng cho iOS.

### 2. Lỗi Quyền Truy Cập Camera & Photo Library
- **Sự cố**: App bị crash ngay lập tức khi người dùng bấm vào nút chụp ảnh xe hoặc hóa đơn trên iOS.
- **Nguyên nhân**: Thiếu khai báo giải trình mục đích sử dụng phần cứng trong file cấu hình quyền của iOS.
- **Giải pháp**: Thêm các dòng cấu hình sau vào file [Info.plist](file:///d:/MotoLog_Mobile/ios/Runner/Info.plist):
  ```xml
  <key>NSCameraUsageDescription</key>
  <string>Ứng dụng cần truy cập máy ảnh để chụp ảnh xe của bạn.</string>
  <key>NSPhotoLibraryUsageDescription</key>
  <string>Ứng dụng cần truy cập thư viện ảnh để chọn ảnh xe từ thiết bị.</string>
  <key>NSMicrophoneUsageDescription</key>
  <string>Ứng dụng cần truy cập micrô nếu bạn quay video.</string>
  ```

### 3. Lỗi Trùng Lặp Dữ Liệu Khi Đăng Xuất (SQLite Cache)
- **Sự cố**: Đăng xuất tài khoản này và đăng nhập tài khoản khác vẫn nhìn thấy dữ liệu (xe, xăng, bảo dưỡng) của tài khoản trước đó.
- **Nguyên nhân**: Hàm `signOut()` mới chỉ đăng xuất phiên làm việc của Firebase Auth chứ chưa xóa sạch cơ sở dữ liệu SQLite local và `SharedPreferences` lưu ID xe được chọn.
- **Giải pháp**:
  - Cập nhật hàm `signOut()` gọi:
    ```dart
    await ref.read(selectedVehicleIdProvider.notifier).select(null);
    await DatabaseHelper.instance.clearAll();
    ```
  - Lọc truy vấn xe theo `userId` thực tế trong `vehicleListProvider` và `VehicleNotifier` ở [vehicle_provider.dart](file:///d:/MotoLog_Mobile/lib/providers/vehicle_provider.dart) để tránh việc SQLite load chung toàn bộ xe.

### 4. Lỗi Trùng Lập / Không Tách Biệt Khi Đăng Nhập 2 Tài Khoản Google Cùng Tên
- **Sự cố**: Đăng nhập tài khoản Google khác nhưng có cùng tên hiển thị thì ứng dụng vẫn dùng chung và hiển thị dữ liệu của tài khoản đăng nhập trước đó.
- **Nguyên nhân**:
  - Ngoài việc SQLite chưa được dọn dẹp (Lỗi số 3), có thể hệ thống đang lưu và đối chiếu dữ liệu dựa vào tên hiển thị (`displayName`) hoặc bộ nhớ cache đăng nhập của Google SDK (`GoogleSignIn().signIn()`) chưa thực hiện `signOut()` triệt để, dẫn đến việc lấy lại Token cũ.
- **Giải pháp**:
  - **Khóa duy nhất theo UID**: Đảm bảo tất cả cấu trúc dữ liệu lưu trữ local (SQLite, SharedPreferences) và Cloud (Firestore) phải được ánh xạ, lọc và ghi nhận theo **Firebase User UID (`user.uid`)** - đây là chuỗi ký tự định danh duy nhất và không bao giờ trùng lặp giữa các tài khoản Google, bất kể chúng có cùng tên hiển thị hay dùng chung thiết bị.
  - **Đăng xuất Google SDK triệt để**: Kiểm tra và bắt buộc khối lệnh `signOut()` phải hoàn tất việc giải phóng phiên đăng nhập của Google SDK trước khi gọi lệnh của Firebase Auth.
