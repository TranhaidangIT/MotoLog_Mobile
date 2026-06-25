import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motolog_mobile/core/constants/app_colors.dart';
import 'package:motolog_mobile/core/constants/maintenance_schedule.dart';
import 'package:motolog_mobile/core/utils/formatters.dart';
import 'package:motolog_mobile/data/models/maintenance_entry.dart';
import 'package:motolog_mobile/features/maintenance/providers/maintenance_provider.dart';
import 'package:motolog_mobile/features/vehicle/providers/vehicle_provider.dart';

/// Màn hình Danh sách Bảo dưỡng
/// Hiển thị lịch sử các lần bảo dưỡng và các hạng mục bảo dưỡng sắp tới.
class MaintenanceListScreen extends ConsumerStatefulWidget {
  const MaintenanceListScreen({super.key});

  @override
  ConsumerState<MaintenanceListScreen> createState() =>
      _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends ConsumerState<MaintenanceListScreen> {
  int _selectedTabIndex = 0; // 0: Tất cả, 1: Sắp tới, 2: Đã hoàn thành

  @override
  Widget build(BuildContext context) {
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
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
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
                    Icon(Icons.two_wheeler_rounded,
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
              loading: () => SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Lỗi: $e')),
              ),
              data: (list) {
                final currentOdo = selectedVehicle?.odometer ?? 0.0;
                
                // Calculate status for each schedule item
                final scheduledItems = MaintenanceSchedule.items.map((item) {
                  return _calculateScheduleStatus(item, list, currentOdo);
                }).toList();

                // Sort by remaining km
                scheduledItems.sort((a, b) => a.remainingKm.compareTo(b.remainingKm));

                return SliverList(
                  delegate: SliverChildListDelegate([
                    // ─── FILTER TABS ───
                    _buildFilterTabs(),
                    const SizedBox(height: 16),

                    // ─── CONTENT ───
                    _buildContent(list, scheduledItems),
                    const SizedBox(height: 100),
                  ]),
                );
              },
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/home/maintenance/add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                'Thêm bảo dưỡng',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = ['Tất cả', 'Sắp tới', 'Đã hoàn thành'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Container(
                margin: EdgeInsets.only(right: index < tabs.length - 1 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent(List<MaintenanceEntry> history, List<_ScheduleStatus> scheduledItems) {
    if (_selectedTabIndex == 2) {
      // Đã hoàn thành (History)
      if (history.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('Chưa có lịch sử bảo dưỡng nào.'),
          ),
        );
      }
      // Sort history descending by date
      final sortedHistory = List<MaintenanceEntry>.from(history)
        ..sort((a, b) => b.date.compareTo(a.date));

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            children: sortedHistory.asMap().entries.map((e) {
              return _HistoryTile(
                entry: e.value,
                isLast: e.key == sortedHistory.length - 1,
                onTap: () => context.push('/home/maintenance/${e.value.id}/edit'),
              );
            }).toList(),
          ),
        ),
      );
    }

    // Tất cả & Sắp tới (Schedule)
    List<_ScheduleStatus> itemsToShow = scheduledItems;
    if (_selectedTabIndex == 1) {
      // Sắp tới: remaining <= 2000 km (or 15% of defaultDueKm)
      itemsToShow = scheduledItems.where((s) => s.remainingKm <= s.item.defaultDueKm * 0.2 || s.remainingKm <= 2000).toList();
    }

    if (itemsToShow.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text('Không có mục bảo dưỡng nào sắp tới.'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: itemsToShow.map((s) => _ScheduleCard(status: s)).toList(),
      ),
    );
  }

  _ScheduleStatus _calculateScheduleStatus(ScheduleItem item, List<MaintenanceEntry> history, double currentOdo) {
    // Find latest matching entry by date
    final matchingEntries = history.where((e) {
      final titleLower = e.title.toLowerCase();
      return item.keywords.any((k) => titleLower.contains(k));
    }).toList();
    
    matchingEntries.sort((a, b) => b.date.compareTo(a.date));
    final lastEntry = matchingEntries.firstOrNull;

    double remainingKm = 0.0;
    
    if (lastEntry != null) {
      if (lastEntry.nextDueKm != null && lastEntry.nextDueKm! > 0) {
        remainingKm = lastEntry.nextDueKm! - currentOdo;
      } else {
        final distanceSinceLast = currentOdo - lastEntry.odometer;
        remainingKm = item.defaultDueKm - distanceSinceLast;
      }
    } else {
      // Never done before
      final milestonesPassed = (currentOdo / item.defaultDueKm).floor();
      final nextMilestone = (milestonesPassed + 1) * item.defaultDueKm;
      remainingKm = nextMilestone - currentOdo;
    }

    // Floor at 0 if negative
    if (remainingKm < 0) remainingKm = 0;

    return _ScheduleStatus(
      item: item,
      remainingKm: remainingKm,
      progress: 1.0 - (remainingKm / item.defaultDueKm).clamp(0.0, 1.0),
    );
  }
}

class _ScheduleStatus {
  final ScheduleItem item;
  final double remainingKm;
  final double progress; // 0.0 -> 1.0 (1.0 is full/due)

  _ScheduleStatus({
    required this.item,
    required this.remainingKm,
    required this.progress,
  });
}

// ─── WIDGETS ───

class _ScheduleCard extends StatelessWidget {
  final _ScheduleStatus status;

  const _ScheduleCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final isCritical = status.remainingKm <= 500;
    final progressColor = isCritical ? AppColors.error : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              status.item.imageAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.build_rounded, color: AppColors.textHintLight),
            ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.item.title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status.item.frequencyLabel,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                // Progress Bar
                Row(
                  children: [
                    Text(
                      'Còn ',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: progressColor,
                      ),
                    ),
                    Text(
                      AppFormatters.km(status.remainingKm),
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: progressColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: status.progress,
                    backgroundColor: progressColor.withValues(alpha: 0.1),
                    color: progressColor,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final MaintenanceEntry entry;
  final bool isLast;
  final VoidCallback onTap;

  const _HistoryTile({
    required this.entry,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.maintBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.build_rounded, color: AppColors.maintText, size: 22),
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
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.maintBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              entry.type.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.maintText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppFormatters.date(entry.date),
                            style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isLast) Divider(height: 1, indent: 72, endIndent: 16, color: AppColors.borderLight),
        ],
      ),
    );
  }
}
