# BÁO CÁO KỸ THUẬT
## MotoLog — Ứng dụng Nhật Ký Phương Tiện Cá Nhân

**Môn học:** Lập Trình Di Động Đa Nền Tảng (Flutter)  
**Sinh viên:** [Họ và tên]  
**MSSV:** [Mã số sinh viên]  
**Lớp:** [Tên lớp]  
**Giảng viên hướng dẫn:** [Tên giảng viên]  
**Ngày nộp:** [DD/MM/YYYY]

---

## Mục lục

1. Mô tả ý tưởng và Sơ đồ luồng ứng dụng
2. Bảng liệt kê các chức năng đã hoàn thành
3. Mô hình CSDL & Ràng buộc Dữ liệu
4. Mô tả kỹ thuật nâng cao đã tự nghiên cứu

---

## 1. Mô tả ý tưởng và Sơ đồ luồng ứng dụng

### 1.1 Ý tưởng & Bài toán thực tế

MotoLog giải quyết 3 vấn đề thực tế của người dùng xe máy tại Việt Nam:

- **Quên lịch bảo dưỡng:** Người dùng không biết khi nào cần thay nhớt, bugi, lọc gió — dẫn đến hỏng xe, tốn chi phí sửa chữa lớn hơn.
- **Không theo dõi chi phí:** Không biết mình tiêu bao nhiêu tiền xăng, bảo dưỡng mỗi tháng, không có cơ sở để tiết kiệm.
- **Mất giấy tờ xe:** Ảnh đăng ký, đăng kiểm, bảo hiểm dễ thất lạc hoặc hư hỏng.

**Giải pháp:** MotoLog số hóa toàn bộ "vòng đời" của xe thành một nhật ký trên điện thoại — tự động tính mức tiêu hao nhiên liệu, cảnh báo bảo dưỡng theo km thực tế, lưu ảnh giấy tờ lên Cloud.

**Đối tượng người dùng:** Người đi xe máy phổ thông tại Việt Nam (xe số và xe tay ga).

**Nền tảng:** Flutter (Android + iOS), Firebase (Auth · Firestore · Storage), SQLite (local).

---

### 1.2 Sơ đồ luồng ứng dụng (Workflow)

> **[CHÈN ẢNH CHỤP SƠ ĐỒ WORKFLOW TẠI ĐÂY]**  
> *(Chụp màn hình sơ đồ Workflow từ file Bao_Cao_Du_An.md xuất ra PNG và chèn vào đây)*

**Mô tả luồng chính:**

text
Mở app → Splash Screen → Kiểm tra Firebase Auth
    │
    ├─ Chưa đăng nhập → Màn hình Giới thiệu (Onboarding) → Đăng nhập / Đăng ký
    │       └─ Xác thực thành công → Trang chủ
    │
    └─ Đã đăng nhập → Trang chủ (Dashboard)
            │
            ├─ Chưa có xe → Thêm xe mới → Trang chủ
            │
            └─ Đã có xe → 4 luồng chính:
                    ├─ Đổ xăng: Tự lấy địa chỉ GPS → Nhập lít/ODO → Tính tiêu hao
                    ├─ Bảo dưỡng & Phụ tùng: Ghi nhận sửa chữa → Up ảnh hóa đơn
                    ├─ Nhắc lịch: Tính ODO tới hạn / Ngày tới hạn → Nhắc nhở
                    └─ Thống kê: Tính tổng chi phí Xăng + Bảo dưỡng theo tháng


---

### 1.3 Sơ đồ điều hướng màn hình (Navigation Map)

Ứng dụng sử dụng go_router với các màn hình chính được điều hướng qua BottonNavigationBar và các luồng chức năng phụ:

