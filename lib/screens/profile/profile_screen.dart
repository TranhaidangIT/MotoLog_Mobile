import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/vehicle_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final vehiclesAsync = ref.watch(vehicleNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Lấy thông tin user hiện tại từ Firebase
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text('Tài khoản'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: currentUser?.photoURL != null
                        ? ClipOval(
                            child: Image.network(
                              currentUser!.photoURL!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          )
                        : const Icon(Icons.person_rounded,
                            color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentUser?.displayName ?? 'Người dùng',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    currentUser?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Stats row
                  vehiclesAsync.when(
                    data: (vehicles) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatBadge(
                            label: 'Xe', value: vehicles.length.toString()),
                        Container(width: 1, height: 30, color: AppColors.borderLight),
                        _StatBadge(label: 'Tháng sử dụng', value: '1'),
                      ],
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                  const SizedBox(height: 24),

                  // === SETTINGS SECTION ===
                  _SectionHeader('Giao diện'),
                  _SettingCard(children: [
                    // Theme toggle
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      title: const Text('Chế độ tối'),
                      subtitle: Text(
                        themeMode == ThemeMode.dark
                            ? 'Đang bật'
                            : themeMode == ThemeMode.light
                                ? 'Đang tắt'
                                : 'Theo hệ thống',
                      ),
                      trailing: Switch(
                        value: themeMode == ThemeMode.dark ||
                            (themeMode == ThemeMode.system && isDark),
                        activeColor: AppColors.primary,
                        onChanged: (_) =>
                            ref.read(themeModeProvider.notifier).toggle(),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  _SectionHeader('Quản lý'),
                  _SettingCard(children: [
                    ListTile(
                      leading: _SettingIcon(
                          icon: Icons.two_wheeler_rounded,
                          color: AppColors.secondary),
                      title: const Text('Quản lý xe'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/vehicle/add'),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: _SettingIcon(
                          icon: Icons.notifications_outlined,
                          color: AppColors.warning),
                      title: const Text('Nhắc nhở bảo dưỡng'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: _SettingIcon(
                          icon: Icons.backup_outlined,
                          color: AppColors.success),
                      title: const Text('Sao lưu dữ liệu'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 16),

                  _SectionHeader('Về ứng dụng'),
                  _SettingCard(children: [
                    ListTile(
                      leading: _SettingIcon(
                          icon: Icons.info_outline, color: AppColors.secondary),
                      title: const Text('Phiên bản'),
                      trailing: Text(
                        '1.0.0',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    ListTile(
                      leading: _SettingIcon(
                          icon: Icons.star_outline, color: AppColors.warning),
                      title: const Text('Đánh giá ứng dụng'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ]),
                  const SizedBox(height: 16),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Đăng xuất Firebase thực sự
                        await ref
                            .read(authNotifierProvider.notifier)
                            .signOut();
                        if (!context.mounted) return;
                        context.go(AppRoutes.login);
                      },
                      icon: const Icon(Icons.logout_rounded,
                          color: AppColors.error),
                      label: const Text(
                        'Đăng xuất',
                        style: TextStyle(color: AppColors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;

  const _StatBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800, color: AppColors.primary),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SettingIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
