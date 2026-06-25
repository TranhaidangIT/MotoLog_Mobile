import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:motolog_mobile/core/constants/app_colors.dart';
import 'package:motolog_mobile/core/utils/formatters.dart';
import 'package:motolog_mobile/data/models/vehicle.dart';
import 'package:motolog_mobile/features/fuel/providers/fuel_provider.dart';
import 'package:motolog_mobile/features/maintenance/providers/maintenance_provider.dart';
import 'package:motolog_mobile/features/vehicle/providers/vehicle_provider.dart';

/// Màn hình Chi tiết Xe
/// Hiển thị thông tin chung, lịch sử bảo dưỡng và chi phí liên quan đến một xe cụ thể.
class VehicleDetailScreen extends ConsumerWidget {
  final String vehicleId;

  const VehicleDetailScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleNotifierProvider);

    return vehicleAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Lỗi: $e'))),
      data: (vehicles) {
        final vehicle = vehicles.where((v) => v.id == vehicleId).firstOrNull;
        if (vehicle == null) {
          return const Scaffold(
            body: Center(child: Text('Không tìm thấy xe')),
          );
        }
        return _VehicleDetailView(vehicle: vehicle);
      },
    );
  }
}

class _VehicleDetailView extends ConsumerStatefulWidget {
  final Vehicle vehicle;
  const _VehicleDetailView({required this.vehicle});

  @override
  ConsumerState<_VehicleDetailView> createState() => _VehicleDetailViewState();
}

class _VehicleDetailViewState extends ConsumerState<_VehicleDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  Color get _vehicleColor {
    try {
      final hex = widget.vehicle.color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;
    final fuelAsync = ref.watch(fuelListProvider);
    final maintAsync = ref.watch(maintenanceListProvider);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: _vehicleColor,
            leading: IconButton(
              icon:
                  const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () => context.push('/vehicle/${v.id}/edit'),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Xóa xe'),
                        content: Text(
                            'Bạn có chắc muốn xóa "${v.name}"?\nTất cả dữ liệu liên quan sẽ bị xóa.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Xóa',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await ref
                          .read(vehicleNotifierProvider.notifier)
                          .delete(v.id);
                      if (context.mounted) context.pop();
                    }
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'delete', child: Text('Xóa xe')),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _vehicleColor,
                      _vehicleColor.withValues(alpha: 0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: 20,
                      child: Icon(
                        Icons.two_wheeler_rounded,
                        size: 140,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            v.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${v.brand} ${v.model} · ${v.year}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _InfoChip(
                                  label: v.plateNumber,
                                  icon: Icons.badge_outlined),
                              const SizedBox(width: 8),
                              _InfoChip(
                                label: AppFormatters.km(v.odometer),
                                icon: Icons.speed_rounded,
                              ),
                              const SizedBox(width: 8),
                              _InfoChip(
                                  label: v.fuelType,
                                  icon: Icons.local_gas_station_outlined),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'Xăng'),
                Tab(text: 'Bảo dưỡng'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            // Fuel tab
            fuelAsync.when(
              data: (list) => list.isEmpty
                  ? const Center(child: Text('Chưa có dữ liệu xăng'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (_, i) => _FuelTile(entry: list[i]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
            // Maintenance tab
            maintAsync.when(
              data: (list) => list.isEmpty
                  ? const Center(child: Text('Chưa có dữ liệu bảo dưỡng'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: list.length,
                      itemBuilder: (_, i) => _MaintTile(entry: list[i]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('$e')),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FuelTile extends StatelessWidget {
  final dynamic entry;
  const _FuelTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accentYellow.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.local_gas_station_rounded,
              color: AppColors.accentYellow, size: 20),
        ),
        title: Text(AppFormatters.currency(entry.totalCost)),
        subtitle: Text(
            '${AppFormatters.liters(entry.liters)} · ${AppFormatters.date(entry.date)}'),
        trailing: Text(
          AppFormatters.km(entry.odometer),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _MaintTile extends StatelessWidget {
  final dynamic entry;
  const _MaintTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accentPurple.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.build_rounded,
              color: AppColors.accentPurple, size: 20),
        ),
        title: Text(entry.title),
        subtitle: Text(AppFormatters.date(entry.date)),
        trailing: Text(
          AppFormatters.currency(entry.cost),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
