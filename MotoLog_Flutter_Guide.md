# MotoLog – Flutter UI Code

> Ứng dụng quản lý xe máy | Theo dõi – Bảo dưỡng – Tiết kiệm

Toàn bộ 6 màn hình được tái hiện 100% theo mockup:
1. Splash Screen
2. Login Screen
3. Home Screen
4. Đổ xăng (Form)
5. Lịch sử đổ xăng
6. Thống kê chi phí

---

## Cấu trúc thư mục

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart
├── screens/
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── fuel_log_screen.dart
│   ├── fuel_history_screen.dart
│   └── statistics_screen.dart
└── widgets/
    └── bottom_nav_bar.dart
```

---

## `pubspec.yaml` (dependencies)

```yaml
name: motolog
description: Ứng dụng quản lý xe máy

publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.2.1
  fl_chart: ^0.68.0
  intl: ^0.19.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
```

---

## `lib/theme/app_theme.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary    = Color(0xFF2E7D32);   // Green 800
  static const Color primaryLight = Color(0xFF4CAF50); // Green 500
  static const Color accent     = Color(0xFF66BB6A);   // Green 400
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color fuelOrange = Color(0xFFFF6F00);   // for fuel cost label
  static const Color maintenanceRed = Color(0xFFE53935);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color divider   = Color(0xFFE0E0E0);
  static const Color greenChip = Color(0xFFE8F5E9);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.beVietnamProTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      titleTextStyle: GoogleFonts.beVietnamPro(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.beVietnamPro(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}
```

---

## `lib/main.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MotoLogApp());
}

class MotoLogApp extends StatelessWidget {
  const MotoLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoLog',
      theme: AppTheme.theme,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## `lib/widgets/bottom_nav_bar.dart`

```dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MotoBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MotoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              _NavItem(icon: Icons.home_outlined, label: 'Trang chủ', index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.local_gas_station_outlined, label: 'Đổ xăng', index: 1, current: currentIndex, onTap: onTap),
              _CenterAddButton(onTap: () => onTap(2)),
              _NavItem(icon: Icons.bar_chart_outlined, label: 'Thống kê', index: 3, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.person_outline, label: 'Cá nhân', index: 4, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool active = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: active ? AppColors.primary : AppColors.textSecondary, size: 24),
            const SizedBox(height: 2),
            Text(label,
              style: TextStyle(
                fontSize: 10,
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CenterAddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: Color(0x552E7D32), blurRadius: 8, offset: Offset(0, 4)),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Screen 1 – `lib/screens/splash_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient – city + road illustration feel
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8F5E9), Color(0xFFB2DFDB), Color(0xFF80CBC4)],
              ),
            ),
          ),

          // Road / city silhouette
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 260),
              painter: _SplashRoadPainter(),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                // Logo
                _MotoLogLogo(size: 100),
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
                      color: i == 0 ? AppColors.primary : AppColors.primary.withOpacity(0.3),
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

// Simple motorcycle SVG-like logo via CustomPaint
class _MotoLogLogo extends StatelessWidget {
  final double size;
  const _MotoLogLogo({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x222E7D32), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: const Center(
        child: Icon(Icons.two_wheeler, size: 52, color: AppColors.primary),
      ),
    );
  }
}

