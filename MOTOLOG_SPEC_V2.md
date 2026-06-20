# MotoLog – Spec 2 màn hình mới: Bảo dưỡng & Nhắc lịch

> Bổ sung vào `MOTOLOG_SPEC.md` đã có.  
> Đọc kỹ toàn bộ trước khi code. Không tự thêm tính năng ngoài phạm vi này.

---

## Tổng quan

| # | Màn hình | File | Mở từ |
|---|----------|------|-------|
| 1 | Bảo dưỡng | `maintenance_screen.dart` (mới) | Quick action "Bảo dưỡng" ở Home |
| 2 | Nhắc lịch | `reminder_screen.dart` (mới) | Quick action "Nhắc lịch" ở Home |

---

## Design tokens (dùng chung toàn app)

```dart
// AppColors – đã có trong app_theme.dart, KHÔNG sửa
primary        = Color(0xFF2E7D32)   // xanh lá chính
primaryLight   = Color(0xFF4CAF50)
accent         = Color(0xFF66BB6A)
background     = Color(0xFFF5F5F5)
surface        = Color(0xFFFFFFFF)
textPrimary    = Color(0xFF1A1A1A)
textSecondary  = Color(0xFF757575)
greenChip      = Color(0xFFE8F5E9)   // nền badge/icon xanh nhạt
divider        = Color(0xFFE0E0E0)
fuelOrange     = Color(0xFFFF6F00)

// Màu riêng cho Nhắc lịch (thêm vào AppColors nếu chưa có)
warningOrange  = Color(0xFFE65100)   // badge "Hôm nay"
warningOrangeBg= Color(0xFFFFF3E0)
dangerRed      = Color(0xFFC62828)   // badge "Gần tới"
dangerRedBg    = Color(0xFFFFEBEE)
```

Font: `Be Vietnam Pro` (google_fonts), đã cấu hình trong `AppTheme`.

---

## Màn hình 1 – Bảo dưỡng (`maintenance_screen.dart`)

### Cấu trúc tổng thể (từ trên xuống)

```
AppBar
├── BackButton (trái)
├── Title: "Bảo dưỡng" (giữa)
└── [empty space] (phải, để căn giữa title)

Body (SingleChildScrollView)
├── Filter chips
├── ListView hạng mục (shrinkWrap, physics: NeverScrollableScrollPhysics)
└── Nút "+ Thêm bảo dưỡng"

BottomNavigationBar (MotoBottomNavBar, currentIndex: 1)
```

### AppBar

```dart
AppBar(
  title: const Text('Bảo dưỡng'),
  centerTitle: true,
  leading: const BackButton(),
)
```

### Filter chips

- Nằm trong `Container` background trắng, padding `horizontal: 16, vertical: 10`
- 3 chip: **Tất cả** · **Sắp tới** · **Đã hoàn thành**
- Chip active: background `AppColors.primary`, text trắng, border `AppColors.primary`
- Chip inactive: background trắng, text `AppColors.textSecondary`, border `AppColors.divider`
- Border radius chip: `BorderRadius.circular(20)`
- Font: 13px, w500
- Gap giữa các chip: 8px
- State: `_filterIndex` (int), `setState` khi tap

### ListView hạng mục

Mỗi item là một `Container` (card) với:
- background trắng
- `borderRadius: BorderRadius.circular(14)`
- `boxShadow`: `BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)`
- padding: `all(12)`
- margin bottom: 8px (dùng `SizedBox` giữa các item)
- Layout bên trong: `Row` → icon + `Expanded(Column)`

**Icon (trái):**
- Kích thước: 40×40
- `borderRadius: BorderRadius.circular(10)`
- background: `AppColors.greenChip`
- `Icon` màu `AppColors.primary`, size 22

**Nội dung (phải icon):**
```
Tên hạng mục      (14px, w600, textPrimary)
Định kỳ ...       (12px, w400, textSecondary) — margin top 2px
[Progress bar]    — margin top 8px
Còn X km          (12px, w600, primary) — margin top 4px
```

