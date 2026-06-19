# Hướng Dẫn Vận Hành, Git & Quy Trình Tự Động Build iOS (CI/CD)

Tài liệu này hướng dẫn chi tiết cách chạy thử nghiệm cục bộ, đẩy mã nguồn lên GitHub và theo dõi hệ thống tự động build bản cài đặt iOS (.ipa) bằng GitHub Actions.

---

## 1. Phát Triển & Chạy Thử Nghiệm Cục Bộ

Để phát triển dự án trên máy tính Windows, sử dụng các lệnh tiêu chuẩn của Flutter:

### Lấy thư viện liên kết (Dependencies):
```bash
flutter pub get
```

### Chạy ứng dụng ở chế độ Debug:
```bash
flutter run
```
*Lưu ý: Do đang phát triển trên Windows, bạn chỉ có thể khởi chạy debug trên Thiết bị giả lập Android (Emulator), Trình duyệt Web hoặc ứng dụng Windows Desktop.*

### Chạy bộ kiểm thử tự động (Unit Tests):
Chúng ta đã viết sẵn bộ test case kiểm thử toàn bộ logic và định dạng nhập liệu của dự án. Hãy chạy lệnh sau trước khi push code để đảm bảo không phát sinh lỗi nghiệp vụ:
```bash
flutter test
```

---

## 2. Quy Trình Làm Việc Với Git & GitHub

Khi bạn có những thay đổi về giao diện (UI) hoặc mã nguồn trong thư mục `d:\MotoLog_Mobile`, hãy làm theo các bước sau để đẩy code lên kho lưu trữ GitHub:

### Bước 1: Xem các file thay đổi
```bash
git status
```

### Bước 2: Đưa các file thay đổi vào danh sách chờ commit
```bash
git add .
```

### Bước 3: Đóng gói các thay đổi (Commit)
Đặt tên mô tả ngắn gọn và ý nghĩa cho những gì bạn đã chỉnh sửa:
```bash
git commit -m "feat: cập nhật giao diện thống kê và sửa bộ lọc thời gian"
```

### Bước 4: Đẩy code lên GitHub
Nhánh chính của dự án hiện tại được đặt tên là `master`. Đẩy code lên bằng lệnh:
```bash
git push origin master
```

---

## 3. Hệ Thống Tự Động Build iOS (GitHub Actions CI/CD)

Vì môi trường Windows không hỗ trợ biên dịch trực tiếp ra ứng dụng iOS, chúng ta sử dụng hệ thống **GitHub Actions** để giải quyết giới hạn này.

### Cách thức hoạt động:
1. Mỗi khi bạn đẩy code lên nhánh `master` hoặc `main` (thông qua lệnh `git push`), GitHub sẽ tự động phát hiện và kích hoạt kịch bản build nằm trong file cấu hình `.github/workflows/ios_build.yml`.
2. GitHub sẽ mượn một **máy chủ macOS ảo** đám mây.
3. Máy ảo này tự động cài đặt Flutter SDK, tải mã nguồn dự án của bạn xuống và chạy lệnh:
   ```bash
   flutter build ios --release --no-codesign
   ```
4. Hệ thống sẽ đóng gói tệp thực thi `Runner.app` vào thư mục `Payload/` và nén lại thành tệp cài đặt định dạng **`MotoLog.ipa`** (unsigned).
5. Cuối cùng, tệp `.ipa` này sẽ được tự động đính kèm vào mục **Releases** trên GitHub dự án của bạn dưới thẻ tag phiên bản tương ứng với số thứ tự lần build (ví dụ: `build-6`).

---

## 4. Hướng Dẫn Tải & Cài Đặt File `.ipa` Lên iPhone

Sau khi GitHub Actions báo biên dịch thành công (hiển thị tích xanh lá cây ✅ trong mục **Actions**):

1. **Tải file `.ipa`**:
   - Truy cập trang GitHub của bạn tại: **[GitHub Releases - MotoLog Mobile](https://github.com/TranhaidangIT/MotoLog_Mobile/releases)**.
   - Nhấp vào bản phát hành mới nhất và tải xuống tệp có đuôi `.ipa` (ví dụ: `MotoLog.ipa`).
2. **Cài đặt bằng Sideloadly** (Miễn phí trên Windows):
   - Tải và cài đặt phần mềm **[Sideloadly](https://sideloadly.io/)** trên máy tính Windows của bạn.
   - Kết nối iPhone với máy tính bằng cáp USB. Mở khóa màn hình điện thoại và bấm **"Tin cậy máy tính này"** (Trust this computer) nếu được hỏi, sau đó nhập mật khẩu màn hình iPhone.
   - Mở phần mềm Sideloadly lên. Thiết bị iPhone của bạn sẽ xuất hiện trong ô **"Device"**.
   - Kéo tệp `MotoLog.ipa` đã tải ở bước 1 thả vào ô **"IPA"** trên Sideloadly.
   - Nhập **Apple ID** (Email tài khoản iCloud thường của bạn, không yêu cầu tài khoản Developer trả phí) vào ô **"Apple Account"**.
   - Bấm nút **"Start"**. Nhập mật khẩu Apple ID của bạn khi được Sideloadly yêu cầu (đây là quy trình xác thực cục bộ trực tiếp với máy chủ Apple để ký chứng chỉ nhà phát triển cá nhân có hạn dùng 7 ngày).
3. **Cấp quyền chạy trên iPhone**:
   - Sau khi phần mềm báo **"Done"**, biểu tượng ứng dụng **MotoLog** sẽ xuất hiện trên màn hình iPhone nhưng chưa mở được.
   - Trên iPhone, bạn vào: **Cài đặt (Settings)** $\rightarrow$ **Cài đặt chung (General)** $\rightarrow$ **Quản lý VPN & Thiết bị (VPN & Device Management)**.
   - Dưới mục *Ứng dụng nhà phát triển (Developer App)*, bấm vào địa chỉ Email Apple ID của bạn.
   - Bấm chọn **"Tin cậy [Email của bạn]"** (Trust) và xác nhận.
   - Quay lại màn hình chính và mở ứng dụng **MotoLog** lên sử dụng bình thường!
