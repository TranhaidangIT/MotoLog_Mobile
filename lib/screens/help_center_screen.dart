import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

/// Màn hình Trung tâm Trợ giúup
/// Liệt kê hướng dẫn sử dụng, câu hỏi thường gặp (FAQ) và thông tin liên hệ hỗ trợ.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _guides = [
    {'title': 'Cách ghi nhận đổ xăng', 'desc': 'Hướng dẫn nhập ODO, số lít, số tiền để app tính đúng mức tiêu hao'},
    {'title': 'Cách thiết lập mốc bảo dưỡng', 'desc': 'Hướng dẫn nhập ODO lần thay gần nhất cho từng hạng mục'},
    {'title': 'Cách thêm phụ tùng kèm ảnh', 'desc': 'Hướng dẫn chụp ảnh trước/sau khi thay phụ tùng'},
    {'title': 'Cách đọc biểu đồ Chi phí', 'desc': 'Giải thích donut chart, biểu đồ xu hướng theo tuần'},
  ];

  static const _faqs = [
    {'q': 'Tại sao bảo dưỡng báo "Đã quá hạn"?', 'a': 'App tính dựa trên ODO hiện tại và lần thay gần nhất. Nếu chưa thiết lập đúng mốc ban đầu, vào "Cá nhân → Thiết lập lại mốc bảo dưỡng" để cập nhật.'},
    {'q': 'Dữ liệu có bị mất khi đổi điện thoại không?', 'a': 'Không, nếu bạn đã đăng nhập bằng Google và bật "Sao lưu & đồng bộ" trong Cài đặt ứng dụng.'},
    {'q': 'Tôi có thể dùng app cho nhiều xe không?', 'a': 'Phiên bản hiện tại hỗ trợ 1 xe. Tính năng nhiều xe đang được phát triển.'},
  ];

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
    child: Text(t, style: GoogleFonts.beVietnamPro(fontSize: 14, fontWeight: FontWeight.w700)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trung tâm trợ giúp'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _sectionTitle('Hướng dẫn sử dụng'),
          ..._guides.map((g) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
            ),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: AppColors.greenChip, borderRadius: BorderRadius.circular(9)),
                child: const Icon(Icons.menu_book_outlined, color: AppColors.primary, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(g['title']!, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600)),
                Text(g['desc']!, style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary)),
              ])),
              const Icon(Icons.chevron_right, size: 16, color: AppColors.textSecondary),
            ]),
          )),

          _sectionTitle('Câu hỏi thường gặp'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
            ),
            child: Column(children: _faqs.map((f) => ExpansionTile(
              title: Text(f['q']!, style: GoogleFonts.beVietnamPro(fontSize: 12, fontWeight: FontWeight.w600)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              expandedAlignment: Alignment.topLeft,
              children: [Text(f['a']!, style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary))],
            )).toList()),
          ),

          _sectionTitle('Liên hệ với chúng tôi'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
            ),
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.email_outlined, color: AppColors.primary),
                title: const Text('Email hỗ trợ'),
                subtitle: const Text('support@motolog.app', style: TextStyle(fontSize: 11)),
                onTap: () => launchUrl(Uri.parse('mailto:support@motolog.app')),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline, color: AppColors.primary),
                title: const Text('Chat Zalo/Messenger'),
                onTap: () {
                  // Điều hướng tới kênh Zalo OA hoặc Messenger hỗ trợ khách hàng
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.phone_outlined, color: AppColors.primary),
                title: const Text('Hotline'),
                subtitle: const Text('1900 xxxx', style: TextStyle(fontSize: 11)),
                onTap: () => launchUrl(Uri.parse('tel:1900xxxx')),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.star_outline, color: AppColors.primary),
                title: const Text('Đánh giá ứng dụng'),
                subtitle: const Text('Để lại 5 sao trên CH Play / App Store', style: TextStyle(fontSize: 11)),
                onTap: () {
                  // Mở App Store hoặc Google Play để đánh giá ứng dụng
                },
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
