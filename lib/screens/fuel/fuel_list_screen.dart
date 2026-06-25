import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/fuel_entry.dart';
import '../../providers/fuel_provider.dart';
import '../../providers/vehicle_provider.dart';

/// Màn hình Danh sách Đổ xăng
/// Hiển thị lịch sử các lần đổ xăng của xe hiện tại.
class FuelListScreen extends ConsumerWidget {
  const FuelListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fuelAsync = ref.watch(fuelListProvider);
    final selectedId = ref.watch(selectedVehicleIdProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── APP BAR ───
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.backgroundLight,
            elevation: 0,
            title: Text(
              'Nhật ký xăng',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded,
                    color: AppColors.textPrimaryLight),
                onPressed: () {},
              ),
            ],
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
                      'Chọn xe để xem nhật ký xăng',
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            fuelAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary)),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(child: Text('Lỗi: $e')),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return SliverFillRemaining(child: _EmptyFuelState());
                }

                // Totals
                final totalCost =
                    list.fold<double>(0, (s, e) => s + e.totalCost);
                final totalLiters =
                    list.fold<double>(0, (s, e) => s + e.liters);
                final avgConsumption = list.length > 1
                    ? list
                            .asMap()
                            .entries
                            .map((e) {
                              final prev = e.key < list.length - 1
                                  ? list[e.key + 1]
                                  : null;
                              return e.value.consumptionWith(prev);
                            })
                            .where((c) => c != null)
                            .fold<double>(0, (s, c) => s + c!) /
                        list.asMap().entries.where((e) {
                          final prev =
                              e.key < list.length - 1 ? list[e.key + 1] : null;
                          return e.value.consumptionWith(prev) != null;
                        }).length
                    : 0.0;

                // Group by month
                final grouped = <String, List<FuelEntry>>{};
                for (final entry in list) {
                  final key = AppFormatters.monthYear(entry.date);
                  grouped.putIfAbsent(key, () => []).add(entry);
                }

                return SliverList(
                  delegate: SliverChildListDelegate([
                    // ─── SUMMARY BANNER (Xanh lá) ───
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.local_gas_station_rounded,
                                    color: Colors.white70, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Tổng tiêu thụ xăng',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _BannerStat(
                                  value: AppFormatters.currency(totalCost),
                                  label: 'Tổng chi phí',
                                ),
                                Container(
                                    width: 1,
                                    height: 36,
                                    color: Colors.white24),
                                _BannerStat(
                                  value: AppFormatters.liters(totalLiters),
                                  label: 'Tổng số lít',
                                ),
                                Container(
                                    width: 1,
                                    height: 36,
                                    color: Colors.white24),
                                _BannerStat(
                                  value: avgConsumption > 0
                                      ? '${avgConsumption.toStringAsFixed(1)} L/100'
                                      : '—',
                                  label: 'TB tiêu hao',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── GROUPED LIST ───
                    ...grouped.entries.map((group) {
                      final entries = group.value;
                      final monthTotal =
                          entries.fold<double>(0, (s, e) => s + e.totalCost);
                      final monthLiters =
                          entries.fold<double>(0, (s, e) => s + e.liters);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Tháng ${group.key}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      AppFormatters.currency(monthTotal),
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      AppFormatters.liters(monthLiters),
                                      style: GoogleFonts.outfit(
                                        fontSize: 11,
                                        color: AppColors.textHintLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Entry cards grouped in container
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: AppColors.borderLight),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: entries.asMap().entries.map((e) {
                                  final entry = e.value;
                                  final prev = e.key < entries.length - 1
                                      ? entries[e.key + 1]
                                      : null;
                                  final consumption =
                                      entry.consumptionWith(prev);
                                  return _FuelEntryTile(
                                    entry: entry,
                                    consumption: consumption,
                                    isLast: e.key == entries.length - 1,
                                    onTap: () => context
                                        .push('/home/fuel/${entry.id}/edit'),
                                    onDelete: () async {
                                      await ref
                                          .read(fuelNotifierProvider.notifier)
                                          .delete(entry.id);
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      );
                    }),

                    const SizedBox(height: 100),
                  ]),
                );
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fuel_fab',
        onPressed: () => context.push('/home/fuel/add'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text('Đổ xăng',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Banner stat item ──
class _BannerStat extends StatelessWidget {
  final String value;
  final String label;

  const _BannerStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

// ── Fuel Entry Tile (inside grouped container) ──
class _FuelEntryTile extends StatelessWidget {
  final FuelEntry entry;
  final double? consumption;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FuelEntryTile({
    required this.entry,
    required this.consumption,
    required this.isLast,
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
        borderRadius: BorderRadius.vertical(
          top: Radius.zero,
          bottom: isLast ? const Radius.circular(14) : Radius.zero,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.fuelBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_gas_station_rounded,
                        color: AppColors.fuelText, size: 20),
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
                            Text(
                              AppFormatters.currency(entry.totalCost),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            Text(
                              AppFormatters.date(entry.date),
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: AppColors.textHintLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _Tag(
                              label: AppFormatters.liters(entry.liters),
                              bgColor: AppColors.fuelBg,
                              textColor: AppColors.fuelText,
                            ),
                            const SizedBox(width: 6),
                            _Tag(
                              label: AppFormatters.km(entry.odometer),
                              bgColor: const Color(0xFFEFF6FF),
                              textColor: const Color(0xFF1D4ED8),
                            ),
                            if (consumption != null) ...[
                              const SizedBox(width: 6),
                              _Tag(
                                label: AppFormatters.consumption(consumption),
                                bgColor: consumption! > 6
                                    ? AppColors.alertBg
                                    : AppColors.fuelBg,
                                textColor: consumption! > 6
                                    ? AppColors.alertText
                                    : AppColors.fuelText,
                              ),
                            ],
                          ],
                        ),
                        if (entry.stationName != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '📍 ${entry.stationName!}',
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
                  indent: 68,
                  endIndent: 16,
                  color: AppColors.borderLight),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _Tag(
      {required this.label, required this.bgColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textColor,
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
            decoration: const BoxDecoration(
              color: AppColors.fuelBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_gas_station_rounded,
                size: 52, color: AppColors.fuelText),
          ),
          const SizedBox(height: 20),
          Text(
            'Chưa có lần đổ xăng nào',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút bên dưới để thêm lần đổ xăng đầu tiên',
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
