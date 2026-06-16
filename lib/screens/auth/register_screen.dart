import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng đồng ý với điều khoản sử dụng')),
      );
      return;
    }

    await ref.read(authNotifierProvider.notifier).registerWithEmail(
          _nameCtrl.text,
          _emailCtrl.text,
          _passCtrl.text,
        );

    if (!mounted) return;
    final authState = ref.read(authNotifierProvider);
    if (authState.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(getAuthErrorMessage(authState.error!)),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    // Router sẽ tự redirect đến dashboard khi đăng ký thành công
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo tài khoản'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bắt đầu hành trình\ncủa bạn 🏍️',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tạo tài khoản miễn phí để lưu nhật ký xe',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 32),

              // Full Name
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (v) =>
                    AppValidators.required(v, fieldName: 'Họ tên'),
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  hintText: 'Nguyễn Văn A',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 16),

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
                textInputAction: TextInputAction.next,
                validator: AppValidators.password,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  hintText: 'Tối thiểu 6 ký tự',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePass
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPassCtrl,
                obscureText: _obscureConfirm,
                textInputAction: TextInputAction.done,
                validator: AppValidators.confirmPassword(_passCtrl.text),
                onFieldSubmitted: (_) => _register(),
                decoration: InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  hintText: 'Nhập lại mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Terms checkbox
              Row(
                children: [
                  Checkbox(
                    value: _agreeTerms,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (v) =>
                        setState(() => _agreeTerms = v ?? false),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Tôi đồng ý với ',
                        style: Theme.of(context).textTheme.bodySmall,
                        children: [
                          TextSpan(
                            text: 'Điều khoản sử dụng',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' và '),
                          TextSpan(
                            text: 'Chính sách bảo mật',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Register button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _register,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Tạo tài khoản'),
                ),
              ),
              const SizedBox(height: 24),

              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Đã có tài khoản? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Đăng nhập'),
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
