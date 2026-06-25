# TỪ ĐIỂN DỮ LIỆU (DATA DICTIONARY) CHUẨN XÁC NHẤT

Dưới đây là cấu trúc các bảng thực tế đang chạy trong mã nguồn hiện tại (File `database_helper.dart`). Cấu trúc cũ của bạn (có `part_records`, `maintenance_history`) đã lỗi thời và được loại bỏ để tối ưu.

---

### Bảng 1: `vehicles` (Quản lý xe)
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | TEXT (PK) | UUID tự sinh duy nhất cho mỗi xe. |
| `name` | TEXT | Tên xe (VD: "Wave Alpha đi làm"). |
| `brand` | TEXT | Hãng xe (Honda, Yamaha, Toyota...). |
| `model` | TEXT | Dòng xe. |
| `plate_number` | TEXT | Biển số xe. |
| `year` | INTEGER | Năm sản xuất/mua. |
| `odometer` | REAL | Số KM (ODO) hiện tại. |
| `fuel_type` | TEXT | Loại nhiên liệu (Xăng, Dầu, Điện...). |
| `color` | TEXT | Mã màu Hex của xe. |
| `engine_capacity`| TEXT | Dung tích xi-lanh (110cc, 150cc...). |
| `registration_image_url` | TEXT | Link ảnh Cà vẹt (Đã up lên Firebase Storage). |
| `inspection_image_url` | TEXT | Link ảnh Đăng kiểm (Nếu là ô tô). |
| `insurance_image_url`| TEXT | Link ảnh Bảo hiểm. |
| `user_id` | TEXT | Firebase UID của chủ xe. |
| `cached_image_url` | TEXT | Đường dẫn lưu đệm ảnh Avatar xe. |
| `is_synced` | INTEGER | Trạng thái đồng bộ (1 = Đã đồng bộ lên Cloud). |

---

### Bảng 2: `fuel_entries` (Nhật ký đổ xăng)
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | TEXT (PK) | UUID duy nhất của lần đổ xăng. |
| `vehicle_id` | TEXT (FK) | Mã xe (Trỏ về `vehicles.id`). |
| `date` | TEXT | Ngày giờ đổ xăng (ISO 8601). |
| `odometer` | REAL | Số ODO lúc đổ. |
| `liters` | REAL | Số Lít đổ. |
| `price_per_liter`| REAL | Đơn giá / Lít. |
| `total_cost` | REAL | Tổng số tiền. |
| `station_name` | TEXT | Tên cây xăng (Lấy tay hoặc tự động). |
| `station_address`| TEXT | Địa chỉ chi tiết (Lấy từ GPS API Nominatim). |
| `station_lat` | REAL | Vĩ độ (Latitude) lúc đổ. |
| `station_lon` | REAL | Kinh độ (Longitude) lúc đổ. |
| `fuel_type` | TEXT | Loại xăng đổ (RON 95, E5...). |
| `is_full` | INTEGER | Đổ đầy bình hay không (1=Có, 0=Không). |
| `note` | TEXT | Ghi chú người dùng. |
| `is_synced` | INTEGER | Trạng thái đồng bộ lên Cloud. |

---

### Bảng 3: `maintenance_entries` (Nhật ký Sửa chữa & Phụ tùng)
*(Bảng này đã gộp thay cho `maintenance_history` và `part_records` cũ)*

| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | TEXT (PK) | UUID duy nhất của lần bảo dưỡng. |
| `vehicle_id` | TEXT (FK) | Mã xe (Trỏ về `vehicles.id`). |
| `type` | TEXT | Loại hạng mục: `ROUTINE` (Bảo dưỡng), `PARTS` (Thay phụ tùng). |
| `title` | TEXT | Tiêu đề (VD: "Thay nhớt", "Thay lốp trước"). |
| `date` | TEXT | Ngày thực hiện. |
| `odometer` | REAL | Số ODO lúc thực hiện. |
| `cost` | REAL | Chi phí (VND). |
| `garage_name` | TEXT | Tên tiệm sửa xe. |
| `next_due_date` | TEXT | Ngày hẹn kiểm tra lại (Tuỳ chọn). |
| `next_due_km` | REAL | Số KM hẹn kiểm tra lại. |
| `image_path` | TEXT | Link ảnh hóa đơn hoặc phụ tùng (Lưu trữ Firebase Storage). |
| `note` | TEXT | Ghi chú. |
| `is_synced` | INTEGER | Trạng thái đồng bộ lên Cloud. |

---

### Bảng 4: `maintenance_items` (Mốc Nhắc lịch Bảo dưỡng Định kỳ)
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | TEXT (PK) | UUID duy nhất của mốc nhắc. |
| `vehicle_id` | TEXT (FK) | Mã xe (Trỏ về `vehicles.id`). |
| `name` | TEXT | Tên hạng mục (VD: "Thay Nhớt Máy"). |
| `icon_code` | TEXT | Mã icon hiển thị trên UI. |
| `interval_km` | INTEGER | Chu kỳ lặp lại (VD: Mỗi 2.000 KM). |
| `last_done_odo` | INTEGER | Số ODO lần cuối làm (Để lấy ODO hiện tại trừ đi xem đến hạn chưa). |
| `is_reminder_on` | INTEGER | Trạng thái bật/tắt (1 = Bật, 0 = Tắt). |

---

### Bảng 5: `custom_reminders` (Nhắc nhở Tùy chỉnh theo Ngày)
| Cột | Kiểu dữ liệu | Mô tả |
| :--- | :--- | :--- |
| `id` | TEXT (PK) | UUID duy nhất. |
| `vehicle_id` | TEXT (FK) | Mã xe (Trỏ về `vehicles.id`). |
| `title` | TEXT | Tiêu đề nhắc nhở (VD: "Gia hạn Đăng kiểm"). |
| `subtitle` | TEXT | Ghi chú thêm. |
| `type` | TEXT | Phân loại (Bảo hiểm, Đăng kiểm, Rửa xe...). |
| `is_on` | INTEGER | Trạng thái bật thông báo Push Notification. |