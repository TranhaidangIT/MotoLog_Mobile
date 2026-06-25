import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../data/models/maintenance_entry.dart';

/// Màn hình Chi tiết Phụ tùng
/// Hiển thị hình ảnh trước/sau khi thay và thông tin chi tiết của một phụ tùng đã ghi nhận.
class PartDetailScreen extends StatelessWidget {
  final MaintenanceEntry entry;
  const PartDetailScreen({super.key, required this.entry});

  void _openFullPhoto(BuildContext context, String? path) {
    if (path == null) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
      body: Center(
        child: InteractiveViewer(
          child: path.startsWith('http') 
              ? CachedNetworkImage(imageUrl: path)
              : Image.file(File(path))
        )
      ),
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
                ? (path.startsWith('http')
                    ? CachedNetworkImage(imageUrl: path, fit: BoxFit.cover, errorWidget: (c,u,e) => const Icon(Icons.broken_image))
                    : Image.file(File(path), fit: BoxFit.cover))
                : Container(color: AppColors.greenChip,
                    child: Icon(Icons.image_not_supported_outlined, color: AppColors.primary)),
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
    final dateText = DateFormat('dd/MM/yyyy').format(entry.date);
    final costText = '${NumberFormat('#,###', 'vi_VN').format(entry.cost)} đ';

    return Scaffold(
      appBar: AppBar(title: Text(entry.title), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(children: [
            _photoColumn(context, label: 'Trước khi thay', path: entry.beforeImageUrl),
            const SizedBox(width: 12),
            _photoColumn(context, label: 'Sau khi thay', path: entry.afterImageUrl ?? entry.imagePath),
          ]),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
            ),
            child: Column(children: [
              _InfoRow(icon: Icons.calendar_today_outlined, label: 'Ngày thay', value: dateText),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(icon: Icons.speed_outlined, label: 'ODO', value: '${entry.odometer} km'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(icon: Icons.payments_outlined, label: 'Chi phí', value: costText),
              if (entry.note != null && entry.note!.isNotEmpty) ...[
                const Divider(height: 1, indent: 16, endIndent: 16),
                _InfoRow(icon: Icons.notes_outlined, label: 'Ghi chú', value: entry.note!),
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
