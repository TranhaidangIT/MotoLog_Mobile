import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/vehicle_provider.dart';

/// Màn hình Quản lý Garage (Danh sách xe)
/// Liệt kê các xe đã thêm, cho phép chọn xe mặc định hoặc thêm xe mới.
class GarageScreen extends ConsumerWidget {
  const GarageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);
    final selectedVehicleId = ref.watch(selectedVehicleIdProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Garage của tôi',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimaryLight,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Nút tròn màu vàng cam "+" ở góc trên bên phải
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => context.push('/vehicle/add'),
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: vehiclesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Lỗi: $err')),
        data: (vehicles) {
          if (vehicles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có xe nào trong Garage',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/vehicle/add'),
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm xe ngay'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              final isActive = vehicle.id == selectedVehicleId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    // Chọn xe này làm active và vào trang chi tiết
                    ref
                        .read(selectedVehicleIdProvider.notifier)
                        .select(vehicle.id);
                    context.push('/vehicle/${vehicle.id}');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primary.withValues(alpha: 0.3)
                            : AppColors.borderLight,
                        width: isActive ? 1.5 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // Ảnh xe máy
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariantLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: vehicle.imageUrl != null &&
                                    vehicle.imageUrl!.isNotEmpty
                                ? (vehicle.imageUrl!.startsWith('assets/')
                                    ? Image.asset(vehicle.imageUrl!,
                                        fit: BoxFit.contain)
                                    : vehicle.imageUrl!.startsWith('http')
                                        ? Image.network(vehicle.imageUrl!, fit: BoxFit.contain)
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
                        const SizedBox(width: 16),

                        // Thông tin xe
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${vehicle.brand} ${vehicle.name}',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryLight,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                vehicle.plateNumber,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.speed_rounded,
                                    size: 14,
                                    color: AppColors.textHintLight,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    AppFormatters.km(vehicle.odometer),
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Checkbox chọn xe active ở góc phải
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(selectedVehicleIdProvider.notifier)
                                .select(vehicle.id);
                          },
                          child: Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.textHintLight,
                                width: isActive ? 6 : 2,
                              ),
                            ),
                            child: isActive
                                ? const Center(
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
