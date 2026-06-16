import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );

    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(AppConstants.keyOnboardingDone) ?? false;

    if (!mounted) return;
    if (onboardingDone) {
      context.go(AppRoutes.login);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Stack(
            children: [
              // Background decorative circles
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: -80,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondary.withOpacity(0.06),
                  ),
                ),
              ),

              // Main content
              Center(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Icon
                      ScaleTransition(
                        scale: _scaleAnim,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.two_wheeler_rounded,
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // App name
                      SlideTransition(
                        position: _slideAnim,
                        child: Column(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppColors.primaryGradient.createShader(bounds),
                              child: const Text(
                                'MotoLog',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              AppConstants.appTagline,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: AppColors.textSecondaryDark,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Loading indicator at bottom
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Đang tải...',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
