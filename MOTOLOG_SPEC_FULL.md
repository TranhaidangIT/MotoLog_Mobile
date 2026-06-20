# MotoLog – Spec tổng thể (FULL) — Áp dụng đè lên toàn bộ code hiện tại

> File này là bản tổng hợp DUY NHẤT, gộp toàn bộ các thay đổi từ v1, v2, fix.
> AI code chỉ cần đọc file này, không cần đọc các file spec cũ.
> Mục tiêu: 8 màn hình chức năng đầy đủ, không còn ô trống nào trong Quick Actions.

---

## 1. Tổng quan trạng thái màn hình

| # | Màn hình | File | Trạng thái | Vào từ đâu |
|---|----------|------|-----------|------------|
| 1 | Splash | `splash_screen.dart` | Có sẵn | Khởi động app |
| 2 | Login | `login_screen.dart` | Có sẵn | Sau Splash |
| 3 | Home | `home_screen.dart` | Sửa lại Quick Actions + Bottom Nav | Sau Login |
| 4 | Đổ xăng (Form) | `add_fuel_screen.dart` | Có sẵn | Quick Action "Đổ xăng" |
| 5 | Lịch sử (gộp xăng+bảo dưỡng) | `history_screen.dart` | Có sẵn, cần fix layout | Bottom Nav tab "Lịch sử" |
| 6 | Thống kê | `stats_screen.dart` | Có sẵn | Quick Action "Thống kê" |
| 7 | Bảo dưỡng | `maintenance_screen.dart` | Có sẵn | Quick Action "Bảo dưỡng" |
| 8 | Nhắc lịch | `reminder_screen.dart` | Có sẵn | Quick Action "Nhắc lịch" |
| 9 | **Chi phí** (MỚI) | `expense_screen.dart` | **Tạo mới — đang trống** | Quick Action "Chi phí" |
| 10 | **Xe của tôi** (MỚI) | `my_vehicle_screen.dart` | **Tạo mới — đang trống** | Quick Action "Xe của tôi" |

→ Sau khi áp dụng file này: **0 ô trống**, toàn bộ 6 Quick Action trên Home đều có màn hình thật.

---

## 2. Cấu trúc thư mục cuối cùng

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart
├── widgets/
│   └── bottom_nav_bar.dart
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── home_screen.dart
    ├── add_fuel_screen.dart
    ├── history_screen.dart          (gộp lịch sử xăng + bảo dưỡng, dùng tab card)
    ├── stats_screen.dart
    ├── maintenance_screen.dart
    ├── reminder_screen.dart
    ├── expense_screen.dart          ← MỚI
    └── my_vehicle_screen.dart       ← MỚI

