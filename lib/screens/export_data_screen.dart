import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../data/services/data_export_service.dart';

class ExportDataScreen extends ConsumerStatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ConsumerState<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends ConsumerState<ExportDataScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    if (user != null && user.email != null) {
      _emailCtrl.text = user.email!;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _exportAndSend() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập một email hợp lệ!'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Tạo file CSV
    final file = await DataExportService.generateCsvExport(uid);
    setState(() => _isLoading = false);

    if (file == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có dữ liệu để xuất!'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    // Chuẩn bị gửi email
    final Email emailConfig = Email(
      body: 'Xin chào,\n\nĐây là file sao lưu toàn bộ dữ liệu (Xe, Nhật ký xăng, Bảo dưỡng, Phụ tùng) từ ứng dụng MotoLog.\nFile đính kèm có định dạng CSV, bạn có thể mở bằng Microsoft Excel hoặc Google Sheets.\n\nCảm ơn bạn đã sử dụng MotoLog!',
      subject: 'MotoLog - Dữ liệu xuất (Export)',
      recipients: [email],
      attachmentPaths: [file.path],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(emailConfig);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Đã mở ứng dụng Mail để gửi file!'), backgroundColor: AppColors.primary),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Lỗi: Không tìm thấy ứng dụng Mail nào trên máy. Vui lòng cài đặt và đăng nhập ứng dụng Mail trước.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gửi dữ liệu qua Email'),
        centerTitle: true,
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hệ thống sẽ tổng hợp mọi dữ liệu lịch sử vào một file Excel (.CSV) và đính kèm vào Email giúp bạn.',
                      style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.primary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Email người nhận', style: GoogleFonts.beVietnamPro(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Nhập địa chỉ email...',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _exportAndSend,
                icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.send_outlined),
                label: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('Tạo dữ liệu & Gửi', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
