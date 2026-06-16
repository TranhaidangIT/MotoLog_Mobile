import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/vehicle.dart';
import '../../providers/fuel_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../vehicle/widgets/vehicle_card.dart';
import 'widgets/stat_card.dart';
import 'widgets/recent_activity_tile.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);
    final selectedId = ref.watch(selectedVehicleIdProvider);
    final upcomingAsync = ref.watch(upcomingMaintenanceProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // === APP BAR ===
          SliverAppBar(
            floating: true,
            snap: true,
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.two_wheeler_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  'MotoLog',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            actions: [
              // Notification bell
              upcomingAsync.when(
                data: (list) => list.isNotEmpty
                    ? Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {},
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        onPressed: () {},
                      ),
                loading: () => IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                ),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(width: 8),
            ],
          ),

          // === CONTENT ===
          SliverToBoxAdapter(
            child: vehiclesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(64),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text('Lỗi: $e')),
              data: (vehicles) {
                if (vehicles.isEmpty) {
                  return _EmptyVehicleState();
                }
                return _DashboardContent(
                  vehicles: vehicles,
                  selectedId: selectedId,
                  ref: ref,
                );
              },
            ),
          ),
        ],
      ),

      // FAB - Add vehicle
      floatingActionButton: FloatingActionButton(
        heroTag: 'dash_fab',
        onPressed: () => context.push('/vehicle/add'),
        tooltip: 'Thêm xe',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _DashboardContent extends ConsumerWidget {
  final List<Vehicle> vehicles;
  final String? selectedId;
  final WidgetRef ref;

  const _DashboardContent({
    required this.vehicles,
    required this.selectedId,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVehicle = selectedId != null
        ? vehicles.firstWhere(
            (v) => v.id == selectedId,
            orElse: () => vehicles.first,
          )
        : vehicles.first;

    final fuelCostAsync = ref.watch(fuelCostThisMonthProvider(selectedVehicle.id));
    final maintCostAsync = ref.watch(maintenanceCostThisMonthProvider(selectedVehicle.id));
    final fuelListAsync = ref.watch(fuelListProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // === VEHICLE CARDS (horizontal scroll) ===
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: vehicles.length,
              itemBuilder: (context, i) {
                final v = vehicles[i];
                final isSelected = v.id == (selectedId ?? vehicles.first.id);
                return Padding(
                  padding: EdgeInsets.only(
                    right: 12,
                    left: i == 0 ? 0 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(selectedVehicleIdProvider.notifier)
                          .select(v.id);
                    },
                    child: VehicleCard(
                      vehicle: v,
                      isSelected: isSelected,
                      onTap: () => context.push('/vehicle/${v.id}'),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // === THỐNG KÊ THÁNG NÀY ===
          Text(
            'Tháng này',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          OrientationBuilder(builder: (context, orientation) {
            final crossCount = orientation == Orientation.landscape ? 4 : 2;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: orientation == Orientation.landscape ? 1.5 : 1.6,
              children: [
                StatCard(
                  icon: Icons.local_gas_station_rounded,
                  iconColor: AppColors.fuelGasoline,
                  label: 'Tiền xăng',
                  valueAsync: fuelCostAsync,
                  formatter: AppFormatters.currency,
                ),
                StatCard(
                  icon: Icons.build_rounded,
                  iconColor: AppColors.secondary,
                  label: 'Bảo dưỡng',
                  valueAsync: maintCostAsync,
                  formatter: AppFormatters.currency,
                ),
                StatCard(
                  icon: Icons.speed_rounded,
                  iconColor: AppColors.success,
                  label: 'Odometer',
                  value: AppFormatters.km(selectedVehicle.odometer),
                ),
                fuelListAsync.when(
                  data: (list) {
                    return StatCard(
                      icon: Icons.account_balance_wallet_rounded,
                      iconColor: AppColors.warning,
                      label: 'Tổng chi phí',
                      value: AppFormatters.currency(
                          (fuelCostAsync.value ?? 0) +
                              (maintCostAsync.value ?? 0)),
                    );
                  },
                  loading: () => StatCard(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.warning,
                    label: 'Tổng chi phí',
                    value: '...',
                  ),
                  error: (_, __) => StatCard(
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: AppColors.warning,
                    label: 'Tổng chi phí',
                    value: '0 ₫',
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // === UPCOMING MAINTENANCE ALERT ===
          Consumer(builder: (context, ref, _) {
            final upcoming = ref.watch(upcomingMaintenanceProvider);
            return upcoming.when(
              data: (list) {
                if (list.isEmpty) return const SizedBox();
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        border: Border.all(
                            color: AppColors.warning.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.warning_amber_rounded,
                                color: AppColors.warning, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${list.length} lịch bảo dưỡng sắp đến hạn',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                          color: AppColors.warning,
                                          fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  list.first.title,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            );
          }),

          // === HOẠT ĐỘNG GẦN ĐÂY ===
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hoạt động gần đây',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.fuelList),
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Recent fuel
          fuelListAsync.when(
            data: (list) {
              final recent = list.take(3).toList();
              if (recent.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text('Chưa có hoạt động nào'),
                  ),
                );
              }
              return Column(
                children: recent
                    .map((e) => RecentActivityTile(
                          icon: Icons.local_gas_station_rounded,
                          iconColor: AppColors.fuelGasoline,
                          title: 'Đổ xăng',
                          subtitle: AppFormatters.currency(e.totalCost),
                          date: AppFormatters.date(e.date),
                        ))
                    .toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _EmptyVehicleState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.two_wheeler_rounded,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có xe nào',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm chiếc xe đầu tiên của bạn\nđể bắt đầu ghi nhật ký',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
                ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.push('/vehicle/add'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Thêm xe ngay'),
          ),
        ],
      ),
    );
  }
}