(XOÁ file cũ không dùng nữa: fuel_history_screen.dart — đã gộp vào history_screen.dart)
```

---

## 3. Home Screen — Quick Actions (bản cuối cùng, đúng 6 ô)

Tìm list `_actions` trong `home_screen.dart`, thay toàn bộ bằng:

```dart
final List<Map<String, dynamic>> _actions = [
  {'icon': Icons.local_gas_station_outlined, 'label': 'Đổ xăng',     'screen': const AddFuelScreen()},
  {'icon': Icons.build_outlined,              'label': 'Bảo dưỡng',  'screen': const MaintenanceScreen()},
  {'icon': Icons.pie_chart_outline,           'label': 'Chi phí',    'screen': const ExpenseScreen()},
  {'icon': Icons.bar_chart_outlined,          'label': 'Thống kê',   'screen': const StatsScreen()},
  {'icon': Icons.two_wheeler_outlined,        'label': 'Xe của tôi', 'screen': const MyVehicleScreen()},
  {'icon': Icons.notifications_outlined,      'label': 'Nhắc lịch',  'screen': const ReminderScreen()},
];
```

Thêm import ở đầu file `home_screen.dart`:

```dart
import 'add_fuel_screen.dart';
import 'maintenance_screen.dart';
import 'expense_screen.dart';
import 'stats_screen.dart';
import 'my_vehicle_screen.dart';
import 'reminder_screen.dart';
import 'history_screen.dart';
```

Khi render Quick Action grid, đảm bảo `onTap` luôn dùng `item['screen']`:

```dart
onTap: () {
  if (item['screen'] != null) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => item['screen'] as Widget));
  }
},
```

---

## 4. Bottom Navigation Bar — 4 tab cố định

Sửa `bottom_nav_bar.dart`, đảm bảo đúng 4 tab sau (không phải 5, không phải "Đổ xăng"):

```dart
_NavItem(icon: Icons.home_outlined,     label: 'Trang chủ', index: 0, current: currentIndex, onTap: onTap),
_NavItem(icon: Icons.history,           label: 'Lịch sử',   index: 1, current: currentIndex, onTap: onTap),
_NavItem(icon: Icons.pie_chart_outline, label: 'Chi phí',   index: 2, current: currentIndex, onTap: onTap),
_NavItem(icon: Icons.two_wheeler_outlined, label: 'Xe của tôi', index: 3, current: currentIndex, onTap: onTap),
```

Trong `home_screen.dart`, phần `onTap` của `MotoBottomNavBar`:

```dart
onTap: (i) {
  if (i == 0) return; // đang ở Home
  if (i == 1) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
  } else if (i == 2) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ExpenseScreen()));
  } else if (i == 3) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const MyVehicleScreen()));
  }
},
```

> Lưu ý `currentIndex` truyền vào `MotoBottomNavBar` ở mỗi màn hình phải đúng theo vị trí tab tương ứng (Home=0, Lịch sử/Bảo dưỡng=1, Chi phí=2, Xe của tôi=3).

---

## 5. History Screen — fix layout còn thiếu (đã có code đầy đủ ở dưới, dùng để paste lại cho chắc)

File `history_screen.dart` dùng nguyên bản đã có, nhưng kiểm tra đúng 3 điểm sau:

1. Mỗi item trong list **PHẢI** có đủ 3 phần bên phải: số tiền (đậm) → badge nhỏ (màu xanh) → icon `chevron_right`.
2. Stats bar (chỉ hiện ở tab "Đổ xăng") **PHẢI** có đủ 4 cột: Tổng tiền, Tổng lít, Tiêu hao TB, Quãng đường.
3. 2 card toggle "Đổ xăng" / "Bảo dưỡng" ở đầu trang phải full code như bản gốc (không bị cắt bớt phần `sub`).

(Toàn bộ code chi tiết đã gửi ở phần trước, giữ nguyên không đổi.)

---

## 6. Maintenance Screen — giữ nguyên (đã đúng)

Không thay đổi gì so với bản đã gửi trước — filter chips, progress bar, nút "Thêm bảo dưỡng".

---

## 7. Reminder Screen — giữ nguyên (đã đúng)

Không thay đổi gì so với bản đã gửi trước — 2 nhóm "Sắp tới" / "Định kỳ", badge 3 màu (đỏ/cam/xanh).

---

## 8. MÀN HÌNH MỚI #1 — Expense Screen (Chi phí)

File: `lib/screens/expense_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  int _periodIndex = 1; // 0=Tuần 1=Tháng 2=Năm
  static const _periods = ['Tuần', 'Tháng', 'Năm'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi phí'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Chọn khoảng thời gian
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: List.generate(_periods.length, (i) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _periodIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _periodIndex == i ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(_periods[i], style: GoogleFonts.beVietnamPro(
                      fontSize: 13, fontWeight: FontWeight.w600,
                      color: _periodIndex == i ? Colors.white : AppColors.textSecondary,
                    )),
                  ),
                ),
              )),
            ),
          ),

          const SizedBox(height: 16),

          // Tổng chi phí lớn
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.greenChip, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Text('Tổng chi phí tháng này', style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              Text('930.000 đ', style: GoogleFonts.beVietnamPro(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.primary)),
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.arrow_upward, size: 14, color: Colors.redAccent),
                Text(' 12% so với tháng trước', style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ]),
          ),

          const SizedBox(height: 16),

          // Phân loại theo danh mục
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Theo danh mục', style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _CategoryBar(icon: Icons.local_gas_station, label: 'Xăng', amount: '680.000 đ', percent: 0.73),
              const SizedBox(height: 12),
              _CategoryBar(icon: Icons.build, label: 'Bảo dưỡng', amount: '250.000 đ', percent: 0.27),
            ]),
          ),

          const SizedBox(height: 16),

          // Giao dịch gần đây
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Giao dịch gần đây', style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600)),
                  TextButton(onPressed: () {}, child: const Text('Xem tất cả')),
                ]),
              ),
              _TxnRow(icon: Icons.local_gas_station, label: 'Đổ xăng', date: '22/06', amount: '80.000 đ'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _TxnRow(icon: Icons.opacity, label: 'Thay nhớt máy', date: '10/06', amount: '120.000 đ'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _TxnRow(icon: Icons.local_gas_station, label: 'Đổ xăng', date: '15/06', amount: '90.000 đ'),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: MotoBottomNavBar(currentIndex: 2, onTap: (_) {}),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final IconData icon;
  final String label, amount;
  final double percent;
  const _CategoryBar({required this.icon, required this.label, required this.amount, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: GoogleFonts.beVietnamPro(fontSize: 13))),
        Text(amount, style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: percent,
          backgroundColor: AppColors.greenChip,
          color: AppColors.primary,
          minHeight: 6,
        ),
      ),
    ]);
  }
}

