import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  int _filterIndex = 0;
  final _filters = ['Tất cả', 'Sắp tới', 'Đã hoàn thành'];

  static const List<Map<String, dynamic>> _items = [
    { 'icon': 'img/phu-tung/thay_nhot_may.png', 'label': 'Thay nhớt máy', 'interval': 'Định kỳ sau mỗi 1.500 – 2.000 km', 'remaining': 500, 'total': 2000 },
    { 'icon': 'img/phu-tung/ve_sinh_noi_cvt.png', 'label': 'Vệ sinh nồi (CVT)', 'interval': 'Định kỳ sau mỗi 8.000 – 10.000 km', 'remaining': 2300, 'total': 10000 },
    { 'icon': 'img/phu-tung/thay_bugi.png', 'label': 'Thay bugi', 'interval': 'Định kỳ sau mỗi 8.000 – 10.000 km', 'remaining': 2300, 'total': 10000 },
    { 'icon': 'img/phu-tung/thay_loc_gio.png', 'label': 'Thay lọc gió', 'interval': 'Định kỳ sau mỗi 10.000 – 12.000 km', 'remaining': 4300, 'total': 12000 },
    { 'icon': 'img/phu-tung/thay_nuoc_lam_mat.png', 'label': 'Thay nước làm mát', 'interval': 'Định kỳ sau mỗi 12.000 – 15.000 km', 'remaining': 6300, 'total': 15000 },
    { 'icon': 'img/phu-tung/thay_ac_quy.png', 'label': 'Thay ắc quy', 'interval': 'Định kỳ sau mỗi 2 năm hoặc 20.000 km', 'remaining': 3500, 'total': 20000 },
    { 'icon': 'img/phu-tung/thay_dau_hop_so.png', 'label': 'Thay dầu hộp số', 'interval': 'Định kỳ sau mỗi 5.000 – 6.000 km', 'remaining': 1200, 'total': 6000 },
    { 'icon': 'img/phu-tung/thay_lop.png', 'label': 'Thay lốp', 'interval': 'Định kỳ sau mỗi 15.000 – 20.000 km', 'remaining': 8000, 'total': 20000 },
    { 'icon': 'img/phu-tung/thay_ma_phanh.png', 'label': 'Thay má phanh', 'interval': 'Định kỳ sau mỗi 10.000 km', 'remaining': 4000, 'total': 10000 },
    { 'icon': 'img/phu-tung/thay_xich_tai.png', 'label': 'Thay xích tải/curoa', 'interval': 'Định kỳ sau mỗi 15.000 km', 'remaining': 5000, 'total': 15000 },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bảo dưỡng'),
        centerTitle: true,
        leading: const BackButton(),
        actions: const [SizedBox(width: 48)], // Empty space to center title
      ),
      body: SingleChildScrollView(
        child: Column(
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
            
            // Item list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                double remaining = (item['remaining'] as int).toDouble();
                double total = (item['total'] as int).toDouble();
                double progressValue = 1 - (remaining / total);
                if (progressValue < 0) progressValue = 0;
                if (progressValue > 1) progressValue = 1;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        item['icon'] as String,
                        width: 48, height: 48,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['label'] as String,
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['interval'] as String,
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progressValue,
                                backgroundColor: AppColors.greenChip,
                                color: AppColors.primary,
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Còn ${(item['remaining'] as int)} km',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),

            // Nút thêm bảo dưỡng
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: ElevatedButton.icon(
                onPressed: () => context.push('/add-maintenance'),
                icon: const Icon(Icons.add),
                label: const Text('Thêm bảo dưỡng'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
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
}
