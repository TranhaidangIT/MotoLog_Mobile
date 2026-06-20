# MotoLog — Context Làm Việc

## Dự án

**Tên:** MotoLog Mobile  
**Thư mục:** `D:\MotoLog_Mobile`  
**Nhánh:** `feature/ui-redesign` (tạo từ `master`)  
**Framework:** Flutter (Dart), Riverpod, GoRouter, SQLite + Firestore  
**Mục tiêu hiện tại:** Thiết kế lại toàn bộ giao diện theo mockup đã có sẵn

---

## Quy tắc bắt buộc (từ promt.md)

- **KHÔNG** sáng tạo, không tự thêm thành phần
- **KHÔNG** thay đổi bố cục, thứ tự thành phần
- **KHÔNG** dùng Glassmorphism, Neumorphism, Dark futuristic, Gradient phức tạp
- Ảnh thiết kế tham chiếu là **nguồn sự thật duy nhất**
- Phong cách: Thân thiện, sạch, gần gũi (Google Maps / Duolingo / Honda)

## Màu sắc

| Tên | Mã màu |
|---|---|
| Primary Green | `#4FAF68` |
| Light Green | `#DFF3E3` |
| Background | `#F8F6F0` |
| Text Primary | `#222222` |
| Text Secondary | `#6B7280` |
| Warning | `#F59E0B` |
| Danger | `#EF4444` |
| White | `#FFFFFF` |

**Font:** Outfit (Google Fonts) — Bold cho tiêu đề, Regular cho body

---

## Cấu trúc thư mục quan trọng

```
D:\MotoLog_Mobile\
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart          ← Bảng màu toàn cục
│   │   │   ├── app_constants.dart       ← Hằng số (animation duration, keys...)
│   │   │   └── maintenance_schedule.dart ← [NEW] 10 hạng mục bảo dưỡng định kỳ
│   │   ├── router/
│   │   │   └── app_router.dart          ← GoRouter cấu hình tất cả routes
│   │   ├── theme/
│   │   │   └── app_theme.dart           ← ThemeData toàn cục
│   │   └── utils/
│   │       ├── formatters.dart          ← AppFormatters (currency, km, date...)
│   │       ├── validators.dart          ← AppValidators
│   │       └── reminder_calculator.dart ← Tính KM còn lại đến kỳ bảo dưỡng
│   ├── data/
│   │   ├── local/                       ← SQLite DAO
│   │   ├── models/                      ← Vehicle, FuelEntry, MaintenanceEntry
│   │   └── services/
│   │       └── firestore_service.dart   ← Sync Firestore <-> SQLite
│   ├── providers/                       ← Riverpod providers
│   │   ├── auth_provider.dart
│   │   ├── vehicle_provider.dart
│   │   ├── fuel_provider.dart
│   │   └── maintenance_provider.dart
│   └── screens/
│       ├── auth/
│       │   ├── login_screen.dart
│       │   └── register_screen.dart
│       ├── dashboard/
│       │   └── dashboard_screen.dart
│       ├── fuel/
│       │   ├── fuel_list_screen.dart
│       │   └── add_edit_fuel_screen.dart
│       ├── garage/
│       │   └── garage_screen.dart
│       ├── main/
│       │   └── main_shell.dart          ← Bottom Navigation Shell
│       ├── maintenance/
│       │   ├── maintenance_list_screen.dart ← [REDESIGNED] Lịch định kỳ + ảnh
│       │   └── add_edit_maintenance_screen.dart
│       ├── onboarding/
│       │   └── onboarding_screen.dart
│       ├── profile/
│       │   └── profile_screen.dart
│       ├── statistics/
│       │   └── statistics_screen.dart
│       └── vehicle/
│           ├── add_edit_vehicle_screen.dart
│           └── vehicle_detail_screen.dart
├── img/
│   ├── logo/                            ← logo.png, logo2.jpg, logo_padded.png
│   ├── backroud/                        ← 1.1.png, 1.2.png (dùng cho Onboarding/Login)
│   ├── xe-2-banh/                       ← Ảnh xe 2 bánh mặc định
│   ├── xe-4-banh/                       ← Ảnh xe 4 bánh mặc định
│   └── phu-tung/                        ← [NEW] 10 ảnh phụ tùng bảo dưỡng
└── pubspec.yaml                         ← assets đã khai báo đủ cả phu-tung/
```

---

## Routes (app_router.dart)

