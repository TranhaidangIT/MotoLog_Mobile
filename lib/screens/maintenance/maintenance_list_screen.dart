import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);

    final selectedVehicle = vehiclesAsync.maybeWhen(
      data: (list) => list.where((v) => v.id == selectedId).firstOrNull,
      orElse: () => null,
    );

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
                    onPressed: () => context.pop(),
                  )
                : null,
            title: Text(
              'Bảo dưỡng',
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
                    const Icon(Icons.two_wheeler_rounded,
                        size: 60, color: AppColors.textHintLight),
                    const SizedBox(height: 12),
                    Text(
                      'Chọn xe để xem bảo dưỡng',
                      style: GoogleFonts.outfit(
                          fontSize: 15, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
            )
          else
            maintAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Lỗi: $e')),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return const SliverFillRemaining(
                      child: _EmptyMaintenanceState());
                }

                // Calculate oil and clutch warning stats
                final oilMaint = list
                    .where((e) =>
                        e.title.toLowerCase().contains('nhớt') ||
                        e.title.toLowerCase().contains('oil'))
                    .firstOrNull;
                double oilRemaining = 200;
                double oilTargetKm = (selectedVehicle?.odometer ?? 12344) + 200;
                if (oilMaint != null && oilMaint.nextDueKm != null) {
                  final diff =
                      oilMaint.nextDueKm! - (selectedVehicle?.odometer ?? 0);
                  if (diff > 0) {
                    oilRemaining = diff;
                    oilTargetKm = oilMaint.nextDueKm!;
                  }
                } else if (selectedVehicle != null) {
                  final odo = selectedVehicle.odometer;
                  final nextMilestone =
                      (((odo / 2000).floor() + 1) * 2000).toDouble();
                  oilRemaining = nextMilestone - odo;
                  oilTargetKm = nextMilestone;
                }

                final clutchMaint = list
                    .where((e) =>
                        e.title.toLowerCase().contains('nồi') ||
                        e.title.toLowerCase().contains('clutch'))
                    .firstOrNull;
                double clutchRemaining = 1000;
                double clutchTargetKm =
                    (selectedVehicle?.odometer ?? 12344) + 1000;
                if (clutchMaint != null && clutchMaint.nextDueKm != null) {
                  final diff =
                      clutchMaint.nextDueKm! - (selectedVehicle?.odometer ?? 0);
                  if (diff > 0) {
                    clutchRemaining = diff;
                    clutchTargetKm = clutchMaint.nextDueKm!;
                  }
                } else if (selectedVehicle != null) {
                  final odo = selectedVehicle.odometer;
                  final nextMilestone =
                      (((odo / 5000).floor() + 1) * 5000).toDouble();
                  clutchRemaining = nextMilestone - odo;
                  clutchTargetKm = nextMilestone;
                }

                return SliverList(
                  delegate: SliverChildListDelegate([
                    // ─── REMINDER ROW ───
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ReminderCard(
                              title: 'Thay nhớt',
                              remainingKm: oilRemaining,
                              targetKm: oilTargetKm,
                              bgColor: const Color(0xFFFEF3C7),
                              textColor: const Color(0xFFB45309),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ReminderCard(
                              title: 'Vệ sinh nồi',
                              remainingKm: clutchRemaining,
                              targetKm: clutchTargetKm,
                              bgColor: const Color(0xFFFEE2E2),
                              textColor: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ─── LIST ───
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Lịch sử bảo dưỡng',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
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
                          children: list
                              .asMap()
                              .entries
                              .map(
                                (e) => _MaintenanceTile(
                                  entry: e.value,
                                  isLast: e.key == list.length - 1,
                                  onTap: () => context.push(
                                      '/home/maintenance/${e.value.id}/edit'),
                                  onDelete: () async {
                                    await ref
                                        .read(maintenanceNotifierProvider
                                            .notifier)
                                        .delete(e.value.id);
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ]),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'maint_fab',
        onPressed: () => context.push('/home/maintenance/add'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text('Thêm',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Reminder Card ──
class _ReminderCard extends StatelessWidget {
  final String title;
  final double remainingKm;
  final double targetKm;
  final Color bgColor;
  final Color textColor;

  const _ReminderCard({
    required this.title,
    required this.remainingKm,
    required this.targetKm,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: textColor.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: textColor, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Còn ${AppFormatters.km(remainingKm)} nữa',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Dự kiến: ${AppFormatters.km(targetKm)}',
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Maintenance Tile ──
class _MaintenanceTile extends StatelessWidget {
  final MaintenanceEntry entry;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MaintenanceTile({
    required this.entry,
    required this.isLast,
    required this.onTap,
    required this.onDelete,
  });

  Color get _typeColor {
    switch (entry.type) {
      case MaintenanceType.routine:
        return AppColors.primary;
      case MaintenanceType.repair:
      case MaintenanceType.parts:
        return AppColors.secondary;
    }
  }

  Color get _typeBg {
    switch (entry.type) {
      case MaintenanceType.routine:
        return AppColors.primary.withValues(alpha: 0.12);
      case MaintenanceType.repair:
      case MaintenanceType.parts:
        return AppColors.secondary.withValues(alpha: 0.12);
    }
  }

  IconData get _typeIcon => Icons.build_rounded;

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
          borderRadius: isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(14))
              : BorderRadius.zero,
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _typeBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_typeIcon, color: _typeColor, size: 22),
                  ),
                  const SizedBox(width: 12),

                  // Info
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
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppFormatters.currency(entry.cost),
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: _typeBg,
                                borderRadius: BorderRadius.circular(6),
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
                              style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: AppColors.textSecondaryLight),
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
                                    ? AppColors.alertText
                                    : entry.isDueSoon
                                        ? AppColors.warning
                                        : AppColors.textHintLight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Hạn: ${AppFormatters.relativeDate(entry.nextDueDate)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight:
                                      (entry.isOverdue || entry.isDueSoon)
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                  color: entry.isOverdue
                                      ? AppColors.alertText
                                      : entry.isDueSoon
                                          ? AppColors.warning
                                          : AppColors.textHintLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (entry.garageName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '📍 ${entry.garageName}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              color: AppColors.textHintLight,
                            ),
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
            if (!isLast)
              const Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 16,
                  color: AppColors.borderLight),
          ],
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
            decoration: const BoxDecoration(
              color: AppColors.fuelBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.build_rounded,
                size: 52, color: AppColors.fuelText),
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có lịch sử bảo dưỡng',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm lần bảo dưỡng, sửa chữa\nhoặc thay phụ tùng',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
