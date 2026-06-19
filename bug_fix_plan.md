# Kế Hoạch Sửa Lỗi: Đăng Nhập Google, Chụp Ảnh & Trùng Lặp Dữ Liệu Tài Khoản (iOS)

Tài liệu này lưu trữ kế hoạch giải quyết các lỗi trên iOS để thực hiện sau khi hoàn thành chạy các test case.

## Các vấn đề cần giải quyết:
1. **Lỗi Google Sign-In**: Đưa `GoogleService-Info.plist` vào build phase trong `project.pbxproj` và thêm `clientId` trên iOS trong `auth_provider.dart`.
2. **Lỗi Camera/Photo**: Thêm các khóa quyền trong `Info.plist`:
   - `NSCameraUsageDescription`
   - `NSPhotoLibraryUsageDescription`
   - `NSMicrophoneUsageDescription`
3. **Lỗi Trùng Lặp Dữ Liệu**:
   - Gọi `clearAll()` SQLite DB và reset selected vehicle khi `signOut()`.
   - Lọc xe theo `userId` trong `vehicle_provider.dart`.
