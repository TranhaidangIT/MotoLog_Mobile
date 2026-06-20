import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    
    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email và mật khẩu')),
      );
      return;
    }

    await ref.read(authNotifierProvider.notifier).signInWithEmail(email, pass);
  }

  Future<void> _loginGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    // Theo dõi trạng thái auth (AsyncLoading...)
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    // Lắng nghe lỗi để hiển thị SnackBar
    ref.listen<AsyncValue<void>>(authNotifierProvider, (_, state) {
      if (!state.isLoading && state.hasError) {
        final errorMsg = getAuthErrorMessage(state.error!);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),

              // Logo mark
              Image.asset('img/logo/logo-app-removebg-preview.png', width: 140, height: 140, fit: BoxFit.contain),
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
                    Text('Người dùng', style: GoogleFonts.beVietnamPro(color: AppColors.primary, fontWeight: FontWeight.w600)),
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
                enabled: !isLoading,
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
                enabled: !isLoading,
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
                    onChanged: isLoading ? null : (v) => setState(() => _rememberMe = v!),
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
                onPressed: isLoading ? null : _login,
                child: isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Đăng nhập'),
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
                onTap: isLoading ? () {} : _loginGoogle,
              ),
              const SizedBox(height: 10),
              _SocialButton(
                label: 'Đăng nhập với Facebook',
                icon: Icons.facebook,
                color: const Color(0xFF1877F2),
                onTap: () {},
              ),
              const SizedBox(height: 24),

              // Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Chưa có tài khoản? ', style: GoogleFonts.beVietnamPro(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => context.push('/register'),
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
