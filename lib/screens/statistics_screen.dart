import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/fuel_provider.dart';
import '../providers/maintenance_provider.dart';
import '../providers/vehicle_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  @override
  Widget build(BuildContext context) {
    final vehicleId = ref.watch(selectedVehicleIdProvider);
    final currencyFormat = NumberFormat('#,###');

    if (vehicleId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thống kê')),
        body: const Center(child: Text('Vui lòng chọn xe trước')),
        bottomNavigationBar: MotoBottomNavBar(
          currentIndex: 2, 
          onTap: (i) {
            if (i == 0) { context.go('/home'); }
            else if (i == 1) { context.go('/fuel-history'); }
            else if (i == 3) { context.go('/profile'); }
          },
          onAddTap: () => context.push('/fuel-log'),
        ),
      );
    }

    final fuelCostAsync = ref.watch(fuelCostThisMonthProvider(vehicleId));
    final maintCostAsync = ref.watch(maintenanceCostThisMonthProvider(vehicleId));
    final avgConsumptionAsync = ref.watch(fuelLitersThisMonthProvider(vehicleId));

    final fuelCost = fuelCostAsync.valueOrNull ?? 0.0;
    final maintCost = maintCostAsync.valueOrNull ?? 0.0;
    final total = fuelCost + maintCost;
    
    // Tính toán %
    double fuelPercent = total > 0 ? (fuelCost / total * 100) : 0;
    double maintPercent = total > 0 ? (maintCost / total * 100) : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê chi phí'),
        leading: BackButton(onPressed: () => context.go('/home')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(children: [
          // Month selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tháng ${DateTime.now().month}/${DateTime.now().year}', style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Total + Pie chart card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Tổng chi phí', style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary)),
                    Text('${currencyFormat.format(total)} đ', style: GoogleFonts.beVietnamPro(fontSize: 26, fontWeight: FontWeight.w800)),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.greenChip,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      const Icon(Icons.arrow_downward, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text('0%', style: GoogleFonts.beVietnamPro(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              ),
              Text('so với tháng trước', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 20),

              // Donut chart + legend
              Row(children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(value: fuelPercent == 0 ? 1 : fuelPercent, color: AppColors.primary, radius: 40, showTitle: false),
                        PieChartSectionData(value: maintPercent, color: AppColors.fuelOrange, radius: 40, showTitle: false),
                        PieChartSectionData(value: total == 0 ? 99 : 0, color: AppColors.divider, radius: 40, showTitle: false),
                      ],
                      centerSpaceRadius: 28,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _LegendItem(color: AppColors.primary, label: 'Xăng', amount: '${currencyFormat.format(fuelCost)} đ (${fuelPercent.toStringAsFixed(1)}%)'),
                  const SizedBox(height: 10),
                  _LegendItem(color: AppColors.fuelOrange, label: 'Bảo dưỡng', amount: '${currencyFormat.format(maintCost)} đ (${maintPercent.toStringAsFixed(1)}%)'),
                  const SizedBox(height: 10),
                  _LegendItem(color: AppColors.divider, label: 'Khác', amount: '0 đ (0%)'),
                ]),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // Bar chart – fuel cost
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Chi phí xăng', style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('${currencyFormat.format(fuelCost)} đ', style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: BarChart(
                  BarChartData(
                    maxY: 320,
                    barGroups: _buildBarGroups(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const labels = ['1/6', '8/6', '15/6', '22/6', '30/6'];
                            final i = v.toInt();
                            return i < labels.length
                              ? Text(labels[i], style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary))
                              : const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          interval: 100,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}k',
                            style: GoogleFonts.beVietnamPro(fontSize: 9, color: AppColors.textSecondary)),
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(color: AppColors.divider, strokeWidth: 0.5),
                    ),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(enabled: false),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Consumption summary
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Tổng lít xăng (tháng này)', style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('${avgConsumptionAsync.valueOrNull?.toStringAsFixed(1) ?? "0"} lít', style: GoogleFonts.beVietnamPro(fontSize: 22, fontWeight: FontWeight.w800)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
      bottomNavigationBar: MotoBottomNavBar(
        currentIndex: 2, 
        onTap: (i) {
          if (i == 0) { context.go('/home'); }
          else if (i == 1) { context.go('/fuel-history'); }
          else if (i == 3) { context.go('/profile'); }
        },
        onAddTap: () => context.push('/fuel-log'),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final values = [75.0, 90.0, 70.0, 80.0, 0.0];
    return List.generate(values.length, (i) => BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: values[i],
          color: values[i] > 0 ? AppColors.primary : Colors.transparent,
          width: 18,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    ));
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;
  const _LegendItem({required this.color, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w500)),
        Text(amount, style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    ]);
  }
}
