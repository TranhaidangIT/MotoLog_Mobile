import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/vehicle_provider.dart';
import '../providers/maintenance_provider.dart';
import '../providers/maintenance_item_provider.dart';
import '../data/models/maintenance_entry.dart';

/// Màn hình Chi tiết Hạng mục Bảo dưỡng
/// Hiển thị tiến độ bảo dưỡng, lịch sử các lần thực hiện và hình ảnh chứng từ.
class MaintenanceItemDetailScreen extends ConsumerStatefulWidget {
  final String itemId;
  const MaintenanceItemDetailScreen({super.key, required this.itemId});

  @override
  ConsumerState<MaintenanceItemDetailScreen> createState() => _MaintenanceItemDetailScreenState();
}

class _MaintenanceItemDetailScreenState extends ConsumerState<MaintenanceItemDetailScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  final _dateFormat = DateFormat('dd/MM/yyyy');

  Widget _buildProgressBar(double progress, bool isOverdue) {
    return Container(
      height: 8,
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(4)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final p = progress.clamp(0.0, 1.0);
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: constraints.maxWidth * p,
              decoration: BoxDecoration(
                color: isOverdue ? const Color(0xFFD32F2F) : AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicleAsync = ref.watch(selectedVehicleProvider);
    final currentOdo = vehicleAsync.valueOrNull?.odometer.toInt() ?? 0;
    
    final items = ref.watch(maintenanceItemNotifierProvider);
    final item = items.firstWhere((e) => e.id == widget.itemId);

    final allEntriesAsync = ref.watch(maintenanceNotifierProvider);
    final allEntries = allEntriesAsync.valueOrNull ?? [];
    final entries = allEntries.where((e) => e.title == item.name).toList();
    entries.sort((a, b) => b.date.compareTo(a.date)); // Mới nhất lên đầu

    final latestEntry = entries.isNotEmpty ? entries.first : null;
    final historyEntries = entries.length > 1 ? entries.sublist(1) : <MaintenanceEntry>[];

    final isOverdue = item.isOverdue(currentOdo);
    final remaining = item.remainingKm(currentOdo);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(item.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Progress Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: const BoxDecoration(color: AppColors.greenChip, shape: BoxShape.circle),
                    child: Icon(item.icon, color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Chu kỳ mỗi ${item.intervalKm} km',
                          style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 8),
                        _buildProgressBar(item.progress(currentOdo), isOverdue),
                        const SizedBox(height: 8),
                        if (isOverdue)
                          Text(
                            'Đã quá hạn ${item.overdueKm(currentOdo)} km',
                            style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFFD32F2F)),
                          )
                        else
                          Text(
                            'Còn $remaining km',
                            style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text('LẦN THAY GẦN NHẤT', style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            
            if (latestEntry == null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Text('Chưa có dữ liệu bảo dưỡng', style: GoogleFonts.beVietnamPro(color: AppColors.textSecondary)),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (latestEntry.imagePath != null && latestEntry.imagePath!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(latestEntry.imagePath!),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 100, width: double.infinity, color: AppColors.surface,
                            child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ngày thay', style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary)),
                        Text(_dateFormat.format(latestEntry.date), style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('ODO lúc thay', style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary)),
                        Text('${latestEntry.odometer.toInt()} km', style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (latestEntry.cost > 0) ...[
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Chi phí', style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary)),
                          Text(_currencyFormat.format(latestEntry.cost), style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

            const SizedBox(height: 24),
            Text('LỊCH SỬ BẢO DƯỠNG', style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 12),

            if (historyEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Không có lịch sử cũ', style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary)),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: historyEntries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = historyEntries[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        if (entry.imagePath != null && entry.imagePath!.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(entry.imagePath!), width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: AppColors.surface, child: const Icon(Icons.broken_image, size: 20, color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_dateFormat.format(entry.date), style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('ODO: ${entry.odometer.toInt()} km', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        if (entry.cost > 0)
                          Text(_currencyFormat.format(entry.cost), style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
