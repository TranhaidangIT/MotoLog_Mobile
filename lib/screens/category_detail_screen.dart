import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/vehicle_provider.dart';
import '../providers/fuel_provider.dart';
import '../providers/maintenance_provider.dart';
import '../data/models/maintenance_entry.dart';

enum ExpenseCategory { fuel, maintenance, other }

class _CategoryStyle {
  final String title;
  final Color color;
  final Color bgLight;
  final IconData icon;
  const _CategoryStyle({required this.title, required this.color, required this.bgLight, required this.icon});
}

const _styles = {
  ExpenseCategory.fuel: _CategoryStyle(
    title: 'Chi phí xăng', color: AppColors.primary, bgLight: Color(0xFFE8F5E9), icon: Icons.local_gas_station,
  ),
  ExpenseCategory.maintenance: _CategoryStyle(
    title: 'Chi phí bảo dưỡng', color: Color(0xFFE65100), bgLight: Color(0xFFFFF3E0), icon: Icons.build,
  ),
  ExpenseCategory.other: _CategoryStyle(
    title: 'Chi phí khác', color: Color(0xFF1565C0), bgLight: Color(0xFFE3F2FD), icon: Icons.more_horiz,
  ),
};

/// Màn hình Chi tiết Danh mục Chi phí
/// Hiển thị biểu đồ xu hướng và danh sách giao dịch theo từng danh mục (Xăng, Bảo dưỡng, Khác).
class CategoryDetailScreen extends ConsumerStatefulWidget {
  final ExpenseCategory category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  ConsumerState<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends ConsumerState<CategoryDetailScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final style = _styles[widget.category]!;
    final vehicleId = ref.watch(selectedVehicleIdProvider);

