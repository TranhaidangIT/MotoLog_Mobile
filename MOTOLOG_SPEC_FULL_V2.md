# MotoLog – Spec tổng thể V2 (FULL, ĐÃ SỬA) — Thay thế hoàn toàn bản trước

> File này thay thế `MOTOLOG_SPEC_FULL.md` cũ. Lý do sửa: Bottom Nav thực tế có **5 ô** (không phải 4), và màn hình Lịch sử cần đơn giản lại đúng theo mockup gốc — không dùng kiểu "2 card toggle" nữa.

---

## ⚠️ 2 LỖI QUAN TRỌNG CẦN SỬA NGAY

### Lỗi 1 — Bottom Navigation Bar sai cấu trúc

Hiện tại đang code theo 4 tab thường. **SAI**. Đúng phải là **5 ô**, ô giữa là nút **+** tròn nổi lên (FAB), không có label:

```
[Trang chủ]  [Lịch sử]  [ (+) ]  [Thống kê]  [Cá nhân]
```

- Ô giữa là `FloatingActionButton` hình tròn, màu xanh `#2E7D32`, icon `+`, nổi cao hơn thanh nav khoảng 5px, **không có nhãn chữ**.
- 4 ô còn lại có icon + label, ô đang active thì icon + chữ chuyển màu xanh `#2E7D32`, in đậm; không active thì màu `#757575`.
- Bấm vào nút **+** → mở `AddFuelScreen` (hoặc bottom sheet chọn "Đổ xăng / Bảo dưỡng" nếu muốn nâng cấp sau).

Code mẫu `bottom_nav_bar.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class MotoBottomNavBar extends StatelessWidget {
  final int currentIndex; // 0=Trang chủ 1=Lịch sử 2=Thống kê 3=Cá nhân (KHÔNG tính nút +)
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const MotoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      padding: const EdgeInsets.only(top: 7, bottom: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_outlined, label: 'Trang chủ', index: 0, current: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.history, label: 'Lịch sử', index: 1, current: currentIndex, onTap: onTap),
          // Nút + nổi giữa — KHÔNG nằm trong logic index như các tab khác
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              width: 44, height: 44,
              margin: const EdgeInsets.only(top: -14),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
          _NavItem(icon: Icons.bar_chart_outlined, label: 'Thống kê', index: 2, current: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.person_outline, label: 'Cá nhân', index: 3, current: currentIndex, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final ValueChanged<int> onTap;
  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    final color = active ? AppColors.primary : const Color(0xFF757575);
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.beVietnamPro(
          fontSize: 10, color: color, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        )),
      ]),
    );
  }
}
```

> **Tất cả màn hình** đang gọi `MotoBottomNavBar(currentIndex: x, onTap: ...)` phải thêm tham số `onAddTap` mới, ví dụ:
>
> ```dart
> MotoBottomNavBar(
>   currentIndex: 1,
>   onTap: (i) { /* điều hướng như cũ */ },
>   onAddTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFuelScreen())),
> )
> ```

**Đổi index:** vì bỏ tab "Chi phí" ra khỏi bottom nav (giờ chỉ vào qua Quick Action ở Home), nav 4 ô còn lại là: `0=Trang chủ, 1=Lịch sử, 2=Thống kê, 3=Cá nhân`. `MyVehicleScreen` đổi từ `currentIndex: 3` giữ nguyên (gắn vào tab "Cá nhân"); `ExpenseScreen` không gắn nav index nào cố định nữa — dùng `currentIndex: -1` hoặc đơn giản giữ nguyên dòng cũ vì nó chỉ mở qua Quick Action, không qua bottom nav (xem mục 4).

---

### Lỗi 2 — History Screen đang sai layout, cần làm lại đúng theo mockup

Bản trước tôi làm theo kiểu "2 card to để chọn Xăng/Bảo dưỡng" — nhưng nhìn lại ảnh mockup gốc (ảnh "Chưa có lịch sử đổ xăng"), bố cục đúng phải đơn giản hơn:

