import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/fuel_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/vehicle_provider.dart';

// Time filter options
enum _TimeFilter { month1, month3, month6, year1 }

extension _TimeFilterExt on _TimeFilter {
  String get label {
    switch (this) {
      case _TimeFilter.month1:
        return '1M';
      case _TimeFilter.month3:
        return '3M';
      case _TimeFilter.month6:
        return '6M';
      case _TimeFilter.year1:
        return '1Y';
    }
  }

  int get months {
    switch (this) {
      case _TimeFilter.month1:
        return 1;
      case _TimeFilter.month3:
        return 3;
      case _TimeFilter.month6:
        return 6;
      case _TimeFilter.year1:
        return 12;
    }
  }
}

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  _TimeFilter _selectedFilter = _TimeFilter.month6;

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedVehicleIdProvider);
    final fuelDataAsync = selectedId != null
        ? ref.watch(fuelMonthlyCostsProvider(selectedId))
        : null;
    final maintDataAsync = selectedId != null
        ? ref.watch(maintenanceMonthlyCostsProvider(selectedId))
        : null;

    double grandTotal = 0;
    if (fuelDataAsync != null && maintDataAsync != null) {
      fuelDataAsync.maybeWhen(
        data: (fuelList) {
          final now = DateTime.now();
          final chartMonths = <String>[];
          for (int i = _selectedFilter.months - 1; i >= 0; i--) {
            final d = DateTime(now.year, now.month - i, 1);
            chartMonths.add('${d.year}-${d.month.toString().padLeft(2, '0')}');
          }
          final fuelMap = {
            for (final d in fuelList)
              d['month'] as String: (d['cost'] as num).toDouble()
          };
          for (final m in chartMonths) {
            grandTotal += fuelMap[m] ?? 0;
          }
        },
        orElse: () {},
      );

      maintDataAsync.maybeWhen(
        data: (maintList) {
          final now = DateTime.now();
          final chartMonths = <String>[];
          for (int i = _selectedFilter.months - 1; i >= 0; i--) {
            final d = DateTime(now.year, now.month - i, 1);
            chartMonths.add('${d.year}-${d.month.toString().padLeft(2, '0')}');
          }
          final maintMap = {
            for (final d in maintList)
              d['month'] as String: (d['cost'] as num).toDouble()
          };
          for (final m in chartMonths) {
            grandTotal += maintMap[m] ?? 0;
          }
        },
        orElse: () {},
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── APP BAR ───
          SliverAppBar(
            floating: true,
            snap: true,
            centerTitle: true,
            backgroundColor: AppColors.backgroundLight,
            elevation: 0,
            leading: Navigator.of(context).canPop()
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimaryLight),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                : null,
            title: Text(
              'Thống kê',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),

          if (selectedId == null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bar_chart_rounded,
                        size: 60, color: AppColors.textHintLight),
                    const SizedBox(height: 12),
                    Text(
                      'Chọn xe để xem thống kê',
                      style: GoogleFonts.outfit(
                          fontSize: 15, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),

                    // ─── TIME FILTER CHIPS ───
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: _TimeFilter.values.map((f) {
                          final isActive = f == _selectedFilter;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedFilter = f),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(9),
                                ),
                                child: Text(
                                  f.label,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: isActive
                                        ? Colors.white
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── GRAND TOTAL DISPLAY ───
                    _GrandTotalDisplay(
                      amount: grandTotal,
                      filter: _selectedFilter,
                    ),
                    const SizedBox(height: 20),

                    // ─── DOUBLE BAR CHART ───
                    _DoubleBarChart(
                      vehicleId: selectedId,
                      months: _selectedFilter.months,
                    ),
                    const SizedBox(height: 24),

                    // ─── PERIOD SUMMARY FOOTER (Side-by-side total & average) ───
                    _PeriodSummaryFooter(
                      totalCost: grandTotal,
                      months: _selectedFilter.months,
                    ),
                    const SizedBox(height: 24),

                    // ─── SUMMARY CARDS ───
                    _SummaryCards(vehicleId: selectedId),
                    const SizedBox(height: 24),

                    // ─── DETAIL ROWS ───
                    _DetailSection(vehicleId: selectedId),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Grand Total Display ──
class _GrandTotalDisplay extends StatelessWidget {
  final double amount;
  final _TimeFilter filter;

  const _GrandTotalDisplay({required this.amount, required this.filter});

  @override
  Widget build(BuildContext context) {
    String periodText = 'kỳ trước';
    switch (filter) {
      case _TimeFilter.month1:
        periodText = 'tháng trước';
        break;
      case _TimeFilter.month3:
        periodText = '3 tháng trước';
        break;
      case _TimeFilter.month6:
        periodText = '6 tháng trước';
        break;
      case _TimeFilter.year1:
        periodText = 'năm trước';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng chi tiêu',
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              AppFormatters.currency(amount),
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.trending_up_rounded,
                    color: AppColors.primary,
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '+8%',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'so với $periodText',
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: AppColors.textHintLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Period Summary Footer ──
class _PeriodSummaryFooter extends StatelessWidget {
  final double totalCost;
  final int months;

  const _PeriodSummaryFooter({required this.totalCost, required this.months});

  @override
  Widget build(BuildContext context) {
    final average = totalCost / (months > 0 ? months : 1);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng chi phí',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppFormatters.currency(totalCost),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trung bình / tháng',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppFormatters.currency(average),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Double Bar Chart ──
class _DoubleBarChart extends ConsumerWidget {
  final String vehicleId;
  final int months;

  const _DoubleBarChart({required this.vehicleId, required this.months});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelDataAsync = ref.watch(fuelMonthlyCostsProvider(vehicleId));
    final maintDataAsync =
        ref.watch(maintenanceMonthlyCostsProvider(vehicleId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi phí theo tháng',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${months == 12 ? '12' : months} tháng gần nhất',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 16),
        fuelDataAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          error: (_, __) => const SizedBox(),
          data: (fuelData) {
            return maintDataAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
              error: (_, __) => const SizedBox(),
              data: (maintData) {
                if (fuelData.isEmpty && maintData.isEmpty) {
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Center(
                      child: Text(
                        'Chưa có dữ liệu',
                        style: GoogleFonts.outfit(
                          color: AppColors.textHintLight,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }

                // Build merged months map
                final now = DateTime.now();
                final chartMonths = <String>[];
                for (int i = months - 1; i >= 0; i--) {
                  final d = DateTime(now.year, now.month - i, 1);
                  chartMonths
                      .add('${d.year}-${d.month.toString().padLeft(2, '0')}');
                }

                final fuelMap = {
                  for (final d in fuelData)
                    d['month'] as String: (d['cost'] as num).toDouble()
                };
                final maintMap = {
                  for (final d in maintData)
                    d['month'] as String: (d['cost'] as num).toDouble()
                };

                double maxY = 0;
                for (final m in chartMonths) {
                  final fuel = fuelMap[m] ?? 0;
                  final maint = maintMap[m] ?? 0;
                  if (fuel > maxY) maxY = fuel;
                  if (maint > maxY) maxY = maint;
                }
                if (maxY == 0) maxY = 500000;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(12, 20, 12, 12),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: maxY * 1.25,
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                getTooltipColor: (_) =>
                                    AppColors.textPrimaryLight,
                                getTooltipItem:
                                    (group, groupIndex, rod, rodIndex) {
                                  final m = chartMonths[group.x.toInt()];
                                  final fuel = fuelMap[m] ?? 0;
                                  final maint = maintMap[m] ?? 0;
                                  return BarTooltipItem(
                                    '${rodIndex == 0 ? "Xăng" : "BD"}\n${AppFormatters.currency(rodIndex == 0 ? fuel : maint)}',
                                    GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  getTitlesWidget: (value, _) {
                                    final i = value.toInt();
                                    if (i < 0 || i >= chartMonths.length) {
                                      return const SizedBox();
                                    }
                                    final parts = chartMonths[i].split('-');
                                    return Text(
                                      parts.length >= 2 ? 'T${parts[1]}' : '',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        color: AppColors.textHintLight,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 52,
                                  getTitlesWidget: (value, _) => Text(
                                    value >= 1000000
                                        ? '${(value / 1000000).toStringAsFixed(1)}M'
                                        : value >= 1000
                                            ? '${(value / 1000).toStringAsFixed(0)}k'
                                            : value.toStringAsFixed(0),
                                    style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        color: AppColors.textHintLight),
                                  ),
                                ),
                              ),
                              rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: maxY > 0 ? maxY / 4 : 100000,
                              getDrawingHorizontalLine: (_) => const FlLine(
                                color: AppColors.borderLight,
                                strokeWidth: 1,
                                dashArray: [4, 4],
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: chartMonths.asMap().entries.map((e) {
                              final m = e.value;
                              final fuel = fuelMap[m] ?? 0;
                              final maint = maintMap[m] ?? 0;
                              return BarChartGroupData(
                                x: e.key,
                                barRods: [
                                  // Fuel bar (gasoline)
                                  BarChartRodData(
                                    toY: fuel,
                                    color: AppColors.primary,
                                    width: months <= 3
                                        ? 12
                                        : months <= 6
                                            ? 8
                                            : 6,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                  ),
                                  // Maint bar (maintenance)
                                  BarChartRodData(
                                    toY: maint,
                                    color: AppColors.secondary,
                                    width: months <= 3
                                        ? 12
                                        : months <= 6
                                            ? 8
                                            : 6,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4)),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                      // Legend
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _Legend(color: AppColors.primary, label: 'Tiền xăng'),
                          SizedBox(width: 24),
                          _Legend(
                              color: AppColors.secondary, label: 'Bảo dưỡng'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;

  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.outfit(
              fontSize: 12, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
//  SUMMARY CARDS
// ══════════════════════════════════════════════
class _SummaryCards extends ConsumerWidget {
  final String vehicleId;

  const _SummaryCards({required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelCostAsync = ref.watch(fuelCostThisMonthProvider(vehicleId));
    final maintCostAsync =
        ref.watch(maintenanceCostThisMonthProvider(vehicleId));
    final fuelLitersAsync = ref.watch(fuelLitersThisMonthProvider(vehicleId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tóm tắt tháng này',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _SummaryRow(
                icon: Icons.local_gas_station_rounded,
                iconBg: AppColors.fuelBg,
                iconColor: AppColors.fuelText,
                label: 'Tiền xăng tháng này',
                valueAsync: fuelCostAsync,
                format: AppFormatters.currency,
                isFirst: true,
              ),
              const Divider(
                  height: 1,
                  indent: 68,
                  endIndent: 16,
                  color: AppColors.borderLight),
              _SummaryRow(
                icon: Icons.build_rounded,
                iconBg: AppColors.maintBg,
                iconColor: AppColors.maintText,
                label: 'Chi phí bảo dưỡng',
                valueAsync: maintCostAsync,
                format: AppFormatters.currency,
              ),
              const Divider(
                  height: 1,
                  indent: 68,
                  endIndent: 16,
                  color: AppColors.borderLight),
              _SummaryRow(
                icon: Icons.opacity_rounded,
                iconBg: const Color(0xFFEFF6FF),
                iconColor: const Color(0xFF1D4ED8),
                label: 'Tổng lít xăng',
                valueAsync: fuelLitersAsync,
                format: AppFormatters.liters,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final AsyncValue<double>? valueAsync;
  final String Function(double)? format;
  final bool isFirst;
  final bool isLast;

  const _SummaryRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    this.valueAsync,
    this.format,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ),
          if (valueAsync != null)
            valueAsync!.when(
              data: (v) => Text(
                format != null ? format!(v) : v.toString(),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              loading: () => Container(
                height: 14,
                width: 60,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              error: (_, __) => const Text('—'),
            )
          else
            const Text('—'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  DETAIL SECTION (insight tips)
// ══════════════════════════════════════════════
class _DetailSection extends ConsumerWidget {
  final String vehicleId;

  const _DetailSection({required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);

    return vehiclesAsync.when(
      data: (vehicles) {
        final v = vehicles.where((x) => x.id == vehicleId).firstOrNull;
        if (v == null) return const SizedBox();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin xe',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.fuelBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.speed_rounded,
                        color: AppColors.fuelText, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Odometer hiện tại',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        AppFormatters.km(v.odometer),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }
}
