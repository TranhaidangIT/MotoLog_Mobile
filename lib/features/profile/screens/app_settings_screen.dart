import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:motolog_mobile/theme/app_theme.dart';
import 'package:motolog_mobile/providers/settings_provider.dart';
import 'package:motolog_mobile/features/vehicle/providers/vehicle_provider.dart';
import 'package:motolog_mobile/features/auth/providers/auth_provider.dart';
import 'package:motolog_mobile/features/export/screens/export_data_screen.dart';

/// Màn hình Cài đặt Ứng dụng
/// Cho phép người dùng tùy chỉnh thông báo, đơn vị hiển thị, giao diện, ngôn ngữ và quản lý dữ liệu.
class AppSettingsScreen extends ConsumerStatefulWidget {
  const AppSettingsScreen({super.key});
  @override
  ConsumerState<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends ConsumerState<AppSettingsScreen> {
  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
    child: Text(t.toUpperCase(), style: GoogleFonts.beVietnamPro(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 0.4)),
  );

  Widget _tile({required IconData icon, required String title, Widget? trailing, VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary, size: 22),
      title: Text(title, style: GoogleFonts.beVietnamPro(fontSize: 13, color: color)),
      trailing: trailing ?? Icon(Icons.chevron_right, size: 18, color: AppColors.textSecondary),
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
          trailing: o == current ? Icon(Icons.check, color: AppColors.primary) : null,
          onTap: () => Navigator.pop(ctx, o),
        )).toList()),
      ),
    );
    if (picked != null) onPicked(picked);
  }

  Future<void> _deleteAllData() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;
    
    // Hiện thông báo đang xử lý
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // Xóa tất cả các xe (Hàm delete trong vehicleNotifierProvider cũng xóa luôn dữ liệu trên Firestore)
    final vehicles = await ref.read(vehicleNotifierProvider.future);
    for (var v in vehicles) {
      await ref.read(vehicleNotifierProvider.notifier).delete(v.id);
    }
    
    // Đăng xuất và điều hướng về trang Login
    await ref.read(authNotifierProvider.notifier).signOut();
    if (mounted) {
      Navigator.pop(context); // Tắt loading
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Cài đặt ứng dụng'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _sectionTitle('Thông báo'),
          _tile(
            icon: Icons.notifications_outlined,
            title: 'Thông báo nhắc lịch',
            trailing: Switch(
              value: settings.notifOn, 
              activeThumbColor: AppColors.primary, 
              onChanged: (v) => settingsNotifier.updateNotifOn(v),
            ),
          ),

          _sectionTitle('Hiển thị'),
          _tile(
            icon: Icons.straighten_outlined,
            title: 'Đơn vị khoảng cách',
            trailing: Text(settings.unit, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
            onTap: () => _pickOption('Đơn vị', ['km', 'dặm (mi)'], settings.unit, (v) => settingsNotifier.updateUnit(v)),
          ),
          _tile(
            icon: Icons.dark_mode_outlined,
            title: 'Giao diện',
            trailing: Text(settings.theme, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
            onTap: () => _pickOption('Giao diện', ['Sáng', 'Tối', 'Theo hệ thống'], settings.theme, (v) => settingsNotifier.updateTheme(v)),
          ),
          _tile(
            icon: Icons.language_outlined,
            title: 'Ngôn ngữ',
            trailing: Text(settings.language, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
            onTap: () => _pickOption('Ngôn ngữ', ['Tiếng Việt', 'English'], settings.language, (v) => settingsNotifier.updateLanguage(v)),
          ),

          _sectionTitle('Dữ liệu'),
          _tile(
            icon: Icons.file_download_outlined, 
            title: 'Xuất dữ liệu (Excel/CSV)', 
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportDataScreen())),
          ),
          _tile(
            icon: Icons.delete_outline,
            title: 'Xoá toàn bộ dữ liệu',
            color: Colors.redAccent,
            onTap: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Cảnh báo nguy hiểm!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hành động này không thể hoàn tác. Toàn bộ lịch sử xăng, bảo dưỡng, phụ tùng của TẤT CẢ các xe sẽ bị xoá hoàn toàn.'),
                    const SizedBox(height: 12),
                    Text(
                      'Vui lòng ĐỒNG BỘ HOẶC XUẤT DỮ LIỆU qua tính năng (Xuất dữ liệu Excel/CSV) trước khi xoá, nếu không dữ liệu sẽ KHÔNG THỂ PHỤC HỒI!',
                      style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600, color: Colors.redAccent),
                    ),
                  ],
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _deleteAllData();
                    }, 
                    child: const Text('Đã hiểu, Xóa', style: TextStyle(color: Colors.redAccent)),
                  ),
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