- AppBar: "Lịch sử đổ xăng", có icon filter (≡) bên phải.
- Ngay dưới AppBar là **filter chip hàng ngang, scroll được**: `Tất cả` (active, viền xanh đậm) · `Tháng này` · `Tháng trước` · `Tuỳ chọn`.
- Bên dưới là **list lịch sử** (không có 2 card toggle to nữa).
- Nếu list rỗng → hiển thị **empty state** ở giữa màn hình: chữ "Chưa có lịch sử đổ xăng" màu xám, cỡ chữ 14.
- Bảo dưỡng **KHÔNG** gộp vào đây nữa — giữ là `maintenance_screen.dart` riêng, vào qua Quick Action ở Home như cũ (đã đúng từ trước).

→ Nói cách khác: **bỏ hẳn ý tưởng gộp Lịch sử xăng + Bảo dưỡng vào 1 tab** mà tôi đề xuất lúc trước. Tab "Lịch sử" trong bottom nav chỉ là lịch sử đổ xăng thuần túy. `HistoryScreen` đổi tên lại đúng vai trò = lịch sử đổ xăng (có thể giữ tên file `history_screen.dart` nhưng nội dung chỉ là fuel history).

Code mẫu `history_screen.dart` (bản đúng, thay hoàn toàn bản cũ):

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import 'add_fuel_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _filterIndex = 0;
  static const _filters = ['Tất cả', 'Tháng này', 'Tháng trước', 'Tuỳ chọn'];

  // Đổi list này thành dữ liệu thật khi có database/storage
  static const _fuelRecords = <Map<String, String>>[
    // Để rỗng [] để test giao diện "Chưa có lịch sử đổ xăng"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đổ xăng'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list)),
        ],
      ),
      body: Column(children: [
        // Filter chips
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: List.generate(_filters.length, (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _filterIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _filterIndex == i ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _filterIndex == i ? AppColors.primary : AppColors.divider),
                  ),
                  alignment: Alignment.center,
                  child: Text(_filters[i], style: GoogleFonts.beVietnamPro(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: _filterIndex == i ? Colors.white : AppColors.textSecondary,
                  )),
                ),
              ),
            )),
          ),
        ),

        // List hoặc Empty state
        Expanded(
          child: _fuelRecords.isEmpty
            ? Center(
                child: Text('Chưa có lịch sử đổ xăng', style: GoogleFonts.beVietnamPro(
                  fontSize: 14, color: AppColors.textSecondary,
                )),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _fuelRecords.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final r = _fuelRecords[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                    ),
                    child: Row(children: [
                      Container(
                        width: 38, height: 38,
                        decoration: const BoxDecoration(color: AppColors.greenChip, shape: BoxShape.circle),
                        child: const Icon(Icons.local_gas_station_outlined, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('${r['date']} · ${r['liters']} lít · ODO ${r['odo']} km',
                          style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
                      ])),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text(r['amount']!, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w700)),
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.greenChip, borderRadius: BorderRadius.circular(6)),
                          child: Text('${r['consumption']} km/lít', style: GoogleFonts.beVietnamPro(
                            fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600,
                          )),
                        ),
                      ]),
                    ]),
                  );
                },
              ),
        ),
      ]),
      bottomNavigationBar: MotoBottomNavBar(
        currentIndex: 1,
        onTap: (i) {}, // điều hướng tab — xem mục Home Screen
        onAddTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFuelScreen())),
      ),
    );
  }
}
```

---

## 1. Tổng quan trạng thái màn hình (bản cuối, đã sửa)

| # | Màn hình | File | Vào từ đâu |
|---|----------|------|------------|
| 1 | Splash | `splash_screen.dart` | Khởi động app |
| 2 | Login | `login_screen.dart` | Sau Splash |
| 3 | Home | `home_screen.dart` | Sau Login |
| 4 | Đổ xăng (Form) | `add_fuel_screen.dart` | Quick Action "Đổ xăng" + nút **+** giữa nav |
| 5 | **Lịch sử đổ xăng** | `history_screen.dart` | Bottom Nav tab "Lịch sử" — **chỉ lịch sử xăng, có filter + empty state** |
| 6 | Thống kê | `stats_screen.dart` | Quick Action "Thống kê" + Bottom Nav tab "Thống kê" |
| 7 | Bảo dưỡng | `maintenance_screen.dart` | Quick Action "Bảo dưỡng" (màn hình riêng, KHÔNG gộp vào Lịch sử) |
| 8 | Nhắc lịch | `reminder_screen.dart` | Quick Action "Nhắc lịch" |
| 9 | Chi phí | `expense_screen.dart` | Quick Action "Chi phí" — **thiết kế lại theo mockup mới, có donut chart** |
| 10 | Xe của tôi / Cá nhân | `my_vehicle_screen.dart` | Quick Action "Xe của tôi" + Bottom Nav tab "Cá nhân" — **thiết kế lại theo mockup mới** |

---

## 2. Home Screen — Quick Actions (giữ nguyên 6 ô, không đổi)

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

Phần `onTap` của `MotoBottomNavBar` trong `home_screen.dart` (đã đổi index do bớt 1 tab):

```dart
MotoBottomNavBar(
  currentIndex: 0,
  onTap: (i) {
    if (i == 0) return; // đang ở Home
    if (i == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
    } else if (i == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
    } else if (i == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyVehicleScreen()));
    }
  },
  onAddTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddFuelScreen())),
)
```

`StatsScreen` và `MyVehicleScreen` cũng cần thêm `MotoBottomNavBar` với `currentIndex: 2` và `currentIndex: 3` tương ứng (nếu chưa có).

---

## 3. Maintenance / Reminder Screen — giữ nguyên, không đổi gì

Vẫn đúng như bản đã gửi trước (progress bar, filter chips, badge 3 màu...). Không có trong bottom nav, chỉ vào qua Quick Action ở Home.

---

## 4. Expense Screen — thiết kế lại 100% theo mockup HTML mới (có donut chart)

File: `lib/screens/expense_screen.dart`

Bố cục từ trên xuống:
1. AppBar "Chi phí" + back button.
2. **Thanh chọn tháng**: `‹  Tháng 6 / 2024  ›` — bấm mũi tên để chuyển tháng.
3. **Card tổng chi phí** nền xanh đậm `#2E7D32`, chữ trắng: label nhỏ "Tổng chi phí tháng này" → số tiền lớn "930.000 đ" → badge nhỏ bo tròn nền trắng mờ "↓ Giảm 8% so với tháng trước".
4. **Card donut chart**: vòng tròn donut bên trái (Xăng xanh 73%, Bảo dưỡng cam 27%, Khác xám 0%) + legend bên phải (dot màu + tên + số tiền/%).
5. **List 3 dòng chi phí theo danh mục**: Xăng / Bảo dưỡng / Khác — mỗi dòng có icon vuông bo góc màu riêng (xanh/cam/xanh dương), tên + phụ đề (số lần), số tiền + % bên phải, chevron cuối dòng.

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});
  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  DateTime _month = DateTime(2024, 6);

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi phí'), leading: const BackButton()),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Month selector
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              IconButton(onPressed: () => _changeMonth(-1), icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary)),
              Text('Tháng ${_month.month} / ${_month.year}', style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600)),
              IconButton(onPressed: () => _changeMonth(1), icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary)),
            ]),
          ),

          // Total card
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Tổng chi phí tháng này', style: GoogleFonts.beVietnamPro(fontSize: 11, color: Colors.white.withOpacity(0.7))),
              const SizedBox(height: 2),
              Text('930.000 đ', style: GoogleFonts.beVietnamPro(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.arrow_downward, size: 10, color: Colors.white),
                  const SizedBox(width: 3),
                  Text('Giảm 8% so với tháng trước', style: GoogleFonts.beVietnamPro(fontSize: 10, color: Colors.white)),
                ]),
              ),
            ]),
          ),

          // Donut + legend
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Row(children: [
              SizedBox(
                width: 72, height: 72,
                child: CustomPaint(painter: _DonutPainter(segments: const [0.73, 0.27, 0.0])),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _LegendRow(color: AppColors.primary, name: 'Xăng', value: '680k (73%)'),
                const SizedBox(height: 5),
                _LegendRow(color: const Color(0xFFFF6F00), name: 'Bảo dưỡng', value: '250k (27%)'),
                const SizedBox(height: 5),
                _LegendRow(color: const Color(0xFFE0E0E0), name: 'Khác', value: '0 đ'),
              ])),
            ]),
          ),

          // Category list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(children: [
              _CostCard(icon: Icons.local_gas_station, iconBg: const Color(0xFFE8F5E9), iconColor: AppColors.primary,
                title: 'Xăng', sub: '6 lần đổ · 27,2 lít', amount: '680.000 đ', percent: '73,1%'),
              const SizedBox(height: 6),
              _CostCard(icon: Icons.build, iconBg: const Color(0xFFFFF3E0), iconColor: const Color(0xFFE65100),
                title: 'Bảo dưỡng', sub: '2 lần · Nhớt + Bugi', amount: '250.000 đ', percent: '26,9%'),
              const SizedBox(height: 6),
              _CostCard(icon: Icons.more_horiz, iconBg: const Color(0xFFE3F2FD), iconColor: const Color(0xFF1565C0),
                title: 'Khác', sub: 'Chưa có chi phí', amount: '0 đ', percent: '0%', dim: true),
            ]),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> segments; // tổng = 1.0, theo thứ tự xanh/cam/xám
  const _DonutPainter({required this.segments});

  static const _colors = [AppColors.primary, Color(0xFFFF6F00), Color(0xFFE0E0E0)];

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(6, 6, size.width - 12, size.height - 12);
    const strokeWidth = 12.0;
    double startAngle = -pi / 2;
    for (var i = 0; i < segments.length; i++) {
      final sweep = segments[i] * 2 * pi;
      final paint = Paint()
        ..color = _colors[i]
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep == 0 ? 0.001 : sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => false;
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String name, value;
  const _LegendRow({required this.color, required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Expanded(child: Text(name, style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary))),
      Text(value, style: GoogleFonts.beVietnamPro(fontSize: 11, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _CostCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, sub, amount, percent;
  final bool dim;
  const _CostCard({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.sub, required this.amount, required this.percent,
    this.dim = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(sub, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(amount, style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600, color: dim ? AppColors.textSecondary : AppColors.textPrimary)),
          Text(percent, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary)),
        ]),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
      ]),
    );
  }
}
```

---

## 5. My Vehicle Screen ("Xe của tôi" / "Cá nhân") — thiết kế lại 100% theo mockup HTML mới

File: `lib/screens/my_vehicle_screen.dart`

Bố cục từ trên xuống:
1. AppBar "Xe của tôi" + back + icon bút chì (sửa) bên phải.
2. **Bike card** nền xanh đậm, có vòng tròn mờ trang trí ở góc dưới-phải: tên xe nhỏ → biển số dạng badge bo tròn nền trắng mờ → "Tổng quãng đường" + số km lớn → dãy dot chỉ số trang (nếu có nhiều xe, dot đầu dài hơn = đang chọn).
3. Tiêu đề mục nhỏ in hoa màu xanh: "THÔNG TIN XE".
4. **Grid 2x2** 4 ô: Năm sản xuất / Màu xe / Dung tích / Loại xăng — mỗi ô icon xanh nhỏ + giá trị đậm + label xám nhỏ.
5. Tiêu đề mục nhỏ: "GIẤY TỜ & HẠN".
6. **List giấy tờ**: Đăng kiểm / Bảo hiểm xe / Đăng ký xe — mỗi dòng icon vuông xanh nhạt + tên + hạn, badge trạng thái bên phải (cam "Sắp hết" / xanh "Còn hạn" / xanh "Hợp lệ").

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
      appBar: AppBar(
        title: const Text('Xe của tôi'),
        leading: const BackButton(),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined, size: 20))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          // Bike card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              Positioned(
                right: -10, bottom: -10,
                child: Container(width: 80, height: 80, decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08), shape: BoxShape.circle,
                )),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Honda Wave Alpha 110', style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.white.withOpacity(0.75))),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text('Biển số: 65B1-123.45', style: GoogleFonts.beVietnamPro(fontSize: 11, color: Colors.white)),
                ),
                const SizedBox(height: 10),
                Text('Tổng quãng đường', style: GoogleFonts.beVietnamPro(fontSize: 10, color: Colors.white.withOpacity(0.7))),
                Text('29.456 km', style: GoogleFonts.beVietnamPro(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 8),
                Row(children: [
                  Container(width: 24, height: 5, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 4),
                  Container(width: 16, height: 5, decoration: BoxDecoration(color: Colors.white.withOpacity(0.35), borderRadius: BorderRadius.circular(3))),
                ]),
              ]),
            ]),
          ),

          const SizedBox(height: 4),
          _SectionTitle('Thông tin xe'),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8,
            childAspectRatio: 1.7,
            children: const [
              _InfoCell(icon: Icons.calendar_today, value: '2019', label: 'Năm sản xuất'),
              _InfoCell(icon: Icons.palette_outlined, value: 'Đỏ đen', label: 'Màu xe'),
              _InfoCell(icon: Icons.settings_outlined, value: '110cc', label: 'Dung tích'),
              _InfoCell(icon: Icons.water_drop_outlined, value: 'RON 95', label: 'Loại xăng'),
            ],
          ),

          const SizedBox(height: 4),
          _SectionTitle('Giấy tờ & hạn'),

          _DocCard(icon: Icons.badge_outlined, title: 'Đăng kiểm', sub: 'Hết hạn: 15/12/2024', badge: 'Sắp hết', badgeColor: const Color(0xFFE65100), badgeBg: const Color(0xFFFFF3E0)),
          const SizedBox(height: 6),
          _DocCard(icon: Icons.shield_outlined, title: 'Bảo hiểm xe', sub: 'Hết hạn: 01/03/2025', badge: 'Còn hạn', badgeColor: AppColors.primary, badgeBg: const Color(0xFFE8F5E9)),
          const SizedBox(height: 6),
          _DocCard(icon: Icons.description_outlined, title: 'Đăng ký xe', sub: 'Vĩnh viễn', badge: 'Hợp lệ', badgeColor: AppColors.primary, badgeBg: const Color(0xFFE8F5E9)),

          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: MotoBottomNavBar(
        currentIndex: 3,
        onTap: (i) {},
        onAddTap: () {},
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
      child: Text(text.toUpperCase(), style: GoogleFonts.beVietnamPro(
        fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 0.4,
      )),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _InfoCell({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600)),
        Text(label, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _DocCard extends StatelessWidget {
  final IconData icon;
  final String title, sub, badge;
  final Color badgeColor, badgeBg;
  const _DocCard({required this.icon, required this.title, required this.sub, required this.badge, required this.badgeColor, required this.badgeBg});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(sub, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(5)),
          child: Text(badge, style: GoogleFonts.beVietnamPro(fontSize: 9, fontWeight: FontWeight.w600, color: badgeColor)),
        ),
      ]),
    );
  }
}
```