class _TxnRow extends StatelessWidget {
  final IconData icon;
  final String label, date, amount;
  const _TxnRow({required this.icon, required this.label, required this.date, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: const BoxDecoration(color: AppColors.greenChip, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(date, style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
        ])),
        Text(amount, style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
```

---

## 9. MÀN HÌNH MỚI #2 — My Vehicle Screen (Xe của tôi)

File: `lib/screens/my_vehicle_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class MyVehicleScreen extends StatelessWidget {
  const MyVehicleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xe của tôi'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card ảnh xe + tên xe
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.greenChip, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              Container(
                width: 90, height: 90,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.two_wheeler, size: 50, color: AppColors.primary),
              ),
              const SizedBox(height: 12),
              Text('Honda Vision 2022', style: GoogleFonts.beVietnamPro(fontSize: 18, fontWeight: FontWeight.w700)),
              Text('59-P1 123.45', style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Sửa thông tin'),
              ),
            ]),
          ),

          const SizedBox(height: 16),

          // ODO hiện tại
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Row(children: [
              const Icon(Icons.speed, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ODO hiện tại', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
                Text('15.200 km', style: GoogleFonts.beVietnamPro(fontSize: 18, fontWeight: FontWeight.w700)),
              ])),
              TextButton(onPressed: () {}, child: const Text('Cập nhật')),
            ]),
          ),

          const SizedBox(height: 12),

          // Thông tin chi tiết
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(children: [
              _InfoRow(icon: Icons.calendar_today, label: 'Ngày mua', value: '12/03/2022'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(icon: Icons.local_gas_station, label: 'Dung tích bình xăng', value: '5,2 lít'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(icon: Icons.color_lens, label: 'Màu xe', value: 'Đen nhám'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(icon: Icons.confirmation_number, label: 'Số khung', value: 'RLHJF1234567'),
            ]),
          ),

          const SizedBox(height: 12),

          // Tổng quan chi phí từ lúc mua
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tổng chi phí từ lúc mua', style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(children: [
                _SummaryCell(label: 'Xăng', value: '680.000 đ'),
                _SummaryCell(label: 'Bảo dưỡng', value: '250.000 đ'),
                _SummaryCell(label: 'Tổng', value: '930.000 đ', highlight: true),
              ]),
            ]),
          ),
        ],
      ),
      bottomNavigationBar: MotoBottomNavBar(currentIndex: 3, onTap: (_) {}),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary))),
        Text(value, style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String label, value;
  final bool highlight;
  const _SummaryCell({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(label, style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.beVietnamPro(
          fontSize: 13, fontWeight: FontWeight.w700,
          color: highlight ? AppColors.primary : AppColors.textPrimary,
        )),
      ]),
    );
  }
}
```

---

## 10. Checklist kiểm tra cuối cùng (AI tự rà soát sau khi code xong)

- [ ] Home Screen có đúng 6 Quick Action, không ô nào `screen: null`
- [ ] Bottom Nav có đúng 4 tab: Trang chủ / Lịch sử / Chi phí / Xe của tôi
- [ ] Tab "Lịch sử" mở `HistoryScreen` (gộp xăng + bảo dưỡng dạng 2 card chọn)
- [ ] Mỗi item trong `HistoryScreen` có đủ: số tiền + badge + chevron
- [ ] Stats bar trong `HistoryScreen` có đủ 4 cột khi ở tab "Đổ xăng"
- [ ] `MaintenanceScreen` có progress bar + "Còn X km" + nút "Thêm bảo dưỡng"
- [ ] `ReminderScreen` có 2 nhóm "Sắp tới"/"Định kỳ" với badge 3 màu
- [ ] `ExpenseScreen` mới: có tổng chi phí, phân loại theo danh mục, giao dịch gần đây
- [ ] `MyVehicleScreen` mới: có ODO, thông tin xe, tổng chi phí từ lúc mua
- [ ] File `fuel_history_screen.dart` cũ đã được xoá (không còn dùng)
- [ ] Tất cả `currentIndex` truyền vào `MotoBottomNavBar` ở từng màn hình đúng vị trí tab
- [ ] Toàn bộ màn hình dùng đúng `AppColors.primary` / `AppColors.greenChip` / `GoogleFonts.beVietnamPro` nhất quán với theme hiện tại

---

**Lưu ý cho AI code (Antigravity):** File này là bản FULL thay thế toàn bộ các spec/fix trước đó (`MOTOLOG_SPEC.md`, `MOTOLOG_SPEC_V2.md`, `MOTOLOG_FIX.md`). Chỉ cần dùng file này.