class _SplashRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGround = Paint()..color = const Color(0xFF4CAF50).withOpacity(0.3);
    final paintRoad = Paint()..color = const Color(0xFF455A64);

    // Ground
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.55), paintGround);

    // Road
    final roadPath = Path()
      ..moveTo(size.width * 0.2, size.height)
      ..lineTo(size.width * 0.4, size.height * 0.45)
      ..lineTo(size.width * 0.6, size.height * 0.45)
      ..lineTo(size.width * 0.8, size.height)
      ..close();
    canvas.drawPath(roadPath, paintRoad);

    // Road center line
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(size.width * 0.5, size.height), Offset(size.width * 0.5, size.height * 0.45), linePaint);
  }

  @override
  bool shouldRepaint(_) => false;
}
```

---

## Screen 2 – `lib/screens/login_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;
  bool _rememberMe = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _login() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Logo mark
              const Icon(Icons.two_wheeler, size: 56, color: AppColors.primary),
              const SizedBox(height: 12),

              Text(
                'Xin chào!\nChào mừng bạn đến',
                textAlign: TextAlign.center,
                style: GoogleFonts.beVietnamPro(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              RichText(
                text: TextSpan(children: [
                  TextSpan(text: 'Moto', style: GoogleFonts.beVietnamPro(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  TextSpan(text: 'Log', style: GoogleFonts.beVietnamPro(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ]),
              ),

              const SizedBox(height: 8),
              // Quick account select
              GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Xin chào, ', style: GoogleFonts.beVietnamPro(color: AppColors.textSecondary)),
                    Text('Trần Hải Đăng', style: GoogleFonts.beVietnamPro(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Text('Đăng nhập tài khoản khác >', style: GoogleFonts.beVietnamPro(color: AppColors.primary, fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                  hintText: 'Nhập email của bạn',
                ),
              ),
              const SizedBox(height: 14),

              // Password
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.textSecondary),
                  hintText: 'Nhập mật khẩu',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textSecondary),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Remember me
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v!),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  Text('Ghi nhớ đăng nhập', style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 18),

              // Login button
              ElevatedButton(
                onPressed: _login,
                child: const Text('Đăng nhập'),
              ),
              const SizedBox(height: 20),

              // Divider
              Row(children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('Hoặc đăng nhập bằng', style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary)),
                ),
                const Expanded(child: Divider()),
              ]),
              const SizedBox(height: 16),

              // Social buttons
              _SocialButton(
                label: 'Đăng nhập với Google',
                icon: Icons.g_mobiledata,
                color: const Color(0xFF4285F4),
                onTap: _login,
              ),
              const SizedBox(height: 10),
              _SocialButton(
                label: 'Đăng nhập với Facebook',
                icon: Icons.facebook,
                color: const Color(0xFF1877F2),
                onTap: _login,
              ),
              const SizedBox(height: 24),

              // Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Chưa có tài khoản? ', style: GoogleFonts.beVietnamPro(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () {},
                    child: Text('Đăng ký', style: GoogleFonts.beVietnamPro(color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: color, size: 22),
      label: Text(label, style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: const BorderSide(color: AppColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
```

---

## Screen 3 – `lib/screens/home_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';
import 'fuel_log_screen.dart';
import 'fuel_history_screen.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  int _carouselIndex = 0;

  static const List<Map<String, dynamic>> _bikes = [
    {'name': 'Honda Wave Alpha 110', 'plate': '65B1-123.45', 'km': '29.456', 'color': Color(0xFF1B5E20)},
    {'name': 'Yamaha Sirius 110',    'plate': '51K2-456.78', 'km': '12.100', 'color': Color(0xFF0D47A1)},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildBikeCarousel()),
            SliverToBoxAdapter(child: _buildQuickActions()),
            SliverToBoxAdapter(child: _buildMonthlySummary()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
      bottomNavigationBar: MotoBottomNavBar(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const FuelLogScreen()));
          } else if (i == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticsScreen()));
          } else {
            setState(() => _navIndex = i);
          }
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Xin chào,', style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textSecondary)),
            Row(children: [
              Text('Trần Hải Đăng', style: GoogleFonts.beVietnamPro(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(width: 6),
              const Text('👋', style: TextStyle(fontSize: 18)),
            ]),
          ]),
          Stack(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
              ),
              child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            ),
            Positioned(
              top: 6, right: 6,
              child: Container(
                width: 16, height: 16,
                decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                child: const Center(child: Text('2', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold))),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildBikeCarousel() {
    return Column(children: [
      SizedBox(
        height: 140,
        child: PageView.builder(
          onPageChanged: (i) => setState(() => _carouselIndex = i),
          itemCount: _bikes.length,
          itemBuilder: (_, i) {
            final bike = _bikes[i];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [bike['color'] as Color, (bike['color'] as Color).withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(color: (bike['color'] as Color).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: Stack(children: [
                  Positioned(
                    right: -10, bottom: -10,
                    child: Opacity(opacity: 0.15, child: Icon(Icons.two_wheeler, size: 130, color: Colors.white)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(bike['name'] as String, style: GoogleFonts.beVietnamPro(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: Text('Biển số: ${bike['plate']}', style: GoogleFonts.beVietnamPro(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                      ),
                      const Spacer(),
                      Text('Tổng quãng đường', style: GoogleFonts.beVietnamPro(color: Colors.white70, fontSize: 12)),
                      Text('${bike['km']} km', style: GoogleFonts.beVietnamPro(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                ]),
              ),
            );
          },
        ),
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_bikes.length, (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _carouselIndex == i ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: _carouselIndex == i ? AppColors.primary : AppColors.primary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        )),
      ),
    ]);
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.local_gas_station, 'label': 'Đổ xăng',  'screen': const FuelLogScreen()},
      {'icon': Icons.build_outlined,     'label': 'Bảo dưỡng', 'screen': null},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Chi phí', 'screen': null},
      {'icon': Icons.bar_chart,          'label': 'Thống kê', 'screen': const StatisticsScreen()},
      {'icon': Icons.two_wheeler,        'label': 'Xe của tôi','screen': null},
      {'icon': Icons.notifications_active_outlined, 'label': 'Nhắc lịch', 'screen': null},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: actions.map((a) => GestureDetector(
          onTap: () {
            final screen = a['screen'];
            if (screen != null) {
              Navigator.push(context, MaterialPageRoute(builder: (_) => screen as Widget));
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.greenChip, shape: BoxShape.circle),
                child: Icon(a['icon'] as IconData, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 8),
              Text(a['label'] as String, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ]),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tổng quan tháng này', style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _SummaryRow(label: 'Chi phí xăng', amount: '680.000 đ', color: AppColors.fuelOrange),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Chi phí bảo dưỡng', amount: '250.000 đ', color: AppColors.maintenanceRed),
          const Divider(height: 20),
          _SummaryRow(label: 'Tổng chi phí', amount: '930.000 đ', color: AppColors.textPrimary, bold: true),
        ]),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final bool bold;

  const _SummaryRow({required this.label, required this.amount, required this.color, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.beVietnamPro(fontSize: 14, color: AppColors.textSecondary)),
        Text(amount, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w600, color: color)),
      ],
    );
  }
}
```

---

## Screen 4 – `lib/screens/fuel_log_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class FuelLogScreen extends StatefulWidget {
  const FuelLogScreen({super.key});

  @override
  State<FuelLogScreen> createState() => _FuelLogScreenState();
}

class _FuelLogScreenState extends State<FuelLogScreen> {
  final _dateCtrl    = TextEditingController(text: '22/06/2024');
  final _placeCtrl   = TextEditingController();
  final _amountCtrl  = TextEditingController(text: '80.000');
  final _litersCtrl  = TextEditingController(text: '3,20');
  final _odoCtrl     = TextEditingController(text: '15.200');
  final _noteCtrl    = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đổ xăng'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildLabel('Ngày đổ'),
          const SizedBox(height: 6),
          TextField(
            controller: _dateCtrl,
            decoration: const InputDecoration(
              suffixIcon: Icon(Icons.calendar_today_outlined, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),

          _buildLabel('Địa điểm'),
          const SizedBox(height: 6),
          TextField(
            controller: _placeCtrl,
            decoration: const InputDecoration(
              hintText: 'Nhập địa điểm cây xăng',
              suffixIcon: Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLabel('Số tiền (VND)'),
              const SizedBox(height: 6),
              TextField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildLabel('Số lít'),
              const SizedBox(height: 6),
              TextField(
                controller: _litersCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ])),
          ]),
          const SizedBox(height: 16),

          _buildLabel('Chỉ số ODO (km)'),
          const SizedBox(height: 6),
          TextField(
            controller: _odoCtrl,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          _buildLabel('Ghi chú (không bắt buộc)'),
          const SizedBox(height: 6),
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Nhập ghi chú...'),
          ),
          const SizedBox(height: 20),

          // Calculation summary
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.greenChip,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Column(children: [
              Text('Tính toán', style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _CalcItem(label: 'Quãng đường', value: '— km')),
                Container(width: 1, height: 40, color: AppColors.accent.withOpacity(0.3)),
                Expanded(child: _CalcItem(label: 'Mức tiêu hao', value: '— km/lít')),
              ]),
            ]),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Lưu lại'),
          ),
          const SizedBox(height: 24),
        ]),
      ),
      bottomNavigationBar: MotoBottomNavBar(currentIndex: 1, onTap: (_) {}),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary));
  }
}