| Tab chính | Màn hình con liên quan | Chức năng |
|-----|---------------|--------------|
| Trang chủ (Home) | FuelLogScreen, AddMaintenanceScreen | Hiển thị tóm tắt, biểu đồ mini, nút thêm nhanh. |
| Lịch sử Xăng | FuelHistoryScreen | Danh sách các lần đổ xăng. |
| Bảo dưỡng | MaintenanceScreen, PartsScreen | Quản lý lịch sử sửa chữa, thay phụ tùng. |
| Nhắc lịch | ReminderScreen | Quản lý các mốc bảo dưỡng định kỳ và lịch hẹn tự tạo. |
| Cá nhân | GarageScreen, ProfileScreen, ExportDataScreen | Quản lý danh sách xe, cấu hình app và xuất file CSV. |

---

### 1.4 Sơ đồ luồng dữ liệu (Data Flow)

> **[CHÈN ẢNH SƠ ĐỒ DATA FLOW TẠI ĐÂY]**  
> *(Sử dụng file So_Do_Data_Flow.png đã được xuất sẵn trong thư mục máy tính)*

**Nguyên tắc:** SQLite là nguồn dữ liệu chính (Offline-first đảm bảo tốc độ cao), Firebase đóng vai trò là lớp Sync và Backup 2 chiều ngầm.

---

## 2. Bảng liệt kê các chức năng đã hoàn thành

| STT | Chức năng | Mô tả chi tiết | Màn hình | Trạng thái |
|-----|-----------|---------------|----------|------------|
| 1 | Đăng nhập / Đăng ký | Email+Password và Google OAuth qua Firebase Auth | LoginScreen · RegisterScreen | ✅ Hoàn thành |
| 2 | Onboarding | Giới thiệu app lần đầu với animation Lottie | OnboardingScreen | ✅ Hoàn thành |
| 3 | Quản lý Garage Xe | Thêm/sửa/xóa nhiều xe cùng lúc. Upload Avatar xe. | GarageScreen · AddEditVehicleScreen | ✅ Hoàn thành |
| 4 | Cài đặt Xe nhanh | Chọn hãng/dòng xe có sẵn từ catalog để điền nhanh thông số | QuickSetupVehicleScreen | ✅ Hoàn thành |
| 5 | Nhật ký đổ xăng | Tự lấy địa chỉ từ GPS, tự tính mức tiêu hao L/100km | FuelLogScreen | ✅ Hoàn thành |
| 6 | Lịch sử đổ xăng | Danh sách chi tiết các lần đổ, phân loại theo xe | FuelHistoryScreen | ✅ Hoàn thành |
| 7 | Quản lý Bảo dưỡng & Phụ tùng | Ghi nhận thay nhớt/sửa chữa. Lưu hình ảnh hóa đơn/phụ tùng | MaintenanceScreen · AddMaintenanceScreen | ✅ Hoàn thành |
| 8 | Cài đặt Mốc Nhắc Lịch | Thiết lập chu kỳ ODO (VD: 2000km thay nhớt) để app theo dõi | ReminderScreen | ✅ Hoàn thành |
| 9 | Lời nhắc Tùy chỉnh | Thêm nhắc hẹn theo Ngày (VD: Ngày gia hạn bảo hiểm) | ReminderScreen | ✅ Hoàn thành |
| 10 | Push notification | Bắn thông báo Local nhắc lịch bảo dưỡng khi sắp đến hạn | NotificationService | ✅ Hoàn thành |
| 11 | Thống kê chi phí | Biểu đồ trực quan (fl_chart) chi phí xăng và sửa chữa theo tháng | StatisticsScreen | ✅ Hoàn thành |
| 12 | Quản lý Giấy tờ xe | Chụp và lưu trữ hình Cà vẹt, Đăng kiểm, Bảo hiểm lên Cloud | MyVehicleScreen | ✅ Hoàn thành |
| 13 | Xuất dữ liệu CSV | Trích xuất toàn bộ dữ liệu ra Excel và gửi qua App Mail | ExportDataScreen | ✅ Hoàn thành |
| 14 | Đồng bộ Firebase | Sync 2 chiều (Cloud Firestore) ngầm khi có mạng | FirestoreService | ✅ Hoàn thành |
| 15 | Tùy chỉnh Giao diện / Ngôn ngữ | Đổi giao diện Dark/Light mode, đổi ngôn ngữ, đơn vị KM/Miles | ProfileScreen | ✅ Hoàn thành |

---

