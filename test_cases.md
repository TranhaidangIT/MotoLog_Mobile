# Tài Liệu Kịch Bản Kiểm Thử (Test Cases) - MotoLog

**Dự án:** MotoLog (Nhật ký xe cá nhân)
**Ngày tạo:** 18/06/2026
**Mục tiêu:** Đảm bảo chất lượng toàn diện cho phần giao diện (UI) và nghiệp vụ xử lý (Logic/Backend) của ứng dụng theo chuẩn kiểm thử phần mềm Việt Nam.

---

## Mẫu Cấu Trúc Test Case
Mỗi Test Case (TC) sẽ bao gồm:
* **Mã TC:** ID duy nhất để theo dõi.
* **Tên TC / Kịch bản:** Mô tả ngắn gọn mục đích kiểm thử.
* **Điều kiện tiền quyết:** Trạng thái cần có trước khi thực hiện test.
* **Các bước thực hiện (Steps):** Hành động của người dùng.
* **Dữ liệu kiểm thử (Test Data):** Dữ liệu dùng để nhập.
* **Kết quả mong muốn (Expected Result):** Hệ thống phản hồi thế nào.

---

## 1. PHẦN GIAO DIỆN (UI/UX)

| Mã TC | Kịch bản kiểm thử | Bước thực hiện | Kết quả mong muốn |
|:---|:---|:---|:---|
| **UI-001** | Kiểm tra hiển thị màn hình Dashboard trên các kích thước màn hình khác nhau (Responsive) | 1. Mở app trên thiết bị màn hình nhỏ (iPhone SE)<br>2. Mở app trên màn hình lớn (Pro Max/Tablet) | Giao diện Cover Flow không bị vỡ. Nút bấm, text không bị đè lên nhau (chồng button). Logo hiển thị tròn đều không bị cắt nửa. |
| **UI-002** | Kiểm tra hiển thị ảnh xe (Fallback Logo) | 1. Thêm một xe mới không tải ảnh lên.<br>2. Quay lại Dashboard và Garage. | Hệ thống sử dụng Logo MotoLog làm ảnh nền dự phòng. Ảnh không bị cắt xén (BoxFit.contain) và hiển thị chính giữa rõ nét. |
| **UI-003** | Kiểm tra trạng thái Light Mode bắt buộc | 1. Vào Cài đặt điện thoại chuyển sang chế độ Dark Mode.<br>2. Mở lại ứng dụng MotoLog. | App vẫn giữ nguyên nền trắng `backgroundLight` (#F8F6F0) và chữ tối màu theo đúng thiết kế, không bị lỗi màu chữ tiệp màu nền. |
| **UI-004** | Kiểm tra cuộn trang (Scroll) và vuốt Cover Flow | 1. Thêm 5 xe vào danh sách.<br>2. Tại Dashboard, vuốt ngang danh sách xe nhanh và liên tục. | Thẻ xe mượt mà, xe được chọn tự động snap (hút) vào giữa màn hình, thông số bên dưới thay đổi theo đúng xe được focus. |

---

## 2. PHẦN NHẬP LIỆU & VALIDATION (FORM LOGIC)

| Mã TC | Kịch bản kiểm thử | Test Data | Kết quả mong muốn |
|:---|:---|:---|:---|
| **VAL-001** | Kiểm tra định dạng biển số xe VN (Positive) | `59A1-123.45`, `29-B1 12345` | Chấp nhận hợp lệ, cho phép lưu xe. |
| **VAL-002** | Kiểm tra định dạng biển số xe VN (Negative/Ngược) | `ABC-DEF`, `12345678`, `!@#$%` | Báo lỗi màu đỏ dưới Textfield: "Biển số xe không đúng định dạng VN". Nút Lưu bị chặn. |
| **VAL-003** | Kiểm tra giá tiền đổ xăng hợp lý | Số lít: `3`<br>Tổng tiền: `70000` (Khoảng 23k/lít) | Chấp nhận hợp lệ. |
| **VAL-004** | Kiểm tra giá tiền xăng phi lý (Dữ liệu ngoại lệ) | Số lít: `50`<br>Tổng tiền: `10000` (200đ/lít) hoặc Số lít: `1` mà giá `1000000` | Cảnh báo: "Giá xăng trung bình bất thường, bạn có chắc chắn thông tin này đúng?". (Hoặc chặn lưu tùy logic) |
| **VAL-005** | Bỏ trống các trường bắt buộc (Form đổ xăng/Bảo dưỡng) | Nhấn nút "Lưu" mà không nhập gì | Highlight đỏ tất cả các trường có dấu `*` với câu thông báo "Vui lòng nhập thông tin này". |
| **VAL-006** | Nhập chữ vào trường yêu cầu số (Odometer, Giá tiền) | Nhập `mot tram` vào trường Odometer | Bàn phím số phải được hiển thị mặc định, chặn không cho phép nhập ký tự chữ cái. |

---

## 3. PHẦN BACKEND & NGHIỆP VỤ BÁO CÁO (BUSINESS LOGIC)

| Mã TC | Kịch bản kiểm thử | Điều kiện tiền quyết | Bước thực hiện / Data | Kết quả mong muốn |
|:---|:---|:---|:---|:---|
| **LOG-001** | Tính toán tổng chi phí theo Quý (3 Tháng) | Xe có chi phí: T4 (100k), T5 (200k), T6 (300k). Hôm nay là cuối T6. | Mở trang Thống kê -> Chọn Filter "3M" (3 Tháng). | Tổng chi phí hiển thị chính xác `600.000 đ`. Trung bình tháng là `200.000 đ`. Cột biểu đồ hiện đủ 3 tháng. |
| **LOG-002** | Tính tỷ lệ tăng trưởng phần trăm (%) | Tháng trước tiêu 500k, tháng này tiêu 600k. | Xem trang Thống kê tháng này. | Hệ thống báo "+20% so với tháng trước" màu đỏ/cam chỉ thị tăng chi phí. |
| **LOG-003** | Tính tỷ lệ giảm chi tiêu (Trường hợp ngược) | Tháng trước tiêu 1 triệu, tháng này tiêu 500k. | Xem trang Thống kê tháng này. | Hệ thống báo "-50% so với tháng trước" màu xanh lá chỉ thị tiết kiệm. |
| **LOG-004** | Thêm dữ liệu ở tương lai (Ngược/Ngoại lệ) | - | Nhập ngày đổ xăng là ngày của 1 tháng sau (VD: hôm nay 18/06, chọn 18/07). | Hệ thống báo lỗi: "Ngày không được vượt quá ngày hiện tại". |
| **LOG-005** | Thêm Odometer nhỏ hơn lần bảo dưỡng/đổ xăng trước (Ngoại lệ) | Lần trước nhập ODO: `10000` | Nhập đổ xăng với ODO mới là: `9500` | Hệ thống báo lỗi "Số KM hiện tại không được nhỏ hơn số KM lần gần nhất (10000)". Chặn việc lưu form. |

---

## 4. TÍNH NĂNG THÔNG BÁO BẢO DƯỠNG (MAINTENANCE REMINDERS)

| Mã TC | Kịch bản kiểm thử | Test Data / Steps | Kết quả mong muốn |
|:---|:---|:---|:---|
| **NOT-001** | Nhắc nhở bảo dưỡng theo mốc KM chuẩn | ODO hiện tại: `5000`<br>Mốc thay nhớt: Cứ mỗi `2000` KM. (Lần cuối thay ở `3100`) | Thẻ Reminder hiển thị mốc tiếp theo `5100`. Số KM còn lại: `100` KM. Trạng thái thẻ: Cảnh báo sắp đến hạn (Màu Vàng/Cam). |
| **NOT-002** | Vượt mốc bảo dưỡng (Overdue) | ODO hiện tại: `5500`. (Lần cuối thay ở `3100`, hạn là `5100`) | Thẻ Reminder báo: "Quá hạn 400 KM". Màu sắc thẻ chuyển sang Đỏ (Alert). Sinh ra thông báo đẩy (Push notification) cảnh báo người dùng. |
| **NOT-003** | Khởi tạo nhắc nhở mới khi hoàn thành bảo dưỡng | 1. Nhấn vào nhắc nhở "Đã quá hạn thay nhớt".<br>2. Thêm mới lịch sử bảo dưỡng "Thay nhớt" tại mốc ODO `5500`. | Nhắc nhở cũ bị reset. Thẻ nhắc nhở mới được tạo với mục tiêu là `7500` KM. Khoảng cách an toàn trở lại màu Xanh nhạt. |
| **NOT-004** | Nhắc nhở theo Thời gian (Tháng) (Edge Case) | Vệ sinh nồi mỗi 6 tháng. Lần cuối: 01/01. Hôm nay: 01/07. (Dù số KM đi rất ít) | Sinh thông báo: "Đã đến hạn vệ sinh nồi (6 tháng)". Cho dù số KM chưa tới ngưỡng. |

---

## 5. TEST NGOẠI LỆ / TRƯỜNG HỢP "NGƯỢC" (NEGATIVE & CORNER CASES)

| Mã TC | Kịch bản kiểm thử | Bước thực hiện | Kết quả mong muốn |
|:---|:---|:---|:---|
| **NEG-001** | Bấm đúp (Double-tap) liên tục vào nút "Lưu" | Điền Form đầy đủ -> Bấm thật nhanh nút "Lưu" 3-4 lần. | Nút Lưu sẽ bị vô hiệu hóa (disabled) hoặc chuyển sang loading (spinner) ngay từ lần bấm đầu tiên. Dữ liệu chỉ được lưu 1 lần (Không tạo ra 3-4 bản ghi trùng lặp trong Database). |
| **NEG-002** | Xóa xe duy nhất (Tác động chuỗi) | Vào chi tiết chiếc xe duy nhất trong danh sách -> Chọn "Xóa xe". | 1. Bật xác nhận xóa.<br>2. Xóa xong, tự động điều hướng về Empty State Dashboard "Chưa có xe nào".<br>3. Tất cả Lịch sử xăng/bảo dưỡng của xe đó bị xóa khỏi DB. |
| **NEG-003** | Nhập ảnh dung lượng quá lớn (Ví dụ > 20MB) | Thêm xe -> Chọn ảnh xe máy có dung lượng 25MB từ thư viện. | App nén ảnh thành công trước khi lưu (compress) và không bị crash Out Of Memory, hoặc báo lỗi "Ảnh quá lớn, vui lòng chọn ảnh < 10MB". |
| **NEG-004** | Ngắt kết nối mạng khi đang lưu dữ liệu | 1. Rút WiFi/4G.<br>2. Bấm "Lưu" form bảo dưỡng. | (Tùy logic Firestore offline): Báo "Sẽ đồng bộ khi có mạng" và lưu cache offline, hoạt động vẫn bình thường. Hoặc cảnh báo "Mất kết nối mạng". |
| **NEG-005** | Nhập giá trị số cực kỳ lớn gây tràn bộ nhớ (Overflow) | Nhập chi phí bảo dưỡng: `999999999999` (vượt ngưỡng tỷ). | Form báo lỗi: "Chi phí không hợp lệ hoặc quá lớn" và không gây crash tràn biến tính toán hiển thị biểu đồ. |
