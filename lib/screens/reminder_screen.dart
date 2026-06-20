import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  int _filterIndex = 0;
  final _filters = ['Tất cả', 'Đang bật', 'Đã tắt'];

  static const _soonItems = [
    {
      'icon': Icons.opacity,
      'label': 'Thay nhớt máy',
      'sub': 'Còn 500 km · ODO 15.200 km',
      'badge': 'Gần tới',
      'level': 'urgent',
    },
    {
      'icon': Icons.local_gas_station,
      'label': 'Nhắc đổ xăng',
      'sub': 'Khi còn dưới 1/4 bình',
      'badge': 'Hôm nay',
      'level': 'warning',
    },
  ];

  static const _periodicItems = [
    {
      'icon': Icons.settings,
      'label': 'Vệ sinh nồi (CVT)',
      'sub': 'Còn 2.300 km · mỗi 10.000 km',
      'badge': 'Bình thường',
      'level': 'normal',
    },
    {
      'icon': Icons.electrical_services,
      'label': 'Thay bugi',
      'sub': 'Còn 2.300 km · mỗi 10.000 km',
      'badge': 'Bình thường',
      'level': 'normal',
    },
    {
      'icon': Icons.air,
      'label': 'Thay lọc gió',
      'sub': 'Còn 4.300 km · mỗi 12.000 km',
      'badge': 'Bình thường',
      'level': 'normal',
    },
    {
      'icon': Icons.water_drop,
      'label': 'Thay nước làm mát',
      'sub': 'Còn 6.300 km · mỗi 15.000 km',
      'badge': 'Bình thường',
      'level': 'normal',
    },
  ];

  Color _iconBg(String level) {
    switch (level) {
      case 'urgent':
        return AppColors.dangerRedBg;
      case 'warning':
        return AppColors.warningOrangeBg;
      default:
        return AppColors.greenChip;
    }
  }

  Color _iconColor(String level) {
    switch (level) {
      case 'urgent':
        return AppColors.dangerRed;
      case 'warning':
        return AppColors.warningOrange;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _soonItems.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
                itemBuilder: (context, index) => _buildReminderItem(_soonItems[index]),
              ),
            ),

            // ĐỊNH KỲ
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
            Container(color: AppColors.surface,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _periodicItems.length,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 64),
                itemBuilder: (context, index) => _buildReminderItem(_periodicItems[index]),
              ),
            ),
            
            const SizedBox(height: 16),
            // Nút thêm nhắc lịch
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: OutlinedButton.icon(
                onPressed: () {},
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
          if (i == 0) {
            context.go('/home');
          } else if (i == 1) {
            context.go('/fuel-history');
          } else if (i == 2) {
            context.go('/expense');
          } else if (i == 3) {
            context.go('/profile');
          }
        },
        onAddTap: () => context.push('/fuel-log'),
      ),
    );
  }

  Widget _buildReminderItem(Map<String, dynamic> item) {
    final level = item['level'] as String;
    final bgColor = _iconBg(level);
    final fgColor = _iconColor(level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              item['icon'] as IconData,
              color: fgColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['label'] as String,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['sub'] as String,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item['badge'] as String,
              style: GoogleFonts.beVietnamPro(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: fgColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