## 3. Mô hình CSDL & Ràng buộc Dữ liệu (Constraints)

### 3.1 Tổng quan kiến trúc lưu trữ

Ứng dụng dùng chiến lược **Offline-First**:
- **SQLite** = Cơ sở dữ liệu Quan hệ chính. Tốc độ cao, truy vấn Join mạnh mẽ, dùng offline.
- **Firebase Firestore** = Database NoSQL, làm kho lưu trữ đám mây đồng bộ 2 chiều (Auto-sync).
- **Firebase Storage** = Lưu trữ file vật lý (Hình avatar, hóa đơn, giấy tờ xe) trả về URL.

### 3.2 Schema SQLite và Ràng buộc (Constraints)

> **[CHÈN ERD DIAGRAM TẠI ĐÂY]**  
> *(Sử dụng file So_Do_CSDL.png đã được xuất sẵn trong thư mục máy tính)*

Dưới đây là chi tiết 5 bảng thực tế kèm theo các ràng buộc (Constraints) quan trọng:

**Bảng 1: vehicles (Thông tin Xe)**
| Cột | Kiểu | Ràng buộc (Constraints) / Mô tả |
|-----|------|-------|
| id | TEXT | **PRIMARY KEY**. Định danh UUID duy nhất. |
| user_id | TEXT | Không NULL. Link tới Firebase Auth UID. |
| name | TEXT | **NOT NULL**. Tên hiển thị của xe. |
| brand | TEXT | **NOT NULL**. Hãng xe. |
| model | TEXT | **NOT NULL**. Dòng xe. |
| plate_number | TEXT | **NOT NULL**. Biển số xe. |
| odometer | REAL | **NOT NULL DEFAULT 0**. Chỉ số KM hiện tại. |
| created_at | TEXT | **NOT NULL**. Thời điểm tạo. |
| is_synced | INTEGER | **DEFAULT 1**. Đánh dấu đồng bộ Cloud. |

**Bảng 2: fuel_entries (Lịch sử Đổ Xăng)**
| Cột | Kiểu | Ràng buộc (Constraints) / Mô tả |
|-----|------|-------|
| id | TEXT | **PRIMARY KEY**. UUID. |
| vehicle_id | TEXT | **FOREIGN KEY** REFERENCES vehicles(id) **ON DELETE CASCADE**. Xóa xe thì tự động xóa xăng. |
| date | TEXT | **NOT NULL**. Ngày đổ xăng. |
| liters | REAL | **NOT NULL**. Lượng xăng đổ. |
| total_cost | REAL | **NOT NULL**. Số tiền thanh toán. |
| price_per_liter | REAL | **NOT NULL**. Giá tiền / Lít. |
| odometer | REAL | **NOT NULL**. Số ODO lúc đổ. (Ràng buộc logic: Phải lớn hơn ODO lần trước). |
| station_address | TEXT | Địa chỉ cây xăng tự động quét. |
| is_synced | INTEGER | **DEFAULT 1**. |

**Bảng 3: maintenance_entries (Lịch sử Bảo dưỡng & Phụ tùng)**
| Cột | Kiểu | Ràng buộc (Constraints) / Mô tả |
|-----|------|-------|
| id | TEXT | **PRIMARY KEY**. UUID. |
| vehicle_id | TEXT | **FOREIGN KEY** REFERENCES vehicles(id) **ON DELETE CASCADE**. |
| type | TEXT | **NOT NULL DEFAULT 'ROUTINE'**. Phân loại Bảo dưỡng hoặc Phụ tùng. |
| title | TEXT | **NOT NULL**. Tên hạng mục làm. |
| date | TEXT | **NOT NULL**. Ngày thực hiện. |
| odometer | REAL | **NOT NULL**. Số KM lúc thực hiện. |
| cost | REAL | **NOT NULL DEFAULT 0**. Chi phí thay thế. |
| image_path | TEXT | Đường dẫn ảnh hóa đơn/phụ tùng (Firebase Storage URL). |

