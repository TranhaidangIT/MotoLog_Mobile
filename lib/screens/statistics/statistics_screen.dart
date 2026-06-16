import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/fuel_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/vehicle_provider.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedVehicleIdProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            title: const Text('Thống kê'),
            bottom: TabBar(
              controller: _tabCtrl,
              tabs: const [
                Tab(text: 'Tháng'),
                Tab(text: 'Quý'),
                Tab(text: 'Năm'),
              ],
            ),
          ),
          if (selectedId == null)
            const SliverFillRemaining(
              child: Center(child: Text('Chọn xe để xem thống kê')),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _CostBarChart(vehicleId: selectedId),
                    const SizedBox(height: 24),
                    _SummarySection(vehicleId: selectedId),
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

class _CostBarChart extends ConsumerWidget {
  final String vehicleId;

  const _CostBarChart({required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelDataAsync = ref.watch(fuelMonthlyCostsProvider(vehicleId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chi phí theo tháng',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          '6 tháng gần nhất',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),

        fuelDataAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (e, _) => const SizedBox(),
          data: (fuelData) {
            if (fuelData.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text('Chưa có dữ liệu'),
                ),
              );
            }

            final reversed = fuelData.reversed.toList();
            final maxCost = reversed.fold<double>(
              0,
              (max, d) => (d['cost'] as num? ?? 0).toDouble() > max
                  ? (d['cost'] as num).toDouble()
                  : max,
            );

            return Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxCost * 1.3,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.primary,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          AppFormatters.currency(rod.toY),
                          const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= reversed.length) {
                            return const SizedBox();
                          }
                          final month = reversed[i]['month'] as String? ?? '';
                          final parts = month.split('-');
                          return Text(
                            parts.length >= 2 ? 'T${parts[1]}' : month,
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        getTitlesWidget: (value, _) => Text(
                          value >= 1000000
                              ? '${(value / 1000000).toStringAsFixed(1)}M'
                              : value >= 1000
                                  ? '${(value / 1000).toStringAsFixed(0)}k'
                                  : value.toStringAsFixed(0),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxCost > 0 ? maxCost / 4 : 100000,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: Theme.of(context).dividerColor,
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: reversed.asMap().entries.map((e) {
                    final cost = (e.value['cost'] as num? ?? 0).toDouble();
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: cost,
                          color: AppColors.primary,
                          width: 18,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: maxCost * 1.3,
                            color: AppColors.primary.withOpacity(0.06),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),

        // Legend
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _Legend(color: AppColors.primary, label: 'Tiền xăng'),
            const SizedBox(width: 20),
            _Legend(color: AppColors.secondary, label: 'Bảo dưỡng'),
          ],
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
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _SummarySection extends ConsumerWidget {
  final String vehicleId;

  const _SummarySection({required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelCostAsync = ref.watch(fuelCostThisMonthProvider(vehicleId));
    final maintCostAsync = ref.watch(maintenanceCostThisMonthProvider(vehicleId));
    final fuelLitersAsync = ref.watch(fuelLitersThisMonthProvider(vehicleId));
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tóm tắt tháng này',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        _SummaryRow(
          icon: Icons.local_gas_station_rounded,
          iconColor: AppColors.fuelGasoline,
          label: 'Tiền xăng',
          valueAsync: fuelCostAsync,
          format: AppFormatters.currency,
        ),
        _SummaryRow(
          icon: Icons.build_rounded,
          iconColor: AppColors.secondary,
          label: 'Chi phí bảo dưỡng',
          valueAsync: maintCostAsync,
          format: AppFormatters.currency,
        ),
        _SummaryRow(
          icon: Icons.opacity_rounded,
          iconColor: AppColors.warning,
          label: 'Tổng lít xăng',
          valueAsync: fuelLitersAsync,
          format: AppFormatters.liters,
        ),
        vehiclesAsync.when(
          data: (vehicles) {
            final v = vehicles.where((x) => x.id == vehicleId).firstOrNull;
            if (v == null) return const SizedBox();
            return _SummaryRow(
              icon: Icons.speed_rounded,
              iconColor: AppColors.success,
              label: 'Odometer hiện tại',
              value: AppFormatters.km(v.odometer),
            );
          },
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final AsyncValue<double>? valueAsync;
  final String Function(double)? format;

  const _SummaryRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.valueAsync,
    this.format,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          valueAsync != null
              ? valueAsync!.when(
                  data: (v) => Text(
                    format != null ? format!(v) : v.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  loading: () => const SizedBox(
                    width: 60,
                    height: 16,
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, __) => const Text('—'),
                )
              : Text(
                  value ?? '—',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
        ],
      ),
    );
  }
}
