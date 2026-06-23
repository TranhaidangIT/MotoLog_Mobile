import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});
  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notifOn = true;
  String _unit = 'km';
  String _theme = 'Theo hệ thống';
  String _language = 'Tiếng Việt';

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
    child: Text(t.toUpperCase(), style: GoogleFonts.beVietnamPro(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 0.4)),
  );

  Widget _tile({required IconData icon, required String title, Widget? trailing, VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary, size: 22),
      title: Text(title, style: GoogleFonts.beVietnamPro(fontSize: 13, color: color)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
      onTap: onTap,
      tileColor: Colors.white,
    );
  }

  Future<void> _pickOption(String title, List<String> options, String current, ValueChanged<String> onPicked) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: options.map((o) => ListTile(
          title: Text(o),
          trailing: o == current ? const Icon(Icons.check, color: AppColors.primary) : null,
          onTap: () => Navigator.pop(ctx, o),
        )).toList()),
      ),
    );
    if (picked != null) onPicked(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt ứng dụng'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _sectionTitle('Thông báo'),
          _tile(
            icon: Icons.notifications_outlined,
            title: 'Thông báo nhắc lịch',
            trailing: Switch(value: _notifOn, activeColor: AppColors.primary, onChanged: (v) => setState(() => _notifOn = v)),
          ),

          _sectionTitle('Hiển thị'),
          _tile(
            icon: Icons.straighten_outlined,
            title: 'Đơn vị khoảng cách',
            trailing: Text(_unit, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
            onTap: () => _pickOption('Đơn vị', ['km', 'dặm (mi)'], _unit, (v) => setState(() => _unit = v)),
          ),
          _tile(
            icon: Icons.dark_mode_outlined,
            title: 'Giao diện',
            trailing: Text(_theme, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
            onTap: () => _pickOption('Giao diện', ['Sáng', 'Tối', 'Theo hệ thống'], _theme, (v) => setState(() => _theme = v)),
          ),
          _tile(
            icon: Icons.language_outlined,
            title: 'Ngôn ngữ',
            trailing: Text(_language, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
            onTap: () => _pickOption('Ngôn ngữ', ['Tiếng Việt', 'English'], _language, (v) => setState(() => _language = v)),
          ),

          _sectionTitle('Dữ liệu'),
          _tile(icon: Icons.cloud_sync_outlined, title: 'Sao lưu & đồng bộ', onTap: () {}),
          _tile(icon: Icons.file_download_outlined, title: 'Xuất dữ liệu (Excel/CSV)', onTap: () {}),
          _tile(
            icon: Icons.delete_outline,
            title: 'Xoá toàn bộ dữ liệu',
            color: Colors.redAccent,
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Xoá toàn bộ dữ liệu?'),
                content: const Text('Hành động này không thể hoàn tác. Toàn bộ lịch sử xăng, bảo dưỡng, phụ tùng sẽ bị xoá.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Xoá', style: TextStyle(color: Colors.redAccent))),
                ],
              ),
            ),
          ),

          _sectionTitle('Thông tin'),
          _tile(icon: Icons.info_outline, title: 'Phiên bản ứng dụng', trailing: Text('v1.0.0', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary))),
        ],
      ),
    );
  }
}
