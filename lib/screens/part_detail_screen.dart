import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/part_record.dart';

class PartDetailScreen extends StatelessWidget {
  final PartRecord part;
  const PartDetailScreen({super.key, required this.part});

  void _openFullPhoto(BuildContext context, String? path) {
    if (path == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(child: InteractiveViewer(child: Image.file(File(path)))),
    )));
  }

  Widget _photoColumn(BuildContext context, {required String label, required String? path}) {
    return Expanded(
      child: Column(children: [
        GestureDetector(
          onTap: () => _openFullPhoto(context, path),
          child: AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: path != null
                ? Image.file(File(path), fit: BoxFit.cover)
                : Container(color: AppColors.greenChip,
                    child: const Icon(Icons.image_not_supported_outlined, color: AppColors.primary)),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(part.name), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            _photoColumn(context, label: 'Trước khi thay', path: part.beforePhotoPath),
            const SizedBox(width: 12),
            _photoColumn(context, label: 'Sau khi thay', path: part.afterPhotoPath),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Column(children: [
              _InfoRow(icon: Icons.calendar_today_outlined, label: 'Ngày thay', value: part.dateText),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(icon: Icons.speed_outlined, label: 'ODO', value: '${part.odo} km'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(icon: Icons.payments_outlined, label: 'Chi phí', value: part.costText),
              if (part.note != null && part.note!.isNotEmpty) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                _InfoRow(icon: Icons.notes_outlined, label: 'Ghi chú', value: part.note!),
              ],
            ]),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary))),
        Flexible(child: Text(value, textAlign: TextAlign.right, style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}