class _CalcItem extends StatelessWidget {
  final String label;
  final String value;
  const _CalcItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
      const SizedBox(height: 4),
      Text(value, style: GoogleFonts.beVietnamPro(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
    ]);
  }
}
```

---

## Screen 5 – `lib/screens/fuel_history_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class FuelHistoryScreen extends StatefulWidget {
  const FuelHistoryScreen({super.key});

  @override
  State<FuelHistoryScreen> createState() => _FuelHistoryScreenState();
}

class _FuelHistoryScreenState extends State<FuelHistoryScreen> {
  int _filterIndex = 0;
  static const _filters = ['Tất cả', 'Tháng này', 'Tháng trước', 'Tuỳ chọn'];

  static const _records = [
    {'date': '22/06/2024', 'station': 'Petrolimex Xuân Khánh', 'amount': '80.000 đ', 'liters': '3.20 lít', 'odo': '15.200 km', 'consumption': '58,0 km/lít'},
    {'date': '15/06/2024', 'station': 'Petrolimex Hưng Lợi',   'amount': '90.000 đ', 'liters': '3.50 lít', 'odo': '15.000 km', 'consumption': '60,0 km/lít'},
    {'date': '08/06/2024', 'station': 'Cửa hàng xăng dầu 47',  'amount': '70.000 đ', 'liters': '2.80 lít', 'odo': '14.800 km', 'consumption': '56,0 km/lít'},
    {'date': '01/06/2024', 'station': 'Petrolimex Cái Răng',   'amount': '75.000 đ', 'liters': '3.00 lít', 'odo': '14.500 km', 'consumption': '55,0 km/lít'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đổ xăng'),
        leading: const BackButton(),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: Icon(Icons.filter_list))],
      ),
      body: Column(children: [
        // Filter chips
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_filters.length, (i) => GestureDetector(
                onTap: () => setState(() => _filterIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: _filterIndex == i ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _filterIndex == i ? AppColors.primary : AppColors.divider),
                  ),
                  child: Text(_filters[i], style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _filterIndex == i ? Colors.white : AppColors.textSecondary,
                  )),
                ),
              )),
            ),
          ),
        ),

        // Stats summary
        Container(
          color: Colors.white,
          margin: const EdgeInsets.only(top: 1),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(children: [
            _StatCell(label: 'Tổng tiền', value: '680.000 đ', sub: '6 lần đổ'),
            Container(width: 1, height: 50, color: AppColors.divider),
            _StatCell(label: 'Tổng lít', value: '27,20 lít'),
            Container(width: 1, height: 50, color: AppColors.divider),
            _StatCell(label: 'Mức tiêu hao TB', value: '58,0 km/lít'),
            Container(width: 1, height: 50, color: AppColors.divider),
            _StatCell(label: 'Quãng đường', value: '1.578 km'),
          ]),
        ),

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 1),
            itemBuilder: (_, i) => _FuelRecordTile(record: _records[i]),
          ),
        ),
      ]),
      bottomNavigationBar: MotoBottomNavBar(currentIndex: 1, onTap: (_) {}),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  const _StatCell({required this.label, required this.value, this.sub});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(label, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary), textAlign: TextAlign.center),
        if (sub != null) Text(sub!, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _FuelRecordTile extends StatelessWidget {
  final Map<String, String> record;
  const _FuelRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(record['date']!, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 2),
          Text(record['station']!, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text('${record['liters']} • ODO: ${record['odo']}', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(record['amount']!, style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.greenChip, borderRadius: BorderRadius.circular(6)),
            child: Text(record['consumption']!, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ]),
    );
  }
}
```

---

## Screen 6 – `lib/screens/statistics_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav_bar.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê chi phí'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(children: [
          // Month selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tháng 6/2024', style: GoogleFonts.beVietnamPro(fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Total + Pie chart card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Tổng chi phí', style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary)),
                    Text('930.000 đ', style: GoogleFonts.beVietnamPro(fontSize: 26, fontWeight: FontWeight.w800)),
                  ]),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.greenChip,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(children: [
                      const Icon(Icons.arrow_downward, color: AppColors.primary, size: 14),
                      const SizedBox(width: 4),
                      Text('8%', style: GoogleFonts.beVietnamPro(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              ),
              Text('so với tháng trước', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 20),

              // Donut chart + legend
              Row(children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(value: 73.1, color: AppColors.primary, radius: 40, showTitle: false),
                        PieChartSectionData(value: 26.9, color: AppColors.fuelOrange, radius: 40, showTitle: false),
                        PieChartSectionData(value: 0.01, color: AppColors.divider, radius: 40, showTitle: false),
                      ],
                      centerSpaceRadius: 28,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _LegendItem(color: AppColors.primary, label: 'Xăng', amount: '680.000 đ (73,1%)'),
                  const SizedBox(height: 10),
                  _LegendItem(color: AppColors.fuelOrange, label: 'Bảo dưỡng', amount: '250.000 đ (26,9%)'),
                  const SizedBox(height: 10),
                  _LegendItem(color: AppColors.divider, label: 'Khác', amount: '0 đ (0%)'),
                ]),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // Bar chart – fuel cost
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Chi phí xăng', style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('680.000 đ', style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: BarChart(
                  BarChartData(
                    maxY: 320,
                    barGroups: _buildBarGroups(),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (v, _) {
                            const labels = ['1/6', '8/6', '15/6', '22/6', '30/6'];
                            final i = v.toInt();
                            return i < labels.length
                              ? Text(labels[i], style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary))
                              : const SizedBox();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          interval: 100,
                          getTitlesWidget: (v, _) => Text('${v.toInt()}k',
                            style: GoogleFonts.beVietnamPro(fontSize: 9, color: AppColors.textSecondary)),
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (_) => FlLine(color: AppColors.divider, strokeWidth: 0.5),
                    ),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(enabled: false),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Consumption summary
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Mức tiêu hao trung bình', style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Text('58,0 km/lít', style: GoogleFonts.beVietnamPro(fontSize: 22, fontWeight: FontWeight.w800)),
                ]),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.greenChip, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    const Icon(Icons.arrow_upward, color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text('5%', style: GoogleFonts.beVietnamPro(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 4),
                    Text('so với tháng trước', style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
      bottomNavigationBar: MotoBottomNavBar(currentIndex: 3, onTap: (_) {}),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    final values = [75.0, 90.0, 70.0, 80.0, 0.0];
    return List.generate(values.length, (i) => BarChartGroupData(
      x: i,
      barRods: [
        BarChartRodData(
          toY: values[i],
          color: values[i] > 0 ? AppColors.primary : Colors.transparent,
          width: 18,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ],
    ));
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String amount;
  const _LegendItem({required this.color, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w500)),
        Text(amount, style: GoogleFonts.beVietnamPro(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    ]);
  }
}
```

---

## Hướng dẫn chạy

```bash
# 1. Tạo project mới
flutter create motolog && cd motolog

# 2. Thay toàn bộ lib/ bằng code ở trên

# 3. Cài dependencies
flutter pub get

# 4. Chạy app
flutter run
```

---

## Màu sắc & Font chính

| Token | Hex | Dùng cho |
|---|---|---|
| `primary` | `#2E7D32` | Nút, icon, accent chính |
| `primaryLight` | `#4CAF50` | Hover, highlight |
| `accent` | `#66BB6A` | Border mềm, divider |
| `fuelOrange` | `#FF6F00` | Chi phí xăng |
| `maintenanceRed` | `#E53935` | Chi phí bảo dưỡng |
| Font | `Be Vietnam Pro` | Toàn bộ app (via google_fonts) |

---

## Tính năng nổi bật đã implement

- ✅ Splash Screen với road painter & page indicators
- ✅ Login Screen: social login, remember me, toggle password
- ✅ Home Screen: bike carousel, quick-action grid, monthly summary
- ✅ Fuel Log Form: dual-column inputs, live calculation area
- ✅ Fuel History: filter chips, stats header, rich list tiles
- ✅ Statistics: donut chart (fl_chart), bar chart, consumption card
- ✅ Bottom NavBar tùy chỉnh với FAB giữa
- ✅ Consistent theme (`Be Vietnam Pro` + green palette)

