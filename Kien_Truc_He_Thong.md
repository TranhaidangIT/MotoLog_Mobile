# TỔNG QUAN KIẾN TRÚC & CÔNG NGHỆ (TECH STACK) HIỆN TẠI CỦA MOTO LOG

Tài liệu này tổng hợp toàn bộ công nghệ, thư viện và luồng hoạt động thực tế đang chạy dưới nền của ứng dụng MotoLog để bạn nắm rõ toàn bộ hệ thống.

---

## 1. Nền tảng Core (Giao diện & Logic)
- **Framework:** Flutter (Ngôn ngữ lập trình Dart).
- **State Management (Quản lý trạng thái):** `flutter_riverpod`
  - Đã loại bỏ hoàn toàn `Provider` cũ kỹ và `StatefulWidget` thuần để chuyển sang Riverpod hiện đại.
  - Giúp ứng dụng mượt mà hơn, tách biệt hoàn toàn Giao diện (UI) và Logic xử lý (Business Logic). Dữ liệu tự động cập nhật lên màn hình ngay khi Database thay đổi.
- **Điều hướng màn hình (Routing):** `go_router`
  - Sử dụng kiến trúc định tuyến nâng cao thay vì `Navigator.push` thông thường. Dễ dàng kiểm tra trạng thái Đăng nhập để chặn người dùng (Redirection).

---

## 2. Mô hình Lưu trữ Dữ liệu (Database Architecture)
Hệ thống sử dụng kiến trúc **Offline-First**, kết hợp sức mạnh của cả SQL và NoSQL.

### A. Tầng Local (Dữ liệu chính - Nhanh, Không cần mạng)
- **Công nghệ:** SQLite (thông qua package `sqflite`).
- **Phân loại:** Cơ sở dữ liệu Quan hệ (SQL).
- **Chi tiết:**
  - Mọi thao tác Thêm, Sửa, Xóa của người dùng đều ghi thẳng vào SQLite trước tiên để đảm bảo tốc độ phản hồi 0.1 giây (không độ trễ).
  - Gồm 5 bảng chính có liên kết Khóa ngoại (Foreign Key) chặt chẽ với nhau: `vehicles`, `fuel_entries`, `maintenance_entries`, `maintenance_items`, `custom_reminders`.

### B. Tầng Cloud (Lưu trữ, Backup & Đồng bộ)
- **Công nghệ:** Hệ sinh thái Firebase.
- **Phân loại:** Cơ sở dữ liệu Không quan hệ (NoSQL) và Object Storage.
- **Chi tiết luồng hoạt động:**
  1. **Firebase Auth:** Dùng để xác thực người dùng. Mỗi user khi đăng nhập sẽ được cấp 1 `UID` duy nhất.
  2. **Firebase Cloud Firestore (NoSQL):** Bất cứ khi nào app có Internet, một Service ngầm sẽ tự động "hút" dữ liệu chữ (Text) từ SQLite và đẩy lên Firestore theo dạng `Collection -> Document`. Cấu trúc được gom nhóm dưới `UID` của người dùng để bảo mật.
  3. **Firebase Storage:** Mỗi khi người dùng up ảnh (Avatar xe, hình đăng kiểm, hóa đơn thay nhớt), file ảnh nặng sẽ được nén lại và tải lên Storage. Storage trả về một đường link `URL`, link này được lưu ngược lại vào SQLite và Firestore để hiển thị.

---

## 3. Các Dịch vụ & API Nâng cao đã tích hợp

Để biến MotoLog thành một ứng dụng thương mại thực thụ, hệ thống đã nhúng thêm các công nghệ sau:

- **Định vị GPS & Reverse Geocoding:** 
  - Kết hợp package `geolocator` và gọi REST API của bên thứ 3 là `Nominatim OpenStreetMap` (miễn phí, thay thế cho Google Maps API tốn tiền).
  - Nhiệm vụ: Tự động lấy tọa độ GPS hiện tại và dịch ra văn bản Địa chỉ để điền vào Tên cây xăng.
  
- **Thông báo Local (Push Notification):**
  - Sử dụng package `flutter_local_notifications`.
  - Nhiệm vụ: Chạy ngầm để soi số KM (ODO) hiện tại. Nếu sắp tới hạn thay nhớt, hệ thống sẽ gọi API của Hệ điều hành (Android/iOS) để rung điện thoại và rớt thông báo xuống màn hình khóa.

- **Export Report (Xuất báo cáo):**
  - Sử dụng package `csv` và `flutter_email_sender`.
  - Nhiệm vụ: Quét toàn bộ Database SQLite, gom dữ liệu xăng cộ và bảo dưỡng lại, nối thành chuỗi tạo ra file Excel `.csv`. Sau đó gọi App Mail có sẵn trong máy để đính kèm file gửi đi.

- **Tối ưu hình ảnh (UX/UI):**
  - Dùng `image_picker` để gọi Camera/Thư viện ảnh Native.
  - Dùng `cached_network_image` để lưu đệm các hình ảnh từ Firebase tải về, giúp lần sau mở app không bị lag và không tốn dung lượng 4G load lại ảnh.
  - Dùng `lottie` để render các hoạt hình vector (Loading, Success) siêu nhẹ.

---

## 4. Design Pattern (Mẫu thiết kế Code)
- **DAO Pattern (Data Access Object):** Tách biệt các file chọc thẳng vào SQLite ra các class riêng (`VehicleDao`, `FuelDao`,...). Các màn hình UI cấm không được viết câu lệnh SQL mà phải gọi qua DAO.
- **Service Pattern:** Tách các luồng gọi API và Firebase ra các file Service riêng (`FirestoreService`, `LocationService`) để dễ dàng bảo trì và tái sử dụng code.