    if (vehicleId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(style.title), leading: const BackButton()),
        body: const Center(child: Text('Vui lòng chọn xe trước')),
      );
    }

    final from = DateTime(_month.year, _month.month, 1);
    final nextMonth = DateTime(_month.year, _month.month + 1, 1);
    final to = nextMonth.subtract(const Duration(seconds: 1));

    List<double> weeklyData = [0, 0, 0, 0];
    List<Map<String, String>> transactions = [];
    double totalCost = 0;
    
    int stat1 = 0;
    double stat2 = 0;
    double stat3 = 0;
    String stat2String = '0';
    String stat3String = '0 đ';

    if (widget.category == ExpenseCategory.fuel) {
      final asyncData = ref.watch(fuelListByMonthProvider((vehicleId: vehicleId, from: from, to: to)));
      final entries = asyncData.valueOrNull ?? [];
      
      for (var e in entries) {
        totalCost += e.totalCost;
        stat1++;
        stat2 += e.liters;
        
        int weekIndex = ((e.date.day - 1) ~/ 7);
        if (weekIndex > 3) weekIndex = 3;
        weeklyData[weekIndex] += e.totalCost;
        
        transactions.add({
          'title': e.stationName != null && e.stationName!.isNotEmpty ? e.stationName! : 'Đổ xăng tại ODO ${e.odometer} km',
          'subtitle': e.stationAddress ?? '',
          'amount': '${NumberFormat('#,###', 'vi_VN').format(e.totalCost)} đ',
          'date': e.date.toIso8601String(),
        });
      }
      
      stat2String = '${stat2.toStringAsFixed(1)} lít';
      stat3 = stat2 > 0 ? totalCost / stat2 : 0; // Giá TB/lít
      stat3String = '${NumberFormat('#,###', 'vi_VN').format(stat3)} đ';
    } else if (widget.category == ExpenseCategory.maintenance) {
      final asyncData = ref.watch(maintenanceListByMonthProvider((vehicleId: vehicleId, from: from, to: to)));
      final entries = asyncData.valueOrNull ?? [];
      
      Map<MaintenanceType, int> typeCount = {};
      
      for (var e in entries) {
        totalCost += e.cost;
        stat1++;
        typeCount[e.type] = (typeCount[e.type] ?? 0) + 1;
        
        int weekIndex = ((e.date.day - 1) ~/ 7);
        if (weekIndex > 3) weekIndex = 3;
        weeklyData[weekIndex] += e.cost;
        
        transactions.add({
          'title': e.title.isNotEmpty ? e.title : (e.type == MaintenanceType.parts ? 'Thay phụ tùng' : 'Bảo dưỡng'),
          'amount': '${NumberFormat('#,###', 'vi_VN').format(e.cost)} đ',
          'date': e.date.toIso8601String(),
        });
      }
      
      String mostFrequentType = '—';
      if (typeCount.isNotEmpty) {
        var topType = typeCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        mostFrequentType = topType == MaintenanceType.parts ? 'Phụ tùng' : (topType == MaintenanceType.repair ? 'Sửa chữa' : 'Định kỳ');
      }
      stat2String = mostFrequentType;
      
      stat3 = stat1 > 0 ? totalCost / stat1 : 0; // Chi phí trung bình / lần
      stat3String = '${NumberFormat('#,###', 'vi_VN').format(stat3)} đ';
    }

    // Sắp xếp lịch sử giao dịch từ mới nhất đến cũ nhất
    transactions.sort((a, b) => DateTime.parse(b['date']!).compareTo(DateTime.parse(a['date']!)));

    return Scaffold(
      appBar: AppBar(title: Text(style.title), leading: const BackButton()),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Header lớn ──
          Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
            decoration: BoxDecoration(color: style.color),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                IconButton(
                  onPressed: () => setState(() => _month = DateTime(_month.year, _month.month - 1)),
                  icon: const Icon(Icons.chevron_left, color: Colors.white),
                ),
                Text('Tháng ${_month.month}/${_month.year}', style: GoogleFonts.beVietnamPro(fontSize: 13, color: Colors.white)),
                IconButton(
                  onPressed: () => setState(() => _month = DateTime(_month.year, _month.month + 1)),
                  icon: const Icon(Icons.chevron_right, color: Colors.white),
                ),
              ]),
              const SizedBox(height: 6),
              Text('Tổng chi phí', style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.white.withOpacity(0.8))),
              const SizedBox(height: 2),
              Text('${NumberFormat('#,###', 'vi_VN').format(totalCost)} đ', style: GoogleFonts.beVietnamPro(fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('Dữ liệu thống kê tháng', style: GoogleFonts.beVietnamPro(fontSize: 11, color: Colors.white)),
              ),
            ]),
          ),

          // ── Grid 3 ô thống kê nhanh — nổi lên đè mép dưới header ──
          Transform.translate(
            offset: const Offset(0, -16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Row(children: _quickStats(widget.category, stat1.toString(), stat2String, stat3String).map((s) => Expanded(
                  child: Column(children: [
                    Icon(s.icon, size: 18, color: style.color),
                    const SizedBox(height: 4),
                    Text(s.value, style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w700)),
                    Text(s.label, style: GoogleFonts.beVietnamPro(fontSize: 9, color: AppColors.textSecondary), textAlign: TextAlign.center),
                  ]),
                )).toList()),
              ),
            ),
          ),

          // ── Biểu đồ xu hướng theo tuần ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Xu hướng chi tiêu theo tuần', style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                SizedBox(
                  height: 100,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(weeklyData.length, (i) {
                      final maxVal = weeklyData.isEmpty ? 0 : weeklyData.reduce((a, b) => a > b ? a : b);
                      final h = maxVal == 0 ? 4.0 : (weeklyData[i] / maxVal) * 80 + 4;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Column(children: [
                            Expanded(child: Align(alignment: Alignment.bottomCenter, child: Container(
                              height: h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter,
                                  colors: [style.color, style.color.withOpacity(0.5)]),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ))),
                            const SizedBox(height: 6),
                            Text('Tuần ${i + 1}', style: GoogleFonts.beVietnamPro(fontSize: 9, color: AppColors.textSecondary)),
                          ]),
                        ),
                      );
                    }),
                  ),
                ),
              ]),
            ),
          ),

          // ── List giao dịch chi tiết ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: Text('Lịch sử giao dịch', style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(children: [
                Icon(style.icon, size: 36, color: style.color.withOpacity(0.3)),
                const SizedBox(height: 8),
                Text('Chưa có giao dịch nào trong tháng này',
                  style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
              ]),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(children: transactions.map((t) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Row(children: [
                  Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(color: style.bgLight, borderRadius: BorderRadius.circular(9)),
                    child: Icon(style.icon, color: style.color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t['title'] ?? '', style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600)),
                      if (t['subtitle'] != null && t['subtitle']!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(t['subtitle']!, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                      Text(DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(t['date']!)), style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  )),
                  Text(t['amount'] ?? '', style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w700, color: style.color)),
                ]),
              )).toList()),
            ),

          const SizedBox(height: 16),

          // ── Nút thêm nhanh ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Điều hướng
                  if (widget.category == ExpenseCategory.fuel) {
                    Navigator.pushNamed(context, '/fuel-log');
                  } else {
                    Navigator.pushNamed(context, '/maintenance');
                  }
                },
                icon: Icon(Icons.add, color: style.color),
                label: Text('Thêm ${style.title.replaceFirst('Chi phí ', '')}',
                  style: GoogleFonts.beVietnamPro(color: style.color, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: style.color),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat {
  final IconData icon;
  final String value, label;
  const _QuickStat(this.icon, this.value, this.label);
}

List<_QuickStat> _quickStats(ExpenseCategory category, String val1, String val2, String val3) {
  switch (category) {
    case ExpenseCategory.fuel:
      return [
        _QuickStat(Icons.local_gas_station, val1, 'Lần đổ'),
        _QuickStat(Icons.water_drop_outlined, val2, 'Tổng lít'),
        _QuickStat(Icons.attach_money, val3, 'Giá TB/lít'),
      ];
    case ExpenseCategory.maintenance:
      return [
        _QuickStat(Icons.build, val1, 'Số lần'),
        _QuickStat(Icons.star_outline, val2, 'Loại nhiều nhất'),
        _QuickStat(Icons.attach_money, val3, 'TB/lần'),
      ];
    case ExpenseCategory.other:
      return [
        _QuickStat(Icons.receipt_long_outlined, val1, 'Số khoản'),
        _QuickStat(Icons.category_outlined, val2, 'Loại nhiều nhất'),
        _QuickStat(Icons.attach_money, val3, 'TB/khoản'),
      ];
  }
}
