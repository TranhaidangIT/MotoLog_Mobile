import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:motolog_mobile/theme/app_theme.dart';
import 'package:motolog_mobile/widgets/bottom_nav_bar.dart';
import 'package:motolog_mobile/features/vehicle/providers/vehicle_provider.dart';
import 'package:motolog_mobile/features/fuel/providers/fuel_provider.dart';
import 'package:motolog_mobile/features/maintenance/providers/maintenance_provider.dart';
import 'package:motolog_mobile/features/auth/providers/auth_provider.dart';
import 'package:motolog_mobile/shared/firebase/firestore_service.dart';
import 'package:motolog_mobile/data/models/vehicle.dart';

/// Màn hình Trang chủ (Dashboard)
/// Hiển thị tổng quan danh sách xe, thống kê chi phí trong tháng và các phím tắt chức năng nhanh.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 0;
  int _carouselIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(firestoreServiceProvider)?.retrySyncOfflineData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch vehicles data
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);
    final selectedId = ref.watch(selectedVehicleIdProvider);
    
    // Watch current user
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(currentUser?.displayName ?? 'Bạn')),
            
            SliverToBoxAdapter(
              child: vehiclesAsync.when(
                data: (vehicles) {
                  if (vehicles.isEmpty) {
                    return _buildEmptyGarage();
                  }
                  return _buildBikeCarousel(vehicles, selectedId);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Lỗi tải dữ liệu xe: $e')),
              ),
            ),
            
            SliverToBoxAdapter(child: _buildQuickActions(selectedId)),
            SliverToBoxAdapter(child: _buildMonthlySummary(selectedId)),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
      bottomNavigationBar: MotoBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 1) {
            context.go('/fuel-history');
          } else if (i == 2) {
            context.go('/profile');
          } else {
            setState(() => _navIndex = i);
          }
        },
        onAddTap: () {
          if (selectedId == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm xe trước khi sử dụng')));
            context.push('/add-vehicle');
          } else {
            context.push('/fuel-log');
          }
        },
      ),
    );
  }

  Widget _buildHeader(String userName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Xin chào,', style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textSecondary)),
            Row(children: [
              Text(userName, style: GoogleFonts.beVietnamPro(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(width: 6),
              const Text('👋', style: TextStyle(fontSize: 18)),
            ]),
          ]),
          Stack(children: [
            GestureDetector(
              onTap: () {
                context.push('/profile');
              },
              child: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8)],
                ),
                child: Icon(Icons.person_outline, color: AppColors.textPrimary),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildEmptyGarage() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.directions_car_filled_outlined, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text('Chưa có xe nào', style: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/add-vehicle');
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm xe mới'),
          )
        ],
      ),
    );
  }

  Widget _buildBikeCarousel(List<Vehicle> bikes, String? selectedId) {
    return Column(children: [
      SizedBox(
        height: 200,
        child: PageView.builder(
          onPageChanged: (i) {
            setState(() => _carouselIndex = i);
            ref.read(selectedVehicleIdProvider.notifier).select(bikes[i].id);
          },
          itemCount: bikes.length,
          itemBuilder: (_, i) {
            final bike = bikes[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                margin: const EdgeInsets.only(top: 30, bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(color: const Color(0xFF1B5E20).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Stack(clipBehavior: Clip.none, children: [
                  Positioned(
                    right: -17, top: -20,
                    child: SizedBox(
                      width: 240,
                      child: (bike.cachedImageUrl != null && bike.cachedImageUrl!.isNotEmpty)
                          ? (bike.cachedImageUrl!.startsWith('http')
                              ? CachedNetworkImage(
                                  imageUrl: bike.cachedImageUrl!,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const SizedBox(
                                    width: 40, height: 40,
                                    child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.two_wheeler, size: 60, color: Colors.white70),
                                )
                              : Image.asset(
                                  bike.cachedImageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.two_wheeler, size: 60, color: Colors.white70),
                                )
                            )
                          : const Icon(Icons.two_wheeler, size: 60, color: Colors.white70),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(bike.name, style: GoogleFonts.beVietnamPro(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text('Biển số: ${bike.plateNumber}', style: GoogleFonts.beVietnamPro(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                      const Spacer(),
                      Text('Tổng quãng đường', style: GoogleFonts.beVietnamPro(color: Colors.white70, fontSize: 12)),
                      Text('${bike.odometer.toInt()} km', style: GoogleFonts.beVietnamPro(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(bikes.length, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _carouselIndex == i ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: _carouselIndex == i ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        )),
      ),
    ]);
  }

  Widget _buildQuickActions(String? selectedId) {
    final actions = [
      {'icon': Icons.local_gas_station, 'label': 'Đổ xăng',  'route': '/fuel-log'},
      {'icon': Icons.build_outlined,     'label': 'Bảo dưỡng', 'route': '/maintenance'},
      {'icon': Icons.settings_input_component_outlined, 'label': 'Phụ tùng', 'route': '/parts'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Chi phí', 'route': '/expense'},
      {'icon': Icons.two_wheeler,        'label': 'Xe của tôi',      'route': '/garage'},
      {'icon': Icons.notifications_active_outlined, 'label': 'Nhắc lịch', 'route': '/reminder'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: actions.map((a) => GestureDetector(
          onTap: () {
            if (a['route'] != null) {
              if (selectedId == null && a['route'] != '/garage') {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm xe trước khi sử dụng')));
                context.push('/add-vehicle');
                return;
              }
              
              if (a['route'] == '/expense') {
                context.go('/expense'); // Chuyển Tab
              } else {
                context.push(a['route'] as String);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.greenChip, shape: BoxShape.circle),
                child: Icon(a['icon'] as IconData, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 8),
              Text(a['label'] as String, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ]),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMonthlySummary(String? selectedId) {
    if (selectedId == null) return const SizedBox.shrink();

    final fuelCostAsync = ref.watch(fuelCostThisMonthProvider(selectedId));
    final maintCostAsync = ref.watch(maintenanceCostThisMonthProvider(selectedId));

    final fuelCost = fuelCostAsync.valueOrNull ?? 0.0;
    final maintCost = maintCostAsync.valueOrNull ?? 0.0;
    final total = fuelCost + maintCost;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tổng quan tháng này', style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Chi phí xăng', amount: '${NumberFormat('#,###', 'vi_VN').format(fuelCost)} đ', color: AppColors.fuelOrange),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Chi phí bảo dưỡng', amount: '${NumberFormat('#,###', 'vi_VN').format(maintCost)} đ', color: AppColors.maintenanceRed),
          const Divider(height: 20),
          _SummaryRow(label: 'Tổng chi phí', amount: '${NumberFormat('#,###', 'vi_VN').format(total)} đ', color: AppColors.textPrimary, bold: true),
        ]),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final bool bold;

  const _SummaryRow({required this.label, required this.amount, required this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textSecondary)),
        Text(amount, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w600, color: color)),
      ],
    );
  }
}