**Progress bar:**
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(4),
  child: LinearProgressIndicator(
    value: 1 - (remaining / total),   // ví dụ: 1 - 500/2000 = 0.75
    backgroundColor: AppColors.greenChip,
    color: AppColors.primary,
    minHeight: 6,
  ),
)
```

> `value` dao động 0.0–1.0. Giá trị cao = đã đi nhiều = thanh dài.

### Dữ liệu tĩnh (hardcode)

```dart
static const List<Map<String, dynamic>> _items = [
  {
    'icon': Icons.opacity,               // nhớt
    'label': 'Thay nhớt máy',
    'interval': 'Định kỳ sau mỗi 1.500 – 2.000 km',
    'remaining': 500,
    'total': 2000,
  },
  {
    'icon': Icons.settings,              // CVT
    'label': 'Vệ sinh nồi (CVT)',
    'interval': 'Định kỳ sau mỗi 8.000 – 10.000 km',
    'remaining': 2300,
    'total': 10000,
  },
  {
    'icon': Icons.electrical_services,   // bugi
    'label': 'Thay bugi',
    'interval': 'Định kỳ sau mỗi 8.000 – 10.000 km',
    'remaining': 2300,
    'total': 10000,
  },
  {
    'icon': Icons.air,                   // lọc gió
    'label': 'Thay lọc gió',
    'interval': 'Định kỳ sau mỗi 10.000 – 12.000 km',
    'remaining': 4300,
    'total': 12000,
  },
  {
    'icon': Icons.water_drop,            // nước làm mát
    'label': 'Thay nước làm mát',
    'interval': 'Định kỳ sau mỗi 12.000 – 15.000 km',
    'remaining': 6300,
    'total': 15000,
  },
];
```

### Nút "+ Thêm bảo dưỡng"

```dart
Padding(
  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
  child: ElevatedButton.icon(
    onPressed: () {},   // TODO: mở form thêm
    icon: const Icon(Icons.add),
    label: const Text('Thêm bảo dưỡng'),
  ),
)
```

Dùng style mặc định của `AppTheme` (xanh lá, full-width, h50, radius 12).

### Bottom nav

```dart
MotoBottomNavBar(currentIndex: 1, onTap: (_) {})
```

---

## Màn hình 2 – Nhắc lịch (`reminder_screen.dart`)

### Cấu trúc tổng thể (từ trên xuống)

```
AppBar
├── BackButton (trái)
├── Title: "Nhắc lịch" (giữa)
└── [empty space] (phải)

Body (SingleChildScrollView)
├── Filter chips
├── Section "Sắp tới"
│   ├── Item: Thay nhớt máy  [badge đỏ "Gần tới"]
│   └── Item: Nhắc đổ xăng  [badge cam "Hôm nay"]
├── Section "Định kỳ"
│   ├── Item: Vệ sinh nồi   [badge xanh "Bình thường"]
│   ├── Item: Thay bugi      [badge xanh "Bình thường"]
│   ├── Item: Thay lọc gió   [badge xanh "Bình thường"]
│   └── Item: Thay nước làm mát [badge xanh "Bình thường"]
└── Nút "+ Thêm nhắc lịch" (viền nét đứt)

BottomNavigationBar (MotoBottomNavBar, currentIndex: 1)
```

### AppBar

```dart
AppBar(
  title: const Text('Nhắc lịch'),
  centerTitle: true,
  leading: const BackButton(),
)
```

### Filter chips

Giống `MaintenanceScreen`, 3 chip: **Tất cả** · **Đang bật** · **Đã tắt**

### Section header

Mỗi nhóm có tiêu đề section:

```dart
Padding(
  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
  child: Text(
    'SẮP TỚI',   // hoặc 'ĐỊNH KỲ'
    style: GoogleFonts.beVietnamPro(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
      letterSpacing: 0.5,
    ),
  ),
)
```

### Item nhắc lịch

Mỗi item là `Container` background trắng, padding `symmetric(horizontal:16, vertical:12)`, ngăn cách bằng `Divider(height:1)`.

Layout: `Row` → icon + `Expanded(Column)` + badge

**Icon (trái):**
- Kích thước: 36×36
- `borderRadius: BorderRadius.circular(9)`
- 3 màu tùy mức độ:

| Mức | iconBg | iconColor | Dùng khi |
|-----|--------|-----------|----------|
| Nguy hiểm | `dangerRedBg` | `dangerRed` | remaining < 1000 km |
| Cảnh báo | `warningOrangeBg` | `warningOrange` | remaining 1000–3000 km hoặc hôm nay |
| Bình thường | `AppColors.greenChip` | `AppColors.primary` | còn nhiều km |

**Nội dung (giữa):**
```
Tên hạng mục    (13px, w500, textPrimary)
Mô tả phụ       (11px, w400, textSecondary) — margin top 2px
```

**Badge (phải):**
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  decoration: BoxDecoration(
    color: badgeBgColor,
    borderRadius: BorderRadius.circular(6),
  ),
  child: Text(badgeText, style: GoogleFonts.beVietnamPro(
    fontSize: 10, fontWeight: FontWeight.w600, color: badgeTextColor,
  )),
)
```

### Dữ liệu tĩnh (hardcode)

