import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/vehicle.dart';
import '../../providers/fuel_provider.dart';
import '../../providers/maintenance_provider.dart';
import '../../providers/vehicle_provider.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);
    final selectedId = ref.watch(selectedVehicleIdProvider);
    final upcomingAsync = ref.watch(upcomingMaintenanceProvider);
    final currentUser = ref.watch(currentUserProvider);

    final firstName = (currentUser?.displayName ?? 'bạn').split(' ').last;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ------------------ HEADER ------------------
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.backgroundLight,
            elevation: 0,
            titleSpacing: 16,
            title: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      Text(
                        firstName,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                // Notification Bell
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: AppColors.textPrimaryLight,
                        size: 20,
                      ),
                    ),
                    upcomingAsync.when(
                      data: (list) => list.isNotEmpty
                          ? Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: AppColors.backgroundLight,
                                      width: 1.5),
                                ),
                              ),
                            )
                          : const SizedBox(),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                // Avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: currentUser?.photoURL != null
                      ? ClipOval(
                          child: Image.network(
                            currentUser!.photoURL!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                ),
              ],
            ),
          ),

          // ------------------ CONTENT ------------------
          SliverToBoxAdapter(
            child: vehiclesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(64),
                  child: CircularProgressIndicator(color: AppColors.primary),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng,';
    if (hour < 18) return 'Chào buổi chiều,';
    return 'Chào buổi tối,';
  }
}

// ----------------------------------------------
//  DASHBOARD CONTENT
// ----------------------------------------------
class _DashboardContent extends ConsumerStatefulWidget {
  final List<Vehicle> vehicles;
  final String? selectedId;

  const _DashboardContent({
    required this.vehicles,
    required this.selectedId,
  });

