import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import '../screens/main/widgets/quick_add_menu.dart';
import 'add_part_screen.dart';
import 'part_detail_screen.dart';
import '../models/part_record.dart';

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key});
  @override
  State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  int _filterIndex = 0;
  static const _filters = ['Tất cả', 'Gần đây'];

  // TODO: thay bằng dữ liệu thật từ storage/database
  final List<PartRecord> _parts = [];

  @override
  Widget build(BuildContext context) {
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
          child: _parts.isEmpty
            ? Center(child: Text('Chưa có phụ tùng nào được ghi nhận',
                style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textSecondary)))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _parts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final p = _parts[i];
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartDetailScreen(part: p))),
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
                          child: p.afterPhotoPath != null
                            ? Image.file(File(p.afterPhotoPath!), width: 56, height: 56, fit: BoxFit.cover)
                            : Container(width: 56, height: 56, color: AppColors.greenChip,
                                child: const Icon(Icons.settings_input_component_outlined, color: AppColors.primary)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(p.name, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('${p.dateText} · ODO ${p.odo} km', style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
                        ])),
                        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(p.costText, style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w700)),
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
        onTap: (i) {},
        onAddTap: () => QuickAddMenu.show(context),
      ),
    );
  }
}
