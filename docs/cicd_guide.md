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

---

## 5. Hướng Dẫn Truy Vấn & Kiểm Tra Dữ Liệu Trên Firebase (Cloud Firestore)

Để kiểm tra xem dữ liệu từ thiết bị của bạn đã được đồng bộ lên Cloud Firestore đúng cấu trúc phân tách theo tài khoản (UID) hay chưa, bạn có thể thực hiện theo các cách sau:

### Cách 1: Sử dụng Giao diện Web (Firebase Console)
Đây là cách trực quan nhất để quản lý và kiểm tra dữ liệu:
1. Truy cập **[Firebase Console](https://console.firebase.google.com/)**.
2. Chọn dự án **`motolog-23f9f`**.
3. Tại menu bên trái, chọn **Build** $\rightarrow$ **Firestore Database**.
4. Bạn sẽ thấy cây dữ liệu dạng:
   - **Collection `users`**: Chứa danh sách các User Documents. Mỗi document được định danh bằng **Firebase UID** duy nhất (ví dụ: `d8K1JgslS...`).
   - Bên trong mỗi Document của User sẽ có:
     - Document chứa profile: `display_name`, `email`, `photo_url`.
     - **Sub-collection `vehicles`**: Chứa thông tin các xe của riêng tài khoản đó.
     - **Sub-collection `fuel_entries`**: Chứa các lần đổ xăng.
     - **Sub-collection `maintenance_entries`**: Chứa lịch sử bảo dưỡng.

---

### Cách 2: Sử dụng Firebase CLI (Lệnh Truy Vấn Trên Windows Terminal)
Bạn có thể cài đặt công cụ **Firebase CLI** để truy vấn trực tiếp từ PowerShell hoặc Command Prompt của Windows.

#### Điều kiện cần:
Cài đặt Firebase CLI qua Node.js (npm):
```bash
npm install -g firebase-tools
```
Đăng nhập vào tài khoản Firebase của bạn:
```bash
firebase login
```

#### Các lệnh kiểm tra dữ liệu:

1. **Lấy danh sách các tài khoản người dùng đã đồng bộ:**
   ```bash
   # Lấy danh sách tài liệu từ collection 'users' để xem các UID hiện có
   firebase firestore:get /users --project motolog-23f9f
   ```

2. **Kiểm tra thông tin chi tiết của một tài khoản cụ thể (theo UID):**
   Thay thế `UID_CỦA_USER` bằng mã UID thực tế bạn muốn kiểm tra:
   ```bash
   firebase firestore:get /users/UID_CỦA_USER --project motolog-23f9f
   ```

3. **Xem danh sách xe của một tài khoản cụ thể:**
   ```bash
   firebase firestore:get /users/UID_CỦA_USER/vehicles --project motolog-23f9f
   ```

4. **Xem danh sách nhật ký đổ xăng của một tài khoản:**
   ```bash
   firebase firestore:get /users/UID_CỦA_USER/fuel_entries --project motolog-23f9f
   ```

---

### Cách 3: Sử dụng Google Cloud CLI (gcloud)
Nếu bạn đã liên kết dự án với Google Cloud SDK, bạn có thể dùng công cụ `gcloud` để liệt kê dữ liệu:

1. **Đăng nhập Google Cloud:**
   ```bash
   gcloud auth login
   ```
2. **Thiết lập dự án hiện tại:**
   ```bash
   gcloud config set project motolog-23f9f
   ```
3. **Liệt kê danh sách các Document trong collection `users`:**
   ```bash
   gcloud firestore documents list --collection=users
   ```
4. **Liệt kê danh sách xe của một User (ví dụ UID là `UID_CỦA_USER`):**
   ```bash
   gcloud firestore documents list --collection=users/UID_CỦA_USER/vehicles
   ```
