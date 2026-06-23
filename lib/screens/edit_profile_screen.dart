import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController(text: 'Dang Tran');
  final _phoneCtrl = TextEditingController();
  static const _email = 'haidangdev123@gmail.com'; // lấy từ FirebaseAuth.currentUser.email

  InputDecoration _decoration() => InputDecoration(
    filled: true,
    fillColor: const Color(0xFFFAFAFA),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.divider)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chỉnh sửa thông tin'), leading: const BackButton()),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(children: [
              CircleAvatar(radius: 44, backgroundColor: const Color(0xFFFF5722),
                child: Text('D', style: GoogleFonts.beVietnamPro(fontSize: 32, color: Colors.white))),
              Positioned(
                right: 0, bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    // Hiển thị picker để thay đổi ảnh đại diện
                  },
                  child: Container(
                    width: 30, height: 30,
                    decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2))),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 15),
                  ),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 28),

          Text('Tên hiển thị', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(controller: _nameCtrl, decoration: _decoration()),

          const SizedBox(height: 16),
          Text('Email', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Expanded(child: Text(_email, style: GoogleFonts.beVietnamPro(fontSize: 13, color: AppColors.textSecondary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.g_mobiledata, size: 16, color: Colors.redAccent),
                  Text('Google', style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary)),
                ]),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Email được xác thực qua Google, không thể thay đổi trong app',
              style: GoogleFonts.beVietnamPro(fontSize: 10, color: AppColors.textSecondary)),
          ),

          const SizedBox(height: 16),
          Text('Số điện thoại (không bắt buộc)', style: GoogleFonts.beVietnamPro(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: _decoration()),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Lưu lại thông tin cá nhân (name, phone) vào Firestore profile
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Lưu thay đổi', style: GoogleFonts.beVietnamPro(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
