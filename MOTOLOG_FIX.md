# MotoLog – Danh sách lỗi cần sửa

> Dựa trên screenshot thực tế so với spec. Chỉ sửa đúng những gì liệt kê dưới đây, không thay đổi gì khác.

---

## Fix 1 – Home Screen: Quick action grid

**Vấn đề:** Ô thứ 3 đang hiện "Lịch sử" thay vì đúng theo thiết kế.

**Yêu cầu:** 6 quick action theo đúng thứ tự sau (trái → phải, trên → dưới):

| Vị trí | Icon | Label | Screen |
|--------|------|-------|--------|
| 1 | `Icons.local_gas_station` | Đổ xăng | `FuelLogScreen()` |
| 2 | `Icons.build_outlined` | Bảo dưỡng | `MaintenanceScreen()` |
| 3 | `Icons.account_balance_wallet_outlined` | Chi phí | `null` |
| 4 | `Icons.bar_chart` | Thống kê | `StatisticsScreen()` |
| 5 | `Icons.two_wheeler` | Xe của tôi | `null` |
| 6 | `Icons.notifications_active_outlined` | Nhắc lịch | `ReminderScreen()` |

Xoá bỏ bất kỳ ô "Lịch sử" nào trong quick action grid.

---

## Fix 2 – Bottom Navigation Bar

**Vấn đề:** Tab index 1 đang hiện "Đổ xăng" thay vì "Lịch sử".

**Yêu cầu:** Đổi tab index 1 thành:
```dart
_NavItem(
  icon: Icons.history,
  label: 'Lịch sử',
  index: 1,
  current: currentIndex,
  onTap: onTap,
)
```

Thứ tự 5 tab phải là:
- 0 → Trang chủ (`Icons.home_outlined`)
- 1 → **Lịch sử** (`Icons.history`) ← sửa
- 2 → FAB nút +
- 3 → Thống kê (`Icons.bar_chart_outlined`)
- 4 → Cá nhân (`Icons.person_outline`)

---

## Fix 3 – Home Screen: Điều hướng bottom nav

**Vấn đề:** Bấm tab index 1 đang mở màn hình sai.

**Yêu cầu:** Trong `onTap` của `MotoBottomNavBar` ở `HomeScreen`, sửa:
```dart
// TRƯỚC (sai)
if (i == 1) {
  Navigator.push(...FuelLogScreen()...);
}

// SAU (đúng)
if (i == 1) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
}
```

Đảm bảo đã `import 'history_screen.dart'` ở đầu file.

---

## Fix 4 – History Screen: Layout mỗi item danh sách

**Vấn đề:** Mỗi item chỉ hiện thông tin bên trái, thiếu số tiền và badge km/lít bên phải, thiếu mũi tên.

**Yêu cầu:** Mỗi item trong list (tab Đổ xăng) phải có layout:

```
[Icon tròn]  [Trái: ngày + tên trạm + lít·ODO]  [Phải: số tiền + badge]  [>]
```

Cụ thể:
```dart
Row(children: [
  // Icon
  Container(
    width: 38, height: 38,
    decoration: BoxDecoration(color: AppColors.greenChip, shape: BoxShape.circle),
    child: Icon(Icons.local_gas_station_outlined, color: AppColors.primary, size: 20),
  ),
  const SizedBox(width: 12),

  // Nội dung trái
  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(r['date']!,    style: /* 11px, textSecondary */),
    Text(r['station']!, style: /* 13px, w600, textPrimary */),
    Text('${r['liters']} · ODO ${r['odo']}', style: /* 11px, textSecondary */),
  ])),

  // Nội dung phải
  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
    Text(r['amount']!, style: /* 14px, w700, textPrimary */),
    const SizedBox(height: 4),
    Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.greenChip,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(r['consumption']!, style: /* 11px, w600, primary */),
    ),
  ]),
  const SizedBox(width: 4),
  Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
])
```

---

## Fix 5 – History Screen: Stats bar (tab Đổ xăng)

**Vấn đề:** Stats bar hiện chưa đủ hoặc sai format.

**Yêu cầu:** Hiển thị 3 cột (không cần cột thứ 4 nếu quá chật), ngăn cách bằng Divider dọc:

| Cột | Label | Giá trị |
|-----|-------|---------|
| 1 | Tổng tiền | 680.000 đ |
| 2 | Tổng lít | 27,20 lít |
| 3 | Tiêu hao TB | 58,0 km/lít |

Stats bar chỉ hiện khi `_tab == 0` (tab Đổ xăng), ẩn khi tab Bảo dưỡng.

---

## Không cần sửa

- Màu sắc, font — giữ nguyên
- Logic filter chips — giữ nguyên
- Màn hình Bảo dưỡng, Nhắc lịch, Thống kê, Đổ xăng — giữ nguyên
- AppTheme — giữ nguyên