  @override
  ConsumerState<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends ConsumerState<_DashboardContent> {
  late PageController _pageController;
  double _pageOffset = 0.0;

  @override
  void initState() {
    super.initState();
    final initialIndex =
        widget.vehicles.indexWhere((v) => v.id == widget.selectedId);
    final startIndex = initialIndex >= 0 ? initialIndex : 0;
    _pageController = PageController(
      viewportFraction: 0.82,
      initialPage: startIndex,
    );
    _pageOffset = startIndex.toDouble();
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void didUpdateWidget(covariant _DashboardContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedId != oldWidget.selectedId &&
        widget.selectedId != null) {
      final index =
          widget.vehicles.indexWhere((v) => v.id == widget.selectedId);
      if (index >= 0 &&
          _pageController.hasClients &&
          _pageController.page?.round() != index) {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = widget.selectedId != null
        ? widget.vehicles.firstWhere(
            (v) => v.id == widget.selectedId,
            orElse: () => widget.vehicles.first,
          )
        : widget.vehicles.first;

    final fuelCostAsync =
        ref.watch(fuelCostThisMonthProvider(selectedVehicle.id));
    final maintCostAsync =
        ref.watch(maintenanceCostThisMonthProvider(selectedVehicle.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // -------- VEHICLE CARD (Cover Flow PageView) --------
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.vehicles.length,
            clipBehavior: Clip.none,
            onPageChanged: (index) {
              ref
                  .read(selectedVehicleIdProvider.notifier)
                  .select(widget.vehicles[index].id);
            },
            itemBuilder: (context, i) {
              final v = widget.vehicles[i];
              double scale = 1.0;
              double diff = (_pageOffset - i).abs();

              if (diff <= 1.0) {
                scale = 1.0 - (diff * 0.12);
              } else {
                scale = 0.88;
              }

              // Active card is at top, others slightly lowered
              double translationY = (1.0 - scale) * 80.0;

              return Transform.translate(
                offset: Offset(0, translationY),
                child: Transform.scale(
                  scale: scale,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: GestureDetector(
                      onTap: () {
                        if (_pageController.page?.round() != i) {
                          _pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: _VehicleCard(
                        vehicle: v,
                        isSelected: v.id == selectedVehicle.id,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // -------- WRAPPED CONTENT IN PADDING --------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- THỐNG KÊ THÁNG NÀY --------
              Text(
                'Tháng này',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PastelStatCard(
                      icon: Icons.local_gas_station_rounded,
                      label: 'Tiền xăng',
                      bgColor: AppColors.fuelBg,
                      iconColor: AppColors.fuelText,
                      textColor: AppColors.fuelText,
                      valueAsync: fuelCostAsync,
                      formatter: AppFormatters.currency,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PastelStatCard(
                      icon: Icons.build_rounded,
                      label: 'Bảo dưỡng',
                      bgColor: AppColors.maintBg,
                      iconColor: AppColors.maintText,
                      textColor: AppColors.maintText,
                      valueAsync: maintCostAsync,
                      formatter: AppFormatters.currency,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // -------- MAINTENANCE ALERT --------
              Consumer(
                builder: (context, ref, _) {
                  final upcoming = ref.watch(upcomingMaintenanceProvider);
                  return upcoming.when(
                    data: (list) {
                      if (list.isEmpty) return const SizedBox();
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.alertBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    AppColors.alertText.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AppColors.alertText
                                        .withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.alertText,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${list.length} hạng mục sắp đến hạn bảo dưỡng',
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.alertText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        list.first.title,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          color: AppColors.alertText
                                              .withValues(alpha: 0.8),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.alertText,
                                  size: 20,
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
                },
              ),

              // -------- HOẠT ĐỘNG GẦN ĐÂY --------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hoạt động gần đây',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.fuelList),
                    child: Text(
                      'Xem tất cả',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Consumer(
                builder: (context, ref, _) {
                  final fuelAsync = ref.watch(fuelListProvider);
                  final maintAsync = ref.watch(maintenanceListProvider);

                  return fuelAsync.when(
                    data: (fuels) {
                      return maintAsync.when(
                        data: (maints) {
                          final items = <_ActivityItem>[];
                          for (final f in fuels.take(3)) {
                            items.add(_ActivityItem(
                              type: 'fuel',
                              title: 'Đổ xăng',
                              subtitle:
                                  '${AppFormatters.liters(f.liters)} · ${AppFormatters.currency(f.totalCost)}',
                              date: f.date,
                            ));
                          }
                          for (final m in maints.take(2)) {
                            items.add(_ActivityItem(
                              type: 'maint',
                              title: m.title,
                              subtitle: AppFormatters.currency(m.cost),
                              date: m.date,
                            ));
                          }
                          items.sort((a, b) => b.date.compareTo(a.date));
                          final recent = items.take(5).toList();

                          if (recent.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border:
                                    Border.all(color: AppColors.borderLight),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.history_rounded,
                                      size: 40,
                                      color: AppColors.textHintLight
                                          .withValues(alpha: 0.5)),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Chưa có hoạt động nào',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.textHintLight,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Container(
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
                              children: recent.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final item = entry.value;
                                final isFuel = item.type == 'fuel';
                                return Column(
                                  children: [
                                    ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 4),
                                      leading: Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: isFuel
                                              ? AppColors.fuelBg
                                              : AppColors.maintBg,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          isFuel
                                              ? Icons.local_gas_station_rounded
                                              : Icons.build_rounded,
                                          color: isFuel
                                              ? AppColors.fuelText
                                              : AppColors.maintText,
                                          size: 20,
                                        ),
                                      ),
                                      title: Text(
                                        item.title,
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      subtitle: Text(
                                        item.subtitle,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          color: AppColors.textSecondaryLight,
                                        ),
                                      ),
                                      trailing: Text(
                                        AppFormatters.date(item.date),
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          color: AppColors.textHintLight,
                                        ),
                                      ),
                                    ),
                                    if (idx < recent.length - 1)
                                      const Divider(
                                        height: 1,
                                        indent: 74,
                                        endIndent: 16,
                                        color: AppColors.borderLight,
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        },
                        loading: () => const LinearProgressIndicator(
                            color: AppColors.primary),
                        error: (_, __) => const SizedBox(),
                      );
                    },
                    loading: () =>
                        const LinearProgressIndicator(color: AppColors.primary),
                    error: (_, __) => const SizedBox(),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

// -- Simple data holder --
class _ActivityItem {
  final String type;
  final String title;
  final String subtitle;
  final DateTime date;

  _ActivityItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
  });
}

// ----------------------------------------------
//  VEHICLE CARD (horizontal)
// ----------------------------------------------
class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;

  const _VehicleCard({required this.vehicle, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 260,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Vehicle image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariantLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty
                    ? (vehicle.imageUrl!.startsWith('assets/')
                        ? Image.asset(vehicle.imageUrl!, fit: BoxFit.contain)
                        : Image.file(File(vehicle.imageUrl!),
                            fit: BoxFit.contain))
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          'img/logo/logo.png',
                          fit: BoxFit.contain,
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${vehicle.brand} ${vehicle.name}',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vehicle.plateNumber,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.speed_rounded,
                          size: 13,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppColors.textHintLight),
                      const SizedBox(width: 4),
                      Text(
                        AppFormatters.km(vehicle.odometer),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
//  PASTEL STAT CARD
// ══════════════════════════════════════════════
class _PastelStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final Color textColor;
  final AsyncValue<double>? valueAsync;
  final String Function(double)? formatter;

  const _PastelStatCard({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.textColor,
    this.valueAsync,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (valueAsync != null)
                  valueAsync!.when(
                    data: (v) => Text(
                      formatter != null ? formatter!(v) : v.toStringAsFixed(0),
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    loading: () => Container(
                      height: 12,
                      width: 50,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    error: (_, __) => Text('—',
                        style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700, color: textColor)),
                  )
                else
                  Text(
                    '—',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.7),
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

// ----------------------------------------------
//  EMPTY STATE
// ----------------------------------------------
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
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(24),
            child: Image.asset(
              'img/logo/logo.png',
              fit: BoxFit.contain,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chưa có xe nào',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm chiếc xe đầu tiên của bạn\nđể bắt đầu ghi nhật ký',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => GoRouter.of(context).push('/vehicle/add'),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Thêm xe ngay'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
