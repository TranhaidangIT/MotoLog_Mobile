import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/vehicle_provider.dart';
import '../providers/fuel_provider.dart';
import '../providers/maintenance_provider.dart';
import 'category_detail_screen.dart';

class ExpenseScreen extends ConsumerStatefulWidget {
  const ExpenseScreen({super.key});
  @override
  ConsumerState<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends ConsumerState<ExpenseScreen> {
  DateTime _month = DateTime.now();

  void _changeMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final vehicleId = ref.watch(selectedVehicleIdProvider);
    if (vehicleId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi phí')),
        body: const Center(child: Text('Vui lòng chọn xe trước')),
      );
    }

    final fuelAsync = ref.watch(fuelListProvider);
    final maintAsync = ref.watch(maintenanceListProvider);

    final fuels = fuelAsync.valueOrNull ?? [];
    final maints = maintAsync.valueOrNull ?? [];

    // Lọc theo tháng hiện tại đang chọn
    final currentFuels = fuels.where((e) => e.date.year == _month.year && e.date.month == _month.month).toList();
    final currentMaints = maints.where((e) => e.date.year == _month.year && e.date.month == _month.month).toList();

    double totalFuel = currentFuels.fold(0.0, (sum, e) => sum + e.totalCost);
    double totalLiters = currentFuels.fold(0.0, (sum, e) => sum + e.liters);
    double totalMaint = currentMaints.fold(0.0, (sum, e) => sum + e.cost);
    double total = totalFuel + totalMaint;

    double pFuel = total > 0 ? totalFuel / total : 0;
    double pMaint = total > 0 ? totalMaint / total : 0;

    // So sánh với tháng trước
    final prevMonth = DateTime(_month.year, _month.month - 1);
    final prevFuels = fuels.where((e) => e.date.year == prevMonth.year && e.date.month == prevMonth.month).toList();
    final prevMaints = maints.where((e) => e.date.year == prevMonth.year && e.date.month == prevMonth.month).toList();
    double prevTotal = prevFuels.fold(0.0, (s, e) => s + e.totalCost) + prevMaints.fold(0.0, (s, e) => s + e.cost);

    double diffPercent = 0.0;
    bool isDown = true;
    if (prevTotal > 0) {
      if (total < prevTotal) {
        diffPercent = ((prevTotal - total) / prevTotal) * 100;
        isDown = true;
      } else {
        diffPercent = ((total - prevTotal) / prevTotal) * 100;
        isDown = false;
      }
    } else {
      diffPercent = total > 0 ? 100 : 0;
      isDown = false;
    }

    final fmt = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Chi phí'), leading: BackButton(onPressed: () => context.go('/home'))),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Month selector
          Container(color: AppColors.surface,
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
              Text('Tổng chi phí tháng này', style: GoogleFonts.beVietnamPro(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
              const SizedBox(height: 2),
              Text('${fmt.format(total)} đ', style: GoogleFonts.beVietnamPro(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 6),
              if (prevTotal > 0 || total > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isDown ? AppColors.greenChip : const Color(0xFFEF5350).withValues(alpha: 0.2), 
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(isDown ? Icons.arrow_downward : Icons.arrow_upward, size: 10, color: Colors.white),
                    const SizedBox(width: 3),
                    Text('${isDown ? 'Giảm' : 'Tăng'} ${diffPercent.toStringAsFixed(1)}% so với tháng trước', 
                      style: GoogleFonts.beVietnamPro(fontSize: 10, color: Colors.white)),
                  ]),
                ),
            ]),
          ),

          // Donut + legend
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
            ),
            child: Row(children: [
              SizedBox(
                width: 72, height: 72,
                child: CustomPaint(painter: _DonutPainter(segments: [pFuel, pMaint, total == 0 ? 1.0 : 0.0])),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _LegendRow(color: AppColors.primary, name: 'Xăng', value: '${fmt.format(totalFuel)}đ (${(pFuel * 100).toStringAsFixed(1)}%)'),
                const SizedBox(height: 5),
                _LegendRow(color: const Color(0xFFFF6F00), name: 'Bảo dưỡng', value: '${fmt.format(totalMaint)}đ (${(pMaint * 100).toStringAsFixed(1)}%)'),
                const SizedBox(height: 5),
                _LegendRow(color: const Color(0xFFE0E0E0), name: 'Khác', value: '0 đ'),
              ])),
            ]),
          ),

          // Category list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const CategoryDetailScreen(category: ExpenseCategory.fuel),
                )),
                child: _CostCard(
                  icon: Icons.local_gas_station, iconBg: const Color(0xFFE8F5E9), iconColor: AppColors.primary,
                  title: 'Xăng', 
                  sub: '${currentFuels.length} lần đổ · ${totalLiters.toStringAsFixed(1)} lít', 
                  amount: '${fmt.format(totalFuel)} đ', 
                  percent: '${(pFuel * 100).toStringAsFixed(1)}%',
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const CategoryDetailScreen(category: ExpenseCategory.maintenance),
                )),
                child: _CostCard(
                  icon: Icons.build, iconBg: const Color(0xFFFFF3E0), iconColor: const Color(0xFFE65100),
                  title: 'Bảo dưỡng', 
                  sub: '${currentMaints.length} lần bảo dưỡng', 
                  amount: '${fmt.format(totalMaint)} đ', 
                  percent: '${(pMaint * 100).toStringAsFixed(1)}%',
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const CategoryDetailScreen(category: ExpenseCategory.other),
                )),
                child: const _CostCard(
                  icon: Icons.more_horiz, iconBg: Color(0xFFE3F2FD), iconColor: Color(0xFF1565C0),
                  title: 'Khác', sub: 'Chưa có chi phí', amount: '0 đ', percent: '0%', dim: true,
                ),
              ),
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
      if (segments[i] <= 0) continue;
      final sweep = segments[i] * 2 * pi;
      final paint = Paint()
        ..color = _colors[i]
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
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
