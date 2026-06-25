import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motolog_mobile/theme/app_theme.dart';
import 'package:motolog_mobile/features/auth/providers/auth_provider.dart';
import 'package:motolog_mobile/features/vehicle/providers/vehicle_provider.dart';
import 'package:motolog_mobile/widgets/bottom_nav_bar.dart';
import 'package:motolog_mobile/features/maintenance/screens/maintenance_setup_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'edit_profile_screen.dart';
import 'app_settings_screen.dart';
import 'help_center_screen.dart';

/// Màn hình Hồ sơ cá nhân
/// Quản lý thông tin tài khoản, cài đặt hệ thống và chức năng Đăng xuất.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Center(
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                  image: currentUser?.photoURL != null ? DecorationImage(image: NetworkImage(currentUser!.photoURL!), fit: BoxFit.cover) : null,
                ),
                child: currentUser?.photoURL == null ? Icon(Icons.person, size: 50, color: AppColors.textSecondary) : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(currentUser?.displayName ?? 'Chưa cập nhật tên', style: GoogleFonts.beVietnamPro(fontSize: 20, fontWeight: FontWeight.w700)),
            Text(currentUser?.email ?? 'Chưa cập nhật email', style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textSecondary)),
            
            const SizedBox(height: 40),
            
            _buildOptionRow(context, Icons.person_outline, 'Chỉnh sửa thông tin', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
            }),
            _buildOptionRow(context, Icons.shield_outlined, 'Quản lý đăng nhập', () {
              launchUrl(Uri.parse('https://myaccount.google.com/security'));
            }),
            _buildOptionRow(context, Icons.tune, 'Thiết lập lại mốc bảo dưỡng', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const MaintenanceSetupScreen(isOnboarding: false)));
            }),
            _buildOptionRow(context, Icons.settings_outlined, 'Cài đặt ứng dụng', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSettingsScreen()));
            }),
            _buildOptionRow(context, Icons.help_outline, 'Trung tâm trợ giúp', () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
            }),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).signOut();
                  // Sẽ tự động bị AuthNotifier đẩy về splash/login do authState thay đổi.
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF3E0),
                  foregroundColor: AppColors.maintenanceRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text('Đăng xuất', style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MotoBottomNavBar(
        currentIndex: 2,
        onTap: (i) {
          if (i == 0) {
            context.go('/home');
          } else if (i == 1) {
            context.go('/fuel-history');
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

  Widget _buildOptionRow(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.greenChip, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.w500))),
            Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
