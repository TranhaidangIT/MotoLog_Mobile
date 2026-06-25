import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motolog_mobile/theme/app_theme.dart';
import 'package:motolog_mobile/core/constants/vehicle_catalog_data.dart';
import 'add_edit_vehicle_screen.dart';

/// Màn hình Cài đặt Xe Nhanh
/// Hiển thị danh sách các mẫu xe phổ biến để người dùng lựa chọn và tự động điền thông số.
class QuickSetupVehicleScreen extends StatefulWidget {
  const QuickSetupVehicleScreen({super.key});

  @override
  State<QuickSetupVehicleScreen> createState() => _QuickSetupVehicleScreenState();
}

class _QuickSetupVehicleScreenState extends State<QuickSetupVehicleScreen> {
  String _searchQuery = '';
  
  @override
  Widget build(BuildContext context) {
    final filtered = localVehicleCatalog.where((c) {
      final text = '${c['brand']} ${c['model']} ${c['version']} ${c['color']} ${c['type']}'.toLowerCase();
      return text.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chọn xe của bạn'),
        centerTitle: true,
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Tìm xe, màu, phiên bản...',
                hintStyle: GoogleFonts.beVietnamPro(fontSize: 14, color: Colors.black38),
                prefixIcon: const Icon(Icons.search, color: Colors.black54),
                filled: true,
                fillColor: const Color(0xFFF0F2F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filtered[index];
                return GestureDetector(
                  onTap: () {
                    // Truyền dữ liệu qua màn hình AddEditVehicle
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddEditVehicleScreen(
                          prefilledData: {
                            'name': '${item['model']} ${item['version']} (${item['color']})',
                            'brand': item['brand'],
                            'model': item['model'],
                            'type': item['type'],
                            'year': item['year'].toString(),
                            'color': item['color'],
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Ảnh Xe Thật
                        Container(
                          width: 80, height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FA),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Transform.flip(
                            flipX: true,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Image.asset(item['image'], fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Thông tin Xe
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('${item['brand']} ${item['year']}', style: GoogleFonts.beVietnamPro(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ),
                              const SizedBox(height: 4),
                              Text(item['model'], style: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                              const SizedBox(height: 4),
                              Text('${item['version']} - Màu ${item['color']}', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.black26),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