**Bảng 4: maintenance_items (Mốc Nhắc Định Kỳ)**
| Cột | Kiểu | Ràng buộc (Constraints) / Mô tả |
|-----|------|-------|
| id | TEXT | **PRIMARY KEY**. UUID. |
| vehicle_id | TEXT | **FOREIGN KEY** REFERENCES vehicles(id) **ON DELETE CASCADE**. |
| name | TEXT | **NOT NULL**. Tên mốc nhắc nhở. |
| interval_km | INTEGER | **NOT NULL**. Số KM chu kỳ (VD: Nhắc mỗi 2000km). |
| last_done_odo | INTEGER | **NOT NULL DEFAULT 0**. Số KM lần gần nhất thực hiện. |
| is_reminder_on| INTEGER | **NOT NULL DEFAULT 1**. Trạng thái bật/tắt nhắc nhở (1/0). |

**Bảng 5: custom_reminders (Nhắc nhở Tùy chỉnh)**
| Cột | Kiểu | Ràng buộc (Constraints) / Mô tả |
|-----|------|-------|
| id | TEXT | **PRIMARY KEY**. UUID. |
| vehicle_id | TEXT | **FOREIGN KEY** REFERENCES vehicles(id) **ON DELETE CASCADE**. |
| title | TEXT | **NOT NULL**. Tiêu đề lời nhắc (VD: Ngày mua bảo hiểm). |
| type | TEXT | **NOT NULL**. Phân loại nhóm. |

### 3.3 Cấu trúc Firebase Firestore (NoSQL)

Firestore đóng vai trò lớp Backup & Sync 2 chiều. Dữ liệu được tổ chức theo mô hình phân cấp Collection → Document → Sub-collection, đảm bảo mỗi người dùng chỉ đọc/ghi được dữ liệu dưới uid của mình.

[CHÈN ẢNH So_Do_NoSQL_Firestore.png TẠI ĐÂY]

Cây phân cấp:

users/ (Collection gốc)
└── {uid}/ (Document của từng người dùng — lưu: uid, email, display_name, photo_url, updated_at)
      ├── vehicles/ (Sub-collection: Danh sách xe)
      │     └── {vehicleId} (1 Document = 1 chiếc xe)
      ├── fuel_entries/ (Sub-collection: Nhật ký đổ xăng)
      │     └── {entryId} (1 Document = 1 lần đổ xăng)
      └── maintenance_entries/ (Sub-collection: Bảo dưỡng & Phụ tùng)
            └── {entryId} (1 Document = 1 lần sửa chữa/thay thế)

Chi tiết Document vehicles/{vehicleId}:
id, name, brand, model, plate_number, year, odometer, fuel_type, image_url, color, engine_capacity, inspection_date, insurance_date, registration_image_url, inspection_image_url, insurance_image_url, user_id, created_at, updated_at.

Chi tiết Document fuel_entries/{entryId}:
id, vehicle_id, date, odometer, liters, price_per_liter, total_cost, station_name, station_address, station_lat, station_lon, fuel_type, is_full, note, created_at.

Chi tiết Document maintenance_entries/{entryId}:
id, vehicle_id, type (ROUTINE / REPAIR / PARTS), title, date, odometer, cost, garage_name, next_date, next_due_km, note, image_path, before_image_url, after_image_url, created_at.

Lưu ý: Khác với SQLite có FOREIGN KEY ràng buộc cứng, Firestore là NoSQL không có Cascade Delete tự động. Khi người dùng xóa xe, ứng dụng thực hiện Batch Delete — xóa đồng loạt toàn bộ fuel_entries và maintenance_entries có vehicle_id tương ứng trong cùng 1 transaction để đảm bảo tính nhất quán dữ liệu.

Lưu ý: Cột is_synced không được đẩy lên Firestore. Đây là cột nội bộ chỉ dùng trong SQLite để đánh dấu trạng thái đồng bộ, giúp Service phát hiện các bản ghi chưa được Push lên Cloud.






---

## 4. Mô tả kỹ thuật nâng cao đã tự nghiên cứu

### 4.1 Hệ sinh thái Firebase (Firebase Ecosystem)