---

## 6. Checklist kiểm tra cuối cùng (đã cập nhật)

- [ ] Bottom Nav có đúng **5 ô**: Trang chủ / Lịch sử / **+** (nổi, không label) / Thống kê / Cá nhân
- [ ] Nút **+** giữa nav mở `AddFuelScreen` (hoặc bottom sheet chọn loại nếu nâng cấp)
- [ ] `HistoryScreen` **CHỈ** là lịch sử đổ xăng — có filter chip ngang (Tất cả/Tháng này/Tháng trước/Tuỳ chọn) + empty state "Chưa có lịch sử đổ xăng", **KHÔNG** còn 2 card toggle Xăng/Bảo dưỡng
- [ ] `MaintenanceScreen` vẫn là màn hình riêng, chỉ vào qua Quick Action ở Home, không nằm trong bottom nav
- [ ] `ExpenseScreen` có: thanh chọn tháng, card tổng chi phí xanh đậm, donut chart + legend, list 3 danh mục (Xăng/Bảo dưỡng/Khác)
- [ ] `MyVehicleScreen` có: bike card xanh đậm với vòng trang trí mờ, grid 2x2 thông tin xe, list giấy tờ với badge trạng thái
- [ ] Tất cả màn hình gọi `MotoBottomNavBar` đều có đủ 3 tham số: `currentIndex`, `onTap`, `onAddTap`
- [ ] Toàn bộ dùng nhất quán `AppColors.primary` (#2E7D32), `AppColors.greenChip`, `GoogleFonts.beVietnamPro`

---

**Lưu ý cho AI code (Antigravity):** File này (`MOTOLOG_SPEC_FULL_V2.md`) thay thế hoàn toàn `MOTOLOG_SPEC_FULL.md` và mọi spec trước đó. Đặc biệt lưu ý 2 lỗi đã sửa ở đầu file (Bottom Nav 5 ô + History Screen đơn giản hoá).
