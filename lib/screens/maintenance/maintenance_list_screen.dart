import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/maintenance_entry.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/vehicle_provider.dart';

class MaintenanceListScreen extends ConsumerWidget {
  const MaintenanceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maintAsync = ref.watch(maintenanceListProvider);
    final selectedId = ref.watch(selectedVehicleIdProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            snap: true,
            title: const Text('Bảo dưỡng & Sửa chữa'),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () {},
              ),
            ],
          ),
          if (selectedId == null)
            const SliverFillRemaining(
              child: Center(child: Text('Chọn xe để xem bảo dưỡng')),
            )
          else
            maintAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Lỗi: $e')),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return const SliverFillRemaining(
                    child: _EmptyMaintenanceState(),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _MaintenanceCard(
                        entry: list[i],
                        onTap: () => context
                            .push('/home/maintenance/${list[i].id}/edit'),
                        onDelete: () async {
                          await ref
                              .read(maintenanceNotifierProvider.notifier)
                              .delete(list[i].id);
                        },
                      ),
                      childCount: list.length,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'maint_fab',
        onPressed: () => context.push('/home/maintenance/add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Thêm'),
      ),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final MaintenanceEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MaintenanceCard({
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  Color get _typeColor {
    switch (entry.type) {
      case MaintenanceType.routine:
        return AppColors.success;
      case MaintenanceType.repair:
        return AppColors.error;
      case MaintenanceType.parts:
        return AppColors.secondary;
    }
  }

  IconData get _typeIcon {
    switch (entry.type) {
      case MaintenanceType.routine:
        return Icons.autorenew_rounded;
      case MaintenanceType.repair:
        return Icons.handyman_rounded;
      case MaintenanceType.parts:
        return Icons.settings_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_typeIcon, color: _typeColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              entry.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            AppFormatters.currency(entry.cost),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _typeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              entry.type.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _typeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppFormatters.date(entry.date),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      if (entry.nextDueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 12,
                              color: entry.isOverdue
                                  ? AppColors.error
                                  : entry.isDueSoon
                                      ? AppColors.warning
                                      : AppColors.textSecondaryLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Hạn: ${AppFormatters.relativeDate(entry.nextDueDate)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: entry.isOverdue
                                    ? AppColors.error
                                    : entry.isDueSoon
                                        ? AppColors.warning
                                        : null,
                                fontWeight: (entry.isOverdue || entry.isDueSoon)
                                    ? FontWeight.w600
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (entry.garageName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          '📍 ${entry.garageName}',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontSize: 11),
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

class _EmptyMaintenanceState extends StatelessWidget {
  const _EmptyMaintenanceState();

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
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.build_rounded,
                size: 52, color: AppColors.success),
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có lịch sử bảo dưỡng',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm lần bảo dưỡng, sửa chữa\nhoặc thay phụ tùng',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