**Firebase Authentication**
Tích hợp phương thức đăng nhập: Email/Password và Google Sign-In (OAuth 2.0). Sau khi xác thực, user.uid được dùng làm khóa để tạo Database độc lập trên Firestore cho riêng từng người dùng, ngăn chặn tuyệt đối việc xâm nhập chéo dữ liệu.

**Firebase Cloud Firestore — Đồng bộ 2 chiều (Background Sync)**
Hoạt động bằng nguyên lý Queue (hàng đợi). Dữ liệu khi nhập sẽ đánh cờ is_synced = 0 vào SQLite. Một Background Service sẽ lắng nghe trạng thái Internet để Push các bản ghi này lên Firestore và cập nhật cờ thành 1. Giúp người dùng chuyển điện thoại, gỡ cài đặt app sẽ không bao giờ mất dữ liệu.

**Firebase Storage — Upload và tối ưu hiển thị**
Chống phình to dung lượng Database bằng cách tách riêng biệt tải ảnh (Cà vẹt, Hóa đơn, Avatar) lên Firebase Storage. Lấy Link URL trả về và lưu bộ đệm bằng CachedNetworkImage giúp ứng dụng nhẹ, mượt và tiết kiệm băng thông 4G khi cuộn danh sách.

---

### 4.2 Dịch vụ định vị và Reverse Geocoding (Lấy địa chỉ tự động)

**Tự động lấy địa chỉ chính xác qua GPS:**
Thay vì dùng API trả phí của Google, ứng dụng tích hợp REST API mã nguồn mở của hệ thống bản đồ Nominatim OpenStreetMap thông qua thư viện http.
1. Gọi module geolocator xin quyền cấp phát Location và lấy chính xác Vĩ độ/Kinh độ (Lat/Lon).
2. Xử lý Timeout chống đứng máy ảo bằng thuật toán Fallback location.
3. Bắn HTTP GET Request đến Nominatim để dịch ngược tọa độ không gian thành dạng Địa chỉ Chữ (Đường, Phường, Thành phố).
4. Tự động điền dữ liệu vào Form nhập xăng thay cho việc gõ tay.

text
GET https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat={lat}&lon={lon}
Headers: User-Agent = MotoLog_Mobile_App_Student_Project


---

### 4.3 Quản lý trạng thái nâng cao (State Management)

**Sử dụng Riverpod thay thế Provider:**
Chuyển đổi hoàn toàn kiến trúc của dự án sang mô hình flutter_riverpod và AsyncNotifier thế hệ mới giúp:
- Tách biệt UI (Giao diện) ra khỏi Logic tính toán.
- Dependency Injection: Bắn dữ liệu xuyên thủng qua nhiều tầng màn hình mà không cần truyền tham số (như dữ liệu ODO hay Xăng cộ).
- Cập nhật Tức thời (Reactive): Màn hình bảo dưỡng và màn hình Thống kê cùng "Lắng nghe" (watch) 1 luồng dữ liệu duy nhất (Single Source of Truth). Dữ liệu thay đổi ở Database, lập tức mọi màn hình liên quan tự vẽ (Render) lại ngay lập tức.

---

### 4.4 Trải nghiệm người dùng nâng cao (High-end UX/UI)

**1. Slivers & CustomScrollView:** Trang chủ ứng dụng được phá bỏ ListView truyền thống, áp dụng hiệu ứng cuộn mượt mà cấp hệ thống của Slivers với Navbar có khả năng thu nhỏ phóng to theo thao tác ngón tay.
**2. Lottie Animations:** Trải nghiệm Onboarding (Giới thiệu) được nhúng các hoạt ảnh Vector định dạng JSON siêu nhẹ, đem lại trải nghiệm sinh động tương đương các ứng dụng thương mại.
**3. Trích xuất Dữ liệu Offline (CSV) & Email:** Xây dựng tính năng Trích xuất dữ liệu, tự động quét mảng dữ liệu SQLite, nối chuỗi thành bảng tính .csv (đọc được bằng Excel) và gọi Protocol của hệ điều hành để đẩy thẳng file báo cáo đính kèm qua ứng dụng Gmail/Mail của người dùng.