| Route | Screen |
|---|---|
| `/onboarding` | OnboardingScreen |
| `/login` | LoginScreen |
| `/login/register` | RegisterScreen |
| `/home/dashboard` | DashboardScreen |
| `/home/garage` | GarageScreen |
| `/home/fuel` | FuelListScreen |
| `/home/fuel/add` | AddEditFuelScreen |
| `/home/fuel/:id/edit` | AddEditFuelScreen |
| `/home/maintenance` | MaintenanceListScreen |
| `/home/maintenance/add` | AddEditMaintenanceScreen |
| `/home/maintenance/:id/edit` | AddEditMaintenanceScreen |
| `/home/statistics` | StatisticsScreen |
| `/home/profile` | ProfileScreen |
| `/vehicle/add` | AddEditVehicleScreen |
| `/vehicle/:id` | VehicleDetailScreen |
| `/vehicle/:id/edit` | AddEditVehicleScreen |

---

## Trạng thái Redesign theo màn hình

| Màn hình | File | Trạng thái |
|---|---|---|
| Onboarding | `screens/onboarding/onboarding_screen.dart` | ✅ Đã khớp spec (illustration nền + card trắng bo góc 32) |
| Login | `screens/auth/login_screen.dart` | ✅ Đã khớp spec (logo + form + Google + Facebook) |
| Register | `screens/auth/register_screen.dart` | ✅ Giữ nguyên |
| Dashboard | `screens/dashboard/dashboard_screen.dart` | 🔄 Cần review / tinh chỉnh Hero Card xanh lá |
| Garage | `screens/garage/garage_screen.dart` | 🔄 Cần review |
| Fuel Log | `screens/fuel/fuel_list_screen.dart` | 🔄 Cần review (Banner xanh + danh sách) |
| Add Fuel | `screens/fuel/add_edit_fuel_screen.dart` | 🔄 Cần review |
| Bảo dưỡng | `screens/maintenance/maintenance_list_screen.dart` | ✅ **REDESIGNED** — 10 hạng mục + ảnh phụ tùng + tabs + progress bar |
| Add Maintenance | `screens/maintenance/add_edit_maintenance_screen.dart` | 🔄 Cần review |
| Analytics | `screens/statistics/statistics_screen.dart` | 🔄 Cần review (Tabs 1M/3M/6M/1Y + biểu đồ cột) |
| Profile | `screens/profile/profile_screen.dart` | 🔄 Cần review |
| Bottom Nav | `screens/main/main_shell.dart` | 🔄 Cần review (5 tab, nút Add nổi giữa) |
| Add Vehicle | `screens/vehicle/add_edit_vehicle_screen.dart` | 🔄 Cần review |

---

## Thứ tự triển khai (tuần tự)

1. ✅ `maintenance_list_screen.dart` — Done
2. ⏳ `dashboard_screen.dart` — Hero Card xanh lá, Quick Stats 2 cột, Recent Activities
3. ⏳ `main_shell.dart` — Bottom Nav 5 tab, nút Add nổi giữa màu xanh
4. ⏳ `fuel_list_screen.dart` — Banner xanh + danh sách
5. ⏳ `statistics_screen.dart` — Tabs + biểu đồ cột
6. ⏳ `profile_screen.dart` — Avatar, settings list
7. ⏳ `garage_screen.dart` — Danh sách xe dạng card
8. ⏳ `add_edit_fuel_screen.dart` — Form thêm xăng
9. ⏳ `add_edit_maintenance_screen.dart` — Form thêm bảo dưỡng
10. ⏳ `add_edit_vehicle_screen.dart` — Form thêm xe

---

## Lưu ý kỹ thuật

- **State Management:** Riverpod — dùng `ref.watch()` để đọc, `ref.read()` để ghi
- **Providers quan trọng:**
  - `vehicleNotifierProvider` — danh sách xe
  - `selectedVehicleIdProvider` — xe đang chọn
  - `fuelListProvider` — danh sách đổ xăng (lọc theo xe đang chọn)
  - `maintenanceListProvider` — danh sách bảo dưỡng
  - `fuelCostThisMonthProvider(vehicleId)` — chi phí xăng tháng này
  - `maintenanceCostThisMonthProvider(vehicleId)` — chi phí bảo dưỡng tháng này
  - `upcomingMaintenanceProvider` — bảo dưỡng sắp đến hạn
  - `authNotifierProvider` — trạng thái đăng nhập
  - `currentUserProvider` — user hiện tại (Firebase User)
- **Navigation:** GoRouter — dùng `context.push()` cho trang phụ, `context.go()` cho tab chính
- **Formatters:** `AppFormatters.currency(double)`, `AppFormatters.km(double)`, `AppFormatters.date(DateTime)`
