import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  final List<_OnboardPage> _pages = [
    _OnboardPage(
      icon: Icons.two_wheeler_rounded,
      iconColor: AppColors.primary,
      title: 'Quản lý nhiều xe',
      description:
          'Thêm tất cả xe của bạn và theo dõi từng chiếc một cách dễ dàng và có tổ chức.',
    ),
    _OnboardPage(
      icon: Icons.local_gas_station_rounded,
      iconColor: AppColors.secondary,
      title: 'Nhật ký nhiên liệu',
      description:
          'Ghi lại mỗi lần đổ xăng. Tự động tính tiêu hao nhiên liệu theo km.',
    ),
    _OnboardPage(
      icon: Icons.build_circle_rounded,
      iconColor: AppColors.success,
      title: 'Lịch bảo dưỡng',
      description:
          'Không bao giờ bỏ lỡ lịch bảo dưỡng. Nhận nhắc nhở trước khi đến hạn.',
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkGradient
              : LinearGradient(
                  colors: [AppColors.backgroundLight, AppColors.surfaceLight],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Bỏ qua'),
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, i) => _OnboardPageView(page: _pages[i]),
                ),
              ),

              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: AppConstants.animNormal,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageCtrl.nextPage(
                          duration: AppConstants.animNormal,
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finish();
                      }
                    },
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'Tiếp theo' : 'Bắt đầu ngay',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _OnboardPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}

class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;

  const _OnboardPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon container
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: page.iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: page.iconColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  page.icon,
                  size: 56,
                  color: page.iconColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }
}
