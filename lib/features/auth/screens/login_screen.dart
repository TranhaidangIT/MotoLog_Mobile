import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motolog_mobile/core/constants/app_colors.dart';
import 'package:motolog_mobile/core/utils/validators.dart';
import 'package:motolog_mobile/features/auth/providers/auth_provider.dart';

/// Màn hình Đăng nhập
/// Cho phép người dùng đăng nhập bằng Email/Mật khẩu hoặc qua các tài khoản mạng xã hội (Google).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authNotifierProvider.notifier).signInWithEmail(
          _emailCtrl.text,
          _passCtrl.text,
        );
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      _showError(getAuthErrorMessage(authState.error!));
    }
  }

  Future<void> _loginWithGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      final msg = getAuthErrorMessage(authState.error!);
      if (msg != 'Đăng nhập Google bị huỷ') {
        _showError(msg);
      }
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      _showError('Nhập email của bạn vào ô Email rồi nhấn Quên mật khẩu');
      return;
    }
    await ref.read(authNotifierProvider.notifier).sendPasswordReset(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã gửi link đặt lại mật khẩu đến $email'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'img/backroud/1.1.png',
              fit: BoxFit.cover,
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Logo MotoLog
                    Image.asset(
                      'img/logo/logo.png',
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.two_wheeler_rounded,
                            size: 48,
                            color: AppColors.primary,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    // Brand Name
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Moto',
                            style: TextStyle(color: AppColors.textPrimaryLight),
                          ),
                          TextSpan(
                            text: 'Log',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ],
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      'Chào mừng trở lại! 👋',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đăng nhập để tiếp tục hành trình của bạn.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 36),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email label and field
                      Text(
                        'Email',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: AppValidators.email,
                        decoration: InputDecoration(
                          hintText: 'Nhập email của bạn',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppColors.textSecondaryLight),
                          fillColor: AppColors.surface,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Password label and field
                      Text(
                        'Mật khẩu',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscurePass,
                        textInputAction: TextInputAction.done,
                        validator: AppValidators.password,
                        onFieldSubmitted: (_) => _login(),
                        decoration: InputDecoration(
                          hintText: 'Nhập mật khẩu',
                          prefixIcon: Icon(Icons.lock_outline,
                              color: AppColors.textSecondaryLight),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondaryLight,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                          fillColor: AppColors.surface,
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.borderLight),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),

                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _forgotPassword,
                          child: Text(
                            'Quên mật khẩu?',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Đăng nhập',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Social Login Divider
                      Row(
                        children: [
                          Expanded(
                              child: Divider(color: AppColors.borderLight)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'hoặc',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(color: AppColors.borderLight)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Google Social Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: isLoading ? null : _loginWithGoogle,
                          style: OutlinedButton.styleFrom(
                            side:
                                BorderSide(color: AppColors.borderLight),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: AppColors.background,
                            foregroundColor: AppColors.textPrimaryLight,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.g_mobiledata,
                                  color: Colors.red, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'Đăng nhập với Google',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản? ',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.go('/login/register'),
                      child: Text(
                        'Đăng ký',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
        ],
      ),
    );
  }
}
