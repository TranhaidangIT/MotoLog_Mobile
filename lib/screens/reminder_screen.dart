import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/maintenance_item_provider.dart';
import '../providers/custom_reminder_provider.dart';
import '../providers/reminder_provider.dart';
import '../providers/vehicle_provider.dart';
import 'add_reminder_screen.dart';

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key});

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  int _filterIndex = 0;
  final _filters = ['Tất cả', 'Đang bật', 'Đã tắt'];

  Color _iconBg(String level) {
    switch (level) {
      case 'overdue':
        return AppColors.dangerRedBg;
      case 'urgent':
      case 'warning':
      case 'soon':
        return AppColors.warningOrangeBg;
      default:
        return AppColors.greenChip;
    }
  }

  Color _iconColor(String level) {
    switch (level) {
      case 'overdue':
        return AppColors.dangerRed;
      case 'urgent':
      case 'warning':
      case 'soon':
        return AppColors.warningOrange;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(selectedVehicleProvider);
    final currentOdo = vehicleAsync.valueOrNull?.odometer.toInt() ?? 0;
    
    final allMaintenance = ref.watch(maintenanceItemNotifierProvider);
    final allCustom = ref.watch(customReminderNotifierProvider);

    // Filter items based on _filterIndex
    final periodicItems = allMaintenance.where((i) {
      if (_filterIndex == 1) return i.isReminderOn;
      if (_filterIndex == 2) return !i.isReminderOn;
      return true;
    }).toList();

    // Upcoming = Maintenance (urgency != normal) + Custom (all active for now)
    final upcomingMaint = periodicItems.where((i) => i.urgency(currentOdo) != 'normal').toList()
      ..sort((a, b) => a.remainingKm(currentOdo).compareTo(b.remainingKm(currentOdo)));
    
    final activeCustom = allCustom.where((i) {
      if (_filterIndex == 1) return i.isOn;
      if (_filterIndex == 2) return !i.isOn;
      return true;
    }).toList();

    // Lọc lại Periodic để không lặp lại ở Upcoming (nếu đang ở bộ lọc Tất cả hoặc Đang bật)
    final normalPeriodic = periodicItems.where((i) => i.urgency(currentOdo) == 'normal').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nhắc lịch'),
        centerTitle: true,
        leading: const BackButton(),
        actions: const [SizedBox(width: 48)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            Container(color: AppColors.surface,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_filters.length, (i) => GestureDetector(
                    onTap: () => setState(() => _filterIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      decoration: BoxDecoration(
                        color: _filterIndex == i ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _filterIndex == i ? AppColors.primary : AppColors.divider),
                      ),
                      child: Text(
                        _filters[i],
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: _filterIndex == i ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )),
                ),
              ),
            ),

            // SẮP TỚI
            if (upcomingMaint.isNotEmpty || activeCustom.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'SẮP TỚI',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Container(color: AppColors.surface,
                child: ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    ...upcomingMaint.map((item) => Column(
                      children: [
                        _buildReminderItem(
                          icon: item.icon,
                          label: item.name,
                          sub: item.isOverdue(currentOdo)
                              ? 'Đã quá hạn ${item.overdueKm(currentOdo)} km'
                              : 'Còn ${item.remainingKm(currentOdo)} km · ODO $currentOdo km',
                          badge: item.urgency(currentOdo) == 'overdue' ? 'Quá hạn' : 'Gần tới',
                          level: item.urgency(currentOdo),
                          isOn: item.isReminderOn,
                          onToggle: (v) => ref.read(maintenanceItemNotifierProvider.notifier).toggleReminder(item.id, v),
                        ),
                        const Divider(height: 1, indent: 64),
                      ],
                    )),
                    ...activeCustom.map((item) => Column(
                      children: [
                        _buildReminderItem(
                          icon: Icons.notifications_active,
                          label: item.title,
                          sub: item.subtitle,
                          badge: 'Tùy chỉnh',
                          level: 'warning',
                          isOn: item.isOn,
                          onToggle: (v) {}, // Cập nhật trạng thái bật/tắt nhắc nhở tuỳ chỉnh
                        ),
                        const Divider(height: 1, indent: 64),
                      ],
                    )),
                  ],
                ),
              ),
            ],

            // ĐỊNH KỲ
            if (normalPeriodic.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'ĐỊNH KỲ',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  'Các hạng mục còn an toàn, chưa cần xử lý — chỉ để bạn theo dõi chu kỳ',
                  style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary),
                ),
              ),
              Container(color: AppColors.surface,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: normalPeriodic.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
                  itemBuilder: (context, index) {
                    final item = normalPeriodic[index];
                    return _buildReminderItem(
                      icon: item.icon,
                      label: item.name,
                      sub: item.isOverdue(currentOdo)
                          ? 'Đã quá hạn ${item.overdueKm(currentOdo)} km'
                          : 'Còn ${item.remainingKm(currentOdo)} km · mỗi ${item.intervalKm} km',
                      badge: 'Bình thường',
                      level: 'normal',
                      isOn: item.isReminderOn,
                      onToggle: (v) => ref.read(maintenanceItemNotifierProvider.notifier).toggleReminder(item.id, v),
                    );
                  },
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            // Nút thêm nhắc lịch
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddReminderScreen())),
                icon: const Icon(Icons.add, color: AppColors.primary, size: 18),
                label: Text(
                  'Thêm nhắc lịch',
                  style: GoogleFonts.beVietnamPro(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MotoBottomNavBar(
        currentIndex: -1, 
        onTap: (i) {
          if (i == 0) context.go('/home');
          if (i == 1) context.go('/fuel-history');
          if (i == 2) context.go('/profile');
        },
        onAddTap: () {
          if (ref.read(selectedVehicleIdProvider) == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng thêm xe trước khi sử dụng')));
            context.push('/add-vehicle');
          } else {
            context.push('/fuel-log');
          }
        },
      ),
    );
  }

  Widget _buildReminderItem({
    required IconData icon,
    required String label,
    required String sub,
    required String badge,
    required String level,
    required bool isOn,
    required ValueChanged<bool> onToggle,
  }) {
    final bgColor = _iconBg(level);
    final fgColor = _iconColor(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: fgColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        sub,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: fgColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: isOn,
            onChanged: onToggle,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
