import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../providers/vehicle_provider.dart';

class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);
    final selectedVehicleId = ref.watch(selectedVehicleIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Danh sách xe'),
        centerTitle: true,
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => context.push('/add-vehicle'),
          ),
        ],
      ),
      body: vehiclesAsync.when(
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Bạn chưa có xe nào', style: GoogleFonts.beVietnamPro(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/add-vehicle'),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm xe mới'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final v = vehicles[index];
              final isDefault = v.id == selectedVehicleId;
              
              // Thủ thuật hình ảnh mặc định theo loại xe (lưu ở engineCapacity)
              String defaultImage = 'img/backroud/3.1.png'; // Ảnh xe số mặc định
              if (v.engineCapacity == 'Xe tay ga') {
                defaultImage = 'img/backroud/2.1.png'; // Ảnh xe ga mặc định
              } else if (v.engineCapacity == 'Xe côn tay / PKL') {
                defaultImage = 'img/backroud/4.1.png'; // Thêm nếu có
              }

              return GestureDetector(
                onTap: () {
                  // Bấm vào xe thì sang trang chi tiết xe đó
                  context.push('/my-vehicle?id=${v.id}');
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(
                      color: isDefault ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      // Hình xe
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 80,
                          height: 80,
                          color: Colors.white,
                          child: v.imageUrl != null && v.imageUrl!.isNotEmpty
                              ? (v.imageUrl!.startsWith('http') 
                                  ? Image.network(v.imageUrl!, fit: BoxFit.cover)
                                  : Image.asset(v.imageUrl!, fit: BoxFit.cover)) // Dùng tạm asset nếu không phải URL thật, hoặc xử lý file logic sau
                              : Image.asset(defaultImage, fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Thông tin xe
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v.displayName, style: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(v.plateNumber, style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(
                              isDefault ? 'Mặc định' : '${v.odometer.toStringAsFixed(0)} km',
                              style: GoogleFonts.beVietnamPro(
                                fontSize: 13, 
                                color: isDefault ? AppColors.primary : AppColors.textSecondary,
                                fontWeight: isDefault ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Nút Check
                      GestureDetector(
                        onTap: () {
                          // Chọn làm mặc định
                          ref.read(selectedVehicleIdProvider.notifier).select(v.id);
                        },
                        child: Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDefault ? AppColors.primary : AppColors.divider,
                              width: 2,
                            ),
                            color: isDefault ? AppColors.primary : Colors.transparent,
                          ),
                          child: isDefault
                              ? const Icon(Icons.check, color: Colors.white, size: 16)
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Lỗi: $e')),
      ),
    );
  }
}