```dart
// Dùng enum hoặc const string để phân loại mức độ
// 'urgent' | 'warning' | 'normal'

static const _soonItems = [
  {
    'icon': Icons.opacity,
    'label': 'Thay nhớt máy',
    'sub': 'Còn 500 km · ODO 15.200 km',
    'badge': 'Gần tới',
    'level': 'urgent',    // đỏ
  },
  {
    'icon': Icons.local_gas_station,
    'label': 'Nhắc đổ xăng',
    'sub': 'Khi còn dưới 1/4 bình',
    'badge': 'Hôm nay',
    'level': 'warning',   // cam
  },
];

static const _periodicItems = [
  {
    'icon': Icons.settings,
    'label': 'Vệ sinh nồi (CVT)',
    'sub': 'Còn 2.300 km · mỗi 10.000 km',
    'badge': 'Bình thường',
    'level': 'normal',    // xanh
  },
  {
    'icon': Icons.electrical_services,
    'label': 'Thay bugi',
    'sub': 'Còn 2.300 km · mỗi 10.000 km',
    'badge': 'Bình thường',
    'level': 'normal',
  },
  {
    'icon': Icons.air,
    'label': 'Thay lọc gió',
    'sub': 'Còn 4.300 km · mỗi 12.000 km',
    'badge': 'Bình thường',
    'level': 'normal',
  },
  {
    'icon': Icons.water_drop,
    'label': 'Thay nước làm mát',
    'sub': 'Còn 6.300 km · mỗi 15.000 km',
    'badge': 'Bình thường',
    'level': 'normal',
  },
];
```

### Helper: map level → màu

```dart
Color _iconBg(String level) {
  switch (level) {
    case 'urgent':  return const Color(0xFFFFEBEE);
    case 'warning': return const Color(0xFFFFF3E0);
    default:        return AppColors.greenChip;
  }
}

Color _iconColor(String level) {
  switch (level) {
    case 'urgent':  return const Color(0xFFC62828);
    case 'warning': return const Color(0xFFE65100);
    default:        return AppColors.primary;
  }
}

Color _badgeBg(String level)   => _iconBg(level);
Color _badgeText(String level) => _iconColor(level);
```

### Nút "+ Thêm nhắc lịch"

Dùng `OutlinedButton` với border nét đứt:

```dart
Padding(
  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
  child: DottedBorder(   // hoặc tự vẽ bằng CustomPaint nếu không dùng package
    borderType: BorderType.RRect,
    radius: const Radius.circular(12),
    color: AppColors.primary,
    dashPattern: const [6, 4],
    child: SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, color: AppColors.primary, size: 18),
        label: Text('Thêm nhắc lịch', style: GoogleFonts.beVietnamPro(
          color: AppColors.primary, fontWeight: FontWeight.w500,
        )),
      ),
    ),
  ),
)
```

> **Nếu không muốn thêm package `dotted_border`**, thay bằng `OutlinedButton.icon` thường với `side: BorderSide(color: AppColors.primary, width: 1.5)` cũng được — chỉ mất nét đứt.

### Bottom nav

```dart
MotoBottomNavBar(currentIndex: 1, onTap: (_) {})
```

---

## Kết nối vào Home Screen

**File:** `lib/screens/home_screen.dart`

Thêm import:
```dart
import 'maintenance_screen.dart';
import 'reminder_screen.dart';
```

Cập nhật list `_quickActions`:
```dart
static final _actions = [
  {'icon': Icons.local_gas_station, 'label': 'Đổ xăng',   'screen': const FuelLogScreen()},
  {'icon': Icons.build_outlined,    'label': 'Bảo dưỡng',  'screen': const MaintenanceScreen()},  // ← đổi null → screen
  {'icon': Icons.account_balance_wallet_outlined, 'label': 'Chi phí', 'screen': null},
  {'icon': Icons.bar_chart,         'label': 'Thống kê',   'screen': const StatisticsScreen()},
  {'icon': Icons.two_wheeler,       'label': 'Xe của tôi', 'screen': null},
  {'icon': Icons.notifications_active_outlined, 'label': 'Nhắc lịch', 'screen': const ReminderScreen()},  // ← đổi null → screen
];
```

---

## Cấu trúc thư mục đầy đủ sau khi xong

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart              ← thêm warningOrange, dangerRed nếu cần
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart            ← sửa: thêm import + cập nhật _actions
│   ├── fuel_log_screen.dart
│   ├── history_screen.dart         ← đã có từ SPEC v1
│   ├── maintenance_screen.dart     ← MỚI (spec này)
│   ├── reminder_screen.dart        ← MỚI (spec này)
│   └── statistics_screen.dart
└── widgets/
    └── bottom_nav_bar.dart
```

---

## Checklist kiểm tra

- [ ] Quick action "Bảo dưỡng" → mở `MaintenanceScreen`
- [ ] Quick action "Nhắc lịch" → mở `ReminderScreen`
- [ ] Filter chips đổi state khi tap (cả 2 màn hình)
- [ ] Progress bar mỗi item tính đúng: `value = 1 - remaining / total`
- [ ] Badge màu đúng: đỏ = urgent, cam = warning, xanh = normal
- [ ] Nút thêm ở cuối mỗi màn hình hiển thị đúng
- [ ] `flutter analyze` không warning
- [ ] Bottom nav index đúng (currentIndex: 1 cho cả 2 màn hình)
