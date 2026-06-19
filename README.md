# 🏍️ MotoLog — Nhật ký xe cá nhân

[![Build & Release iOS](https://github.com/TranhaidangIT/MotoLog_Mobile/actions/workflows/ios_build.yml/badge.svg)](https://github.com/TranhaidangIT/MotoLog_Mobile/actions/workflows/ios_build.yml)

**MotoLog** là ứng dụng di động được phát triển bằng Flutter giúp người dùng dễ dàng quản lý nhật ký bảo dưỡng, theo dõi chi phí đổ xăng, tính toán mức tiêu hao nhiên liệu và nhận các nhắc nhở bảo dưỡng xe máy/ô tô cá nhân một cách khoa học.

Dự án hỗ trợ đồng bộ dữ liệu hai chiều giữa cơ sở dữ liệu nội bộ SQLite và dịch vụ đám mây Cloud Firestore, giúp quản lý dữ liệu hiệu quả ngay cả khi ngoại tuyến.

---

## ✨ Tính năng chính

- 🔐 **Đăng nhập & Xác thực**: Hỗ trợ đăng nhập truyền thống bằng Email/Mật khẩu hoặc Đăng nhập nhanh bằng tài khoản Google (Firebase Auth).
- 🏍️ **Quản lý nhà xe (Garage)**: Thêm và theo dõi thông tin chi tiết nhiều xe cùng lúc (Tên xe, biển số, hãng sản xuất, năm sản xuất, ảnh đại diện...).
- ⛽ **Nhật ký đổ xăng**: Ghi nhận số km (odometer), số lít xăng, giá tiền. Tự động tính toán chi phí trung bình và tiêu thụ nhiên liệu.
- 🔧 **Lịch sử bảo dưỡng**: Lưu vết các mốc bảo dưỡng định kỳ, thay thế phụ tùng hoặc sửa chữa hư hỏng kèm theo hóa đơn/chi phí chi tiết.
- ⏰ **Nhắc nhở thông minh (Reminders)**: Tự động cảnh báo khi sắp đến mốc thay nhớt máy (mỗi 2.000 KM) hoặc vệ sinh nồi/bảo dưỡng hệ thống (mỗi 5.000 KM) dựa trên Odometer hiện tại và Lịch sử bảo dưỡng gần nhất.
- 📊 **Thống kê & Biểu đồ**:
  - Biểu đồ cột kép so sánh chi phí xăng và chi phí bảo dưỡng qua các tháng.
  - Bộ lọc linh hoạt theo 1 tháng, 3 tháng, 6 tháng và 1 năm.
  - Tự động tính toán phần trăm tăng/giảm chi tiêu trực quan so với kỳ trước.
- ☁️ **Đồng bộ hóa đám mây**: Tự động đồng bộ hóa lên Firebase Firestore khi thiết bị kết nối mạng, cho phép khôi phục dữ liệu tức thì khi chuyển sang thiết bị mới.

---

## 🛠 Công nghệ sử dụng

- **Core Framework**: Flutter (Dart) phiên bản 3.x
- **State Management**: Flutter Riverpod (Quản lý trạng thái ứng dụng sạch và hiệu quả)
- **Local Storage**: SQFlite (SQLite) lưu trữ offline tốc độ cao
- **Backend / Cloud**: Firebase (Auth, Cloud Firestore)
- **Routing**: GoRouter (Quản lý luồng chuyển màn hình mượt mà)
- **Charts**: fl_chart (Vẽ biểu đồ thống kê chuyên nghiệp)
- **Design system**: Google Fonts (Outfit), Cupertino & Material Icons.

---

## 📂 Cấu trúc thư mục

```text
lib/
├── core/             # Các hằng số màu sắc, cấu hình router, định dạng dữ liệu (Formatters), kiểm tra đầu vào (Validators).
├── data/
│   ├── local/        # Định nghĩa các bảng SQLite và lớp truy xuất dữ liệu (DAO).
│   ├── models/       # Các đối tượng mô hình dữ liệu (Vehicle, FuelEntry, MaintenanceEntry).
│   └── services/     # Dịch vụ đám mây FirestoreService quản lý đồng bộ.
├── providers/        # Các bộ quản lý trạng thái Riverpod (Auth, Vehicles, Fuel, Maintenance).
└── screens/          # Giao diện người dùng chia theo các module chức năng (Auth, Dashboard, Vehicle, Fuel, Maintenance, Statistics).
```

---

## 🚀 Chạy dự án cục bộ

### Điều kiện tiên quyết:
- Máy tính đã cài đặt **Flutter SDK** (Channel Stable).
- Có giả lập Android/iOS hoặc thiết bị thật kết nối qua chế độ Debug.

### Các bước thực hiện:
1. Tải dependencies của dự án:
   ```bash
   flutter pub get
   ```
2. Chạy ứng dụng trên thiết bị đang kết nối:
   ```bash
   flutter run
   ```
3. Chạy các kiểm thử tự động (Unit Tests) để xác minh nghiệp vụ xử lý:
   ```bash
   flutter test
   ```

---

## 📖 Tài liệu nội bộ hướng dẫn quy trình Build & Git
Xem chi tiết hướng dẫn vận hành, đẩy code lên GitHub, và kích hoạt build tự động ra file `.ipa` cho iOS tại:  
👉 **[Hướng dẫn vận hành & CI/CD](file:///d:/MotoLog_Mobile/docs/cicd_guide.md)**
