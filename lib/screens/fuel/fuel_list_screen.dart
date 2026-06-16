import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/fuel_entry.dart';
import '../../providers/fuel_provider.dart';
import '../../providers/vehicle_provider.dart';

class FuelListScreen extends ConsumerWidget {
  const FuelListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelAsync = ref.watch(fuelListProvider);
    final selectedId = ref.watch(selectedVehicleIdProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Nhật ký xăng'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () {},
              ),
            ],
          ),
          if (selectedId == null)
            const SliverFillRemaining(
              child: Center(child: Text('Chọn xe để xem nhật ký xăng')),
            )
          else
            fuelAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Lỗi: $e')),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyFuelState(),
                  );
                }

                // Group by month
                final grouped = <String, List<FuelEntry>>{};
                for (final entry in list) {
                  final key = AppFormatters.monthYear(entry.date);
                  grouped.putIfAbsent(key, () => []).add(entry);
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final keys = grouped.keys.toList();
                      final monthKey = keys[index];
                      final entries = grouped[monthKey]!;
                      final totalCost = entries.fold<double>(
                          0, (sum, e) => sum + e.totalCost);
                      final totalLiters =
                          entries.fold<double>(0, (sum, e) => sum + e.liters);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tháng $monthKey',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      AppFormatters.currency(totalCost),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
                                          ?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    Text(
                                      AppFormatters.liters(totalLiters),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Entries
                          ...entries.asMap().entries.map((e) {
                            final entry = e.value;
                            final prev = e.key < entries.length - 1
                                ? entries[e.key + 1]
                                : null;
                            final consumption =
                                entry.consumptionWith(prev);

                            return _FuelEntryCard(
                              entry: entry,
                              consumption: consumption,
                              onTap: () => context.push(
                                  '/home/fuel/${entry.id}/edit'),
                              onDelete: () async {
                                await ref
                                    .read(fuelNotifierProvider.notifier)
                                    .delete(entry.id);
                              },
                            );
                          }),
                        ],
                      );
                    },
                    childCount: grouped.length,
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fuel_fab',
        onPressed: () => context.push('/home/fuel/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Đổ xăng'),
      ),
    );
  }
}

class _FuelEntryCard extends StatelessWidget {
  final FuelEntry entry;
  final double? consumption;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FuelEntryCard({
    required this.entry,
    required this.consumption,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.fuelGasoline.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_gas_station_rounded,
                      color: AppColors.fuelGasoline, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppFormatters.currency(entry.totalCost),
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            AppFormatters.date(entry.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Tag(
                              label: AppFormatters.liters(entry.liters),
                              color: AppColors.fuelGasoline),
                          const SizedBox(width: 6),
                          _Tag(
                              label: AppFormatters.km(entry.odometer),
                              color: AppColors.secondary),
                          if (consumption != null) ...[
                            const SizedBox(width: 6),
                            _Tag(
                              label: AppFormatters.consumption(consumption),
                              color: consumption! > 6
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ],
                        ],
                      ),
                      if (entry.stationName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          entry.stationName!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;

  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _EmptyFuelState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.fuelGasoline.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_gas_station_rounded,
                size: 52, color: AppColors.fuelGasoline),
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có lần đổ xăng nào',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút bên dưới để thêm lần đổ xăng đầu tiên',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
