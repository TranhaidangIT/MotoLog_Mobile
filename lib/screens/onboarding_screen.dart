import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/router/app_router.dart';
import '../theme/app_theme.dart';

/// Màn hình Giới thiệu (Onboarding)
/// Hiển thị các tính năng nổi bật của ứng dụng trong lần đầu tiên mở app.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Theo dõi dữ liệu',
      'subtitle': 'Ghi lại mọi chi phí',
      'description': 'Dễ dàng ghi chú lịch sử đổ xăng, các mốc bảo dưỡng định kỳ và thay thế phụ tùng.',
      'features': [
        {'icon': Icons.local_gas_station, 'title': 'Theo dõi xăng', 'desc': 'Ghi lại mỗi lần đổ xăng và mức tiêu hao'},
        {'icon': Icons.build_outlined, 'title': 'Quản lý bảo dưỡng', 'desc': 'Nhắc lịch bảo dưỡng, thay nhớt'},
        {'icon': Icons.settings_input_component_outlined, 'title': 'Lịch sử phụ tùng', 'desc': 'Theo dõi tuổi thọ các linh kiện'},
      ]
    },
    {
      'title': 'Thống kê trực quan',
      'subtitle': 'Nắm bắt chi phí',
      'description': 'Báo cáo chi tiết và biểu đồ giúp bạn biết chính xác mình đã chi tiêu bao nhiêu mỗi tháng.',
      'features': [
        {'icon': Icons.bar_chart, 'title': 'Biểu đồ chi phí', 'desc': 'Theo dõi biến động chi tiêu theo thời gian'},
        {'icon': Icons.pie_chart_outline, 'title': 'Phân tích danh mục', 'desc': 'So sánh tiền xăng và tiền bảo dưỡng'},
        {'icon': Icons.speed, 'title': 'Mức tiêu thụ', 'desc': 'Tính toán số km đi được trên mỗi lít xăng'},
      ]
    },
    {
      'title': 'Đồng bộ Đám mây',
      'subtitle': 'Dữ liệu an toàn',
      'description': 'Tự động sao lưu lên Google Cloud. Hỗ trợ offline khi mất mạng và tự động đẩy lên sau.',
      'features': [
        {'icon': Icons.cloud_done_outlined, 'title': 'Lưu trữ đám mây', 'desc': 'Không bao giờ mất dữ liệu khi đổi máy'},
        {'icon': Icons.wifi_off, 'title': 'Hoạt động Offline', 'desc': 'Ghi chú bình thường kể cả khi không có mạng'},
        {'icon': Icons.security, 'title': 'Bảo mật an toàn', 'desc': 'Dữ liệu được bảo vệ bằng tài khoản Google'},
      ]
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboardingDone, true);
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4EC), // Màu nền hơi xanh nhẹ giống bản thiết kế
      body: Stack(
        children: [
          // Background Image (Phần ảnh chứa chiếc xe và cây xăng)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Image.asset(
              'img/backroud/1.2.png',
              fit: BoxFit.cover,
            ),
          ),

          // Header Text (Nằm đè lên trên ảnh nếu ảnh là background trơn, 
          // nếu ảnh đã có chữ thì có thể bỏ phần này, nhưng thường text nên vẽ bằng code)
          Positioned(
            top: 80,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ghi lại hành trình\ncủa bạn và chiếc xe .',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 28,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1B1B1B),
                  ),
                ),
              ],
            ),
          ),

          // White Card Container at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (idx) => setState(() => _currentIndex = idx),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        final features = page['features'] as List;

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: features.map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: index == 0 ? AppColors.primary.withValues(alpha: 0.8) : 
                                             (index == 1 ? AppColors.fuelOrange.withValues(alpha: 0.8) : AppColors.maintenanceRed.withValues(alpha: 0.8)),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(f['icon'], color: Colors.white, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          f['title'],
                                          style: GoogleFonts.beVietnamPro(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          f['desc'],
                                          style: GoogleFonts.beVietnamPro(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )).toList(),
                          ),
                        );
                      },
                    ),
                  ),

                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index ? AppColors.primary : AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                  ),

                  const SizedBox(height: 24),

                  // Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentIndex == _pages.length - 1 ? 'Bắt đầu' : 'Tiếp tục',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
