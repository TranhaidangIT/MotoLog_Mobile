import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class AddVehicleMethodScreen extends StatelessWidget {
  const AddVehicleMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng theo thiết kế
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Thêm xe mới',
          style: GoogleFonts.beVietnamPro(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Bạn muốn thêm xe theo cách nào?',
            style: GoogleFonts.beVietnamPro(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          
          // Card 1: Thiết lập nhanh
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/quick-setup-vehicle'),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF7F8FA),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 16, right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD), // Màu xanh dương nhạt
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Nhanh hơn',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE), // Màu nền icon
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.two_wheeler_rounded, size: 40, color: Color(0xFF1976D2)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Thiết lập nhanh',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Chọn từ danh sách xe phổ biến,\nthông tin sẽ được điền sẵn cho bạn',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Positioned(
                      right: 16, bottom: 20,
                      child: Icon(Icons.chevron_right_rounded, color: Colors.black26),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Divider mỏng
          Container(height: 1, color: Colors.black.withValues(alpha: 0.05)),
          
          // Card 2: Tự thiết lập
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/add-vehicle-manual'),
              child: Container(
                width: double.infinity,
                color: const Color(0xFFFAFAFA),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9), // Nền icon xanh lá
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_outlined, size: 36, color: Color(0xFF388E3C)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tự thiết lập',
                          style: GoogleFonts.beVietnamPro(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Nhập đầy đủ thông tin xe theo cách\ncủa bạn',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.beVietnamPro(
                              fontSize: 13,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Positioned(
                      right: 16, bottom: 20,
                      child: Icon(Icons.chevron_right_rounded, color: Colors.black26),
                    ),
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
