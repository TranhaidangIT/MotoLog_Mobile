import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/home'); // Sẽ bị GoRouter đẩy về /login nếu chưa đăng nhập
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('img/backroud/1.1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                // Logo
                const _MotoLogLogo(size: 100),
                const SizedBox(height: 20),
                // Brand name
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Moto',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: 'Log',
                        style: GoogleFonts.beVietnamPro(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Theo dõi chiếc xe\ncủa bạn mỗi ngày',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                // Page indicator dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == 0 ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == 0 ? AppColors.primary : AppColors.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MotoLogLogo extends StatelessWidget {
  final double size;
  const _MotoLogLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset('img/logo/logo-app-removebg-preview.png', width: size * 1.8, height: size * 1.8, fit: BoxFit.contain);
  }
}
