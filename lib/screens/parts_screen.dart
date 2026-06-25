import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/vehicle_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import 'package:go_router/go_router.dart';
import '../providers/maintenance_provider.dart';
import '../data/models/maintenance_entry.dart';
import 'add_part_screen.dart';

class PartsScreen extends ConsumerStatefulWidget {
  const PartsScreen({super.key});
  @override
  ConsumerState<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends ConsumerState<PartsScreen> {
  int _filterIndex = 0;
  static const _filters = ['Tất cả', 'Gần đây'];

  @override
  Widget build(BuildContext context) {
    final maintenanceAsync = ref.watch(maintenanceListProvider);
    final allParts = maintenanceAsync.valueOrNull?.where((e) => e.type == MaintenanceType.parts).toList() ?? [];
    
    // Sort and filter logic can be added here based on _filterIndex
    final parts = List<MaintenanceEntry>.from(allParts);

    return Scaffold(
      appBar: AppBar(title: const Text('Phụ tùng')),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(children: List.generate(_filters.length, (i) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filterIndex = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _filterIndex == i ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _filterIndex == i ? AppColors.primary : AppColors.divider),
                ),
                child: Text(_filters[i], style: GoogleFonts.beVietnamPro(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: _filterIndex == i ? Colors.white : AppColors.textSecondary,
                )),
              ),
            ),
          ))),
        ),
        const Divider(height: 1),
        Expanded(
          child: parts.isEmpty
            ? Center(child: Text('Chưa có phụ tùng nào được ghi nhận',
                style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textSecondary)))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: parts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final p = parts[i];
                  final costText = '${NumberFormat('#,###', 'vi_VN').format(p.cost)} đ';
                  final dateText = DateFormat('dd/MM/yyyy').format(p.date);
                  
                  return GestureDetector(
                    onTap: () {
                      // Navigator.push(context, MaterialPageRoute(builder: (_) => PartDetailScreen(part: p)));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tính năng xem chi tiết đang được cập nhật')));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                      ),
                      child: Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: p.afterImageUrl != null && p.afterImageUrl!.isNotEmpty
                            ? Image.file(File(p.afterImageUrl!), width: 56, height: 56, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(width: 56, height: 56, color: AppColors.greenChip, child: const Icon(Icons.settings_input_component_outlined, color: AppColors.primary)))
                            : Container(width: 56, height: 56, color: AppColors.greenChip,
                                child: const Icon(Icons.settings_input_component_outlined, color: AppColors.primary)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.title, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('$dateText · ODO ${p.odometer} km', style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(costText, style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
                        ]),
                      ]),
                    ),
                  );
                },
              ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddPartScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Thêm phụ tùng'),
            ),
          ),
        ),
      ]),
      bottomNavigationBar: MotoBottomNavBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 0) {
            context.go('/home');
          } else if (i == 1) {
            context.go('/fuel-history');
          } else if (i == 2) {
            context.go('/profile');
          }
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
