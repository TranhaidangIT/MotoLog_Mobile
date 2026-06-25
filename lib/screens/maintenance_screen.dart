import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../providers/maintenance_item_provider.dart';
import '../providers/vehicle_provider.dart';
import 'maintenance_item_detail_screen.dart';

/// Màn hình Danh sách Hạng mục Bảo dưỡng
/// Liệt kê các hạng mục cần bảo dưỡng, phân loại theo trạng thái và thanh tiến độ thực tế.
class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  int _filterIndex = 0;
  final _filters = ['Tất cả', 'Sắp tới'];

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(selectedVehicleProvider);
    final currentOdo = vehicleAsync.valueOrNull?.odometer.toInt() ?? 0;
    final allItems = ref.watch(maintenanceItemNotifierProvider);

    // Lọc items
    List<dynamic> displayItems = allItems;
    if (_filterIndex == 1) {
      displayItems = allItems.where((i) => i.urgency(currentOdo) != 'normal').toList()
        ..sort((a, b) => a.remainingKm(currentOdo).compareTo(b.remainingKm(currentOdo)));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bảo dưỡng'),
        centerTitle: true,
        leading: const BackButton(),
        actions: const [SizedBox(width: 48)],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Filter chips
            Container(
              color: AppColors.surface,
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
            displayItems.isEmpty 
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: Text(
                      _filterIndex == 1 ? 'Không có hạng mục nào sắp tới hạn 🎉' : 'Chưa có hạng mục bảo dưỡng',
                      style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textSecondary),
                    ),
                  ),
                )
              : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                final item = displayItems[index];
                double progressValue = item.progress(currentOdo);
                int remaining = item.remainingKm(currentOdo);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => MaintenanceItemDetailScreen(itemId: item.id)));
                  },
                  child: Container(
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
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                          child: Icon(item.icon, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: GoogleFonts.beVietnamPro(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Định kỳ sau mỗi ${item.intervalKm} km',
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
                              if (item.isOverdue(currentOdo))
                                Text(
                                  'Đã quá hạn ${item.overdueKm(currentOdo)} km',
                                  style: GoogleFonts.beVietnamPro(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFD32F2F),
                                  ),
                                )
                              else
                                Text(
                                  'Còn $remaining km',
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
}
