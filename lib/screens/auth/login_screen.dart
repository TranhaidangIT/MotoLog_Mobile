import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
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
    // Router sẽ tự redirect đến dashboard khi auth state thay đổi
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
        backgroundColor: Colors.green,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark ? AppColors.darkGradient : null,
          color: isDark ? null : AppColors.backgroundLight,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.08),

                    // Header
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.two_wheeler_rounded,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'MotoLog',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'Chào mừng\ntrở lại! 👋',
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đăng nhập để tiếp tục theo dõi xe của bạn',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 40),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: AppValidators.email,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'example@gmail.com',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: _passCtrl,
                            obscureText: _obscurePass,
                            textInputAction: TextInputAction.done,
                            validator: AppValidators.password,
                            onFieldSubmitted: (_) => _login(),
                            decoration: InputDecoration(
                              labelText: 'Mật khẩu',
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_obscurePass
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () => setState(
                                    () => _obscurePass = !_obscurePass),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: const Text('Quên mật khẩu?'),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _login,
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text('Đăng nhập'),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Divider
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'hoặc',
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Google Sign-In
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: isLoading ? null : _loginWithGoogle,
                              icon: Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.grey.shade300),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(2),
                                  child: Icon(Icons.g_mobiledata,
                                      color: Colors.red, size: 18),
                                ),
                              ),
                              label: const Text('Tiếp tục với Google'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Register link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa có tài khoản? ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => context.go('/login/register'),
                          child: const Text('Đăng ký ngay'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
