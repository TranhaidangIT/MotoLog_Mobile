import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:motolog_mobile/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:motolog_mobile/features/auth/providers/auth_provider.dart';

/// Màn hình Đăng ký tài khoản
/// Cho phép người dùng mới tạo tài khoản bằng Họ Tên, Email và Mật khẩu.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true, _obscure2 = true;

  InputDecoration _decoration(String hint, {Widget? suffix}) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary),
    filled: true,
    fillColor: const Color(0xFFF5F5F5),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    suffixIcon: suffix,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.background, elevation: 0, leading: const BackButton(color: Colors.black)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            const SizedBox(height: 8),
            Text('Tạo tài khoản', style: GoogleFonts.beVietnamPro(fontSize: 24, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Đăng ký để bắt đầu quản lý xe của bạn',
              style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary)),

            const SizedBox(height: 28),
            Text('Họ và tên', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(controller: _nameCtrl, decoration: _decoration('Nhập họ và tên')),

            const SizedBox(height: 16),
            Text('Email hoặc số điện thoại', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(controller: _contactCtrl, decoration: _decoration('Nhập email hoặc SĐT')),

            const SizedBox(height: 16),
            Text('Mật khẩu', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _passCtrl,
              obscureText: _obscure1,
              decoration: _decoration('Nhập mật khẩu', suffix: IconButton(
                icon: Icon(_obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                onPressed: () => setState(() => _obscure1 = !_obscure1),
              )),
            ),

            const SizedBox(height: 16),
            Text('Xác nhận mật khẩu', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _confirmCtrl,
              obscureText: _obscure2,
              decoration: _decoration('Nhập lại mật khẩu', suffix: IconButton(
                icon: Icon(_obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 18),
                onPressed: () => setState(() => _obscure2 = !_obscure2),
              )),
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: ref.watch(authNotifierProvider).isLoading ? null : () async {
                  final name = _nameCtrl.text.trim();
                  final email = _contactCtrl.text.trim();
                  final pass = _passCtrl.text;
                  final confirm = _confirmCtrl.text;

                  if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')));
                    return;
                  }
                  if (pass != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mật khẩu xác nhận không khớp')));
                    return;
                  }

                  await ref.read(authNotifierProvider.notifier).registerWithEmail(name, email, pass);
                  final authState = ref.read(authNotifierProvider);
                  if (authState.hasError) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getAuthErrorMessage(authState.error!))));
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đăng ký thành công!')));
                      context.pop();
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: ref.watch(authNotifierProvider).isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Đăng ký', style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: GestureDetector(
                onTap: () => context.pop(),
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary),
                    children: [
                      const TextSpan(text: 'Đã có tài khoản? '),
                      TextSpan(text: 'Đăng nhập', style: GoogleFonts.beVietnamPro(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
