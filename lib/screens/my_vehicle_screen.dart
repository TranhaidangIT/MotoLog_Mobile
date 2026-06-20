import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/vehicle_provider.dart';

class MyVehicleScreen extends ConsumerWidget {
  final String? vehicleId;
  const MyVehicleScreen({super.key, this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsync = vehicleId != null
        ? ref.watch(vehicleNotifierProvider).whenData((vehicles) {
            for (var v in vehicles) {
              if (v.id == vehicleId) return v;
            }
            return null;
          })
        : ref.watch(selectedVehicleProvider);

    final vehicle = vehicleAsync.valueOrNull;

    if (vehicle == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Xe của tôi'), centerTitle: true, leading: const BackButton()),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Vui lòng thêm hoặc chọn xe', style: GoogleFonts.beVietnamPro(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => context.push('/add-vehicle'),
                icon: const Icon(Icons.add),
                label: const Text('Thêm xe mới'),
              ),
            ],
          ),
        ),
      );
    }

    final fmt = NumberFormat('#,###.#');
    final dateFmt = DateFormat('dd/MM/yyyy');

    // Logic tính ngày còn lại của đăng kiểm, bảo hiểm
    String _getBadge(DateTime? date) {
      if (date == null) return 'Chưa có';
      final diff = date.difference(DateTime.now()).inDays;
      if (diff < 0) return 'Hết hạn';
      if (diff < 30) return 'Sắp hết ($diff ngày)';
      return 'Còn hạn';
    }

    Color _getBadgeColor(String badge) {
      if (badge == 'Chưa có' || badge == 'Hết hạn') return const Color(0xFFD32F2F);
      if (badge.startsWith('Sắp hết')) return const Color(0xFFF57C00);
      return AppColors.primary;
    }

    Color _getBadgeBg(String badge) {
      if (badge == 'Chưa có' || badge == 'Hết hạn') return const Color(0xFFFFEBEE);
      if (badge.startsWith('Sắp hết')) return const Color(0xFFFFF3E0);
      return const Color(0xFFE8F5E9);
    }

    final insBadge = _getBadge(vehicle.insuranceDate);
    final inspBadge = _getBadge(vehicle.inspectionDate);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Xe của tôi'),
        centerTitle: true,
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/add-vehicle'),
          ),
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.edit_outlined, size: 20)
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(10),
        children: [
          // Bike card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              Positioned(
                right: -10, bottom: -10,
                child: Container(width: 80, height: 80, decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.08), shape: BoxShape.circle,
                )),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(vehicle.name, style: GoogleFonts.beVietnamPro(fontSize: 12, color: Colors.white.withValues(alpha: 0.75))),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text('Biển số: ${vehicle.plateNumber}', style: GoogleFonts.beVietnamPro(fontSize: 11, color: Colors.white)),
                ),
                const SizedBox(height: 10),
                Text('Tổng quãng đường', style: GoogleFonts.beVietnamPro(fontSize: 10, color: Colors.white.withValues(alpha: 0.7))),
                Text('${fmt.format(vehicle.odometer)} km', style: GoogleFonts.beVietnamPro(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 8),
                Row(children: [
                  Container(width: 24, height: 5, decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(3))),
                  const SizedBox(width: 4),
                  Container(width: 16, height: 5, decoration: BoxDecoration(color: AppColors.surface.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(3))),
                ]),
              ]),
            ]),
          ),

          const SizedBox(height: 4),
          const _SectionTitle('Thông tin xe'),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8, crossAxisSpacing: 8,
            childAspectRatio: 1.7,
            children: [
              _InfoCell(icon: Icons.calendar_today, value: '${vehicle.year}', label: 'Năm sản xuất'),
              _InfoCell(icon: Icons.palette_outlined, value: vehicle.color == '#FF6B00' ? 'Đen' : vehicle.color, label: 'Màu xe'),
              _InfoCell(icon: Icons.settings_outlined, value: vehicle.engineCapacity ?? '-- cc', label: 'Dung tích'),
              _InfoCell(icon: Icons.water_drop_outlined, value: vehicle.fuelType, label: 'Loại nhiên liệu'),
            ],
          ),

          const SizedBox(height: 4),
          const _SectionTitle('Giấy tờ & hạn'),

          _DocCard(
            icon: Icons.badge_outlined, 
            title: 'Đăng kiểm', 
            sub: vehicle.inspectionDate != null ? 'Hết hạn: ${dateFmt.format(vehicle.inspectionDate!)}' : 'Chưa nhập thông tin', 
            badge: inspBadge, 
            badgeColor: _getBadgeColor(inspBadge), 
            badgeBg: _getBadgeBg(inspBadge),
          ),
          const SizedBox(height: 6),
          _DocCard(
            icon: Icons.shield_outlined, 
            title: 'Bảo hiểm xe', 
            sub: vehicle.insuranceDate != null ? 'Hết hạn: ${dateFmt.format(vehicle.insuranceDate!)}' : 'Chưa nhập thông tin', 
            badge: insBadge, 
            badgeColor: _getBadgeColor(insBadge), 
            badgeBg: _getBadgeBg(insBadge),
          ),
          const SizedBox(height: 6),
          _DocCard(
            icon: Icons.description_outlined, 
            title: 'Đăng ký xe', 
            sub: (vehicle.isRegistered ?? true) ? 'Hợp lệ' : 'Chưa có giấy tờ', 
            badge: (vehicle.isRegistered ?? true) ? 'Hợp lệ' : 'Lỗi', 
            badgeColor: (vehicle.isRegistered ?? true) ? AppColors.primary : const Color(0xFFD32F2F), 
            badgeBg: (vehicle.isRegistered ?? true) ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
          ),

          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: MotoBottomNavBar(
        currentIndex: 3,
        onTap: (i) {
          if (i == 0) { context.go('/home'); }
          else if (i == 1) { context.go('/fuel-history'); }
          else if (i == 2) { context.go('/expense'); }
        },
        onAddTap: () => context.push('/fuel-log'),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 10, 4, 6),
      child: Text(text.toUpperCase(), style: GoogleFonts.beVietnamPro(
        fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 0.4,
      )),
    );
  }
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _InfoCell({required this.icon, required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600)),
        Text(label, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _DocCard extends StatelessWidget {
  final IconData icon;
  final String title, sub, badge;
  final Color badgeColor, badgeBg;
  const _DocCard({required this.icon, required this.title, required this.sub, required this.badge, required this.badgeColor, required this.badgeBg});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(sub, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(5)),
          child: Text(badge, style: GoogleFonts.beVietnamPro(fontSize: 9, fontWeight: FontWeight.w600, color: badgeColor)),
        ),
      ]),
    );
  }
}
