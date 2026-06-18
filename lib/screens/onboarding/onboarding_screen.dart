import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final List<OnboardData> _pagesData = [
    OnboardData(
      backgroundImage: 'img/backroud/1.2.png',
      title: 'Ghi lại hành trình\ncủa bạn và chiếc xe',
      subtitle: 'Theo dõi xăng, bảo dưỡng và chi phí một cách dễ dàng.',
      features: [
        const OnboardFeature(
          icon: Icons.local_gas_station_rounded,
          iconColor: AppColors.primary,
          title: 'Theo dõi xăng',
          description: 'Ghi lại mỗi lần đổ xăng và mức tiêu hao nhiên liệu.',
        ),
        const OnboardFeature(
          icon: Icons.build_rounded,
          iconColor: AppColors.secondary,
          title: 'Quản lý bảo dưỡng',
          description: 'Nhắc lịch bảo dưỡng, thay nhớt và các hạng mục khác.',
        ),
        const OnboardFeature(
          icon: Icons.analytics_rounded,
          iconColor: Color(0xFF10B981),
          title: 'Thống kê chi phí',
          description: 'Xem báo cáo chi tiết và biểu đồ theo thời gian.',
        ),
      ],
    ),
    OnboardData(
      backgroundImage: 'img/backroud/1.1.png',
      title: 'Mọi thứ được\nđồng bộ & an toàn',
      subtitle: 'Dữ liệu được lưu trữ cẩn thận và chỉ thuộc về bạn.',
      features: [
        const OnboardFeature(
          icon: Icons.cloud_done_rounded,
          iconColor: Color(0xFF3B82F6),
          title: 'Đồng bộ dữ liệu',
          description: 'Đăng nhập để đồng bộ dữ liệu trên nhiều thiết bị.',
        ),
        const OnboardFeature(
          icon: Icons.shield_rounded,
          iconColor: AppColors.primary,
          title: 'Bảo mật thông tin',
          description: 'Thông tin của bạn luôn được bảo vệ tuyệt đối.',
        ),
      ],
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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // PageView
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pagesData.length,
            itemBuilder: (context, i) {
              final data = _pagesData[i];
              return Stack(
                children: [
                  // Illustration Background (full screen)
                  Positioned.fill(
                    child: Image.asset(
                      data.backgroundImage,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(),
                    ),
                  ),

                  // Text title & subtitle at the top
                  Positioned(
                    top: 60,
                    left: 24,
                    right: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          data.subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card nội dung trắng bo góc 32 ở cuối
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Features list
                          for (final feat in data.features)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          feat.iconColor.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      feat.icon,
                                      color: feat.iconColor,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          feat.title,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimaryLight,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          feat.description,
                                          style: GoogleFonts.outfit(
                                            fontSize: 12,
                                            color: AppColors.textSecondaryLight,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 12),

                          // Pagination Dots (dots inside the card)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pagesData.length,
                              (index) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 16 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? AppColors.primary
                                      : AppColors.borderLight,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Nút hành động Bắt đầu / Tiếp theo (full-width inside the card)
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentPage < _pagesData.length - 1) {
                                  _pageCtrl.nextPage(
                                    duration: AppConstants.animNormal,
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  _finish();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Text(
                                _currentPage == 0 ? 'Bắt đầu' : 'Tiếp theo',
                                style: GoogleFonts.outfit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Skip button at top right
          Positioned(
            top: 40,
            right: 16,
            child: TextButton(
              onPressed: _finish,
              child: Text(
                'Bỏ qua',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardData {
  final String backgroundImage;
  final String title;
  final String subtitle;
  final List<OnboardFeature> features;

  OnboardData({
    required this.backgroundImage,
    required this.title,
    required this.subtitle,
    required this.features,
  });
}

class OnboardFeature {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const OnboardFeature({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}
