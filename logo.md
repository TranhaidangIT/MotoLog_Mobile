# Flutter Splash Screen - Exploded View Reverse Animation (Hiệu ứng Lắp Ghép Logo)

Tài liệu này chứa **Prompt chuẩn** để gửi cho các AI (như Gemini, ChatGPT, Claude) hiểu cách sinh code hiệu ứng lắp ráp xe, kèm theo **Code mẫu hoàn chỉnh** sử dụng thư viện `flutter_animate`.

---

## 1. Prompt Tiếng Anh chuẩn dành cho AI
*Bạn chỉ cần copy toàn bộ đoạn Prompt dưới đây và gửi cho AI để nó tự động viết code chính xác theo ý bạn:*

> **Prompt:**
> I have a motorcycle logo image that I want to use for a Flutter App Splash Screen. The logo needs to be split into 3 separate transparent PNG layers: `khung_xe.png` (the upper black frame), `than_xe.png` (the middle green body), and `hai_banh_xe.png` (the bottom wheels).
> 
> Please write a complete Flutter widget for this Splash Screen using the `flutter_animate` package to create an **"Exploded View Reverse" (Assembly Animation)** effect. 
> 
> **The automation flow must be as follows:**
> 1. The screen background is white.
> 2. `khung_xe.png` automatically slides DOWN from the top with an ease-out curve.
> 3. `than_xe.png` automatically slides IN from the left with a slight delay.
> 4. `hai_banh_xe.png` automatically slides UP from the bottom with a slight rotation (simulating wheels rolling into place).
> 5. After all parts assemble perfectly into a complete motorcycle logo, wait for 500ms, then trigger a quick bounce/scale effect on the entire logo.
> 6. Finally, scale the entire assembled logo down to 0 (shrink/fade out) and automatically navigate to `HomeScreen()`.
> 
> Keep the code clean, modular, and use `StatefulWidget` to handle the automatic navigation.

---

## 2. Cấu trúc thư mục Assets cần chuẩn bị
Để hiệu ứng chạy đúng, bạn cần cắt tấm ảnh logo ban đầu ra làm 3 phần riêng biệt (dạng `.png` suốt) và khai báo trong `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/khung_xe.png
    - assets/than_xe.png
    - assets/hai_banh_xe.png
3. Mã nguồn Flutter mẫu (Gợi ý tối ưu)
Thêm package vào pubspec.yaml:

YAML
dependencies:
  flutter_animate: ^4.5.0
File code motorcycle_splash_screen.dart:

Dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MotorcycleSplashScreen extends StatefulWidget {
  const MotorcycleSplashScreen({super.key});

  @override
  State<MotorcycleSplashScreen> createState() => _MotorcycleSplashScreenState();
}

class _MotorcycleSplashScreenState extends State<MotorcycleSplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng sạch sẽ giống Pinterest
      body: Center(
        child: SizedBox(
          width: 300,  // Kích thước vùng chứa chiếc xe
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              
              // 1. KHUNG XE (Màu đen phía trên) - Bay từ TRÊN xuống
              Image.asset('assets/khung_xe.png')
                  .animate()
                  .fade(duration: 500.ms)
                  .slideY(
                    begin: -1.2, 
                    end: 0, 
                    duration: 700.ms, 
                    curve: Curves.easeOutCubic
                  ),

              // 2. THÂN XE (Màu xanh ở giữa) - Bay từ TRÁI sang
              Image.asset('assets/than_xe.png')
                  .animate()
                  .fade(delay: 200.ms, duration: 400.ms)
                  .slideX(
                    begin: -1.2, 
                    end: 0, 
                    delay: 200.ms, 
                    duration: 700.ms, 
                    curve: Curves.easeOutCubic
                  ),

              // 3. BÁNH XE (Phía dưới) - Bay từ DƯỚI lên + Xoay nhẹ góc tròn
              Image.asset('assets/hai_banh_xe.png')
                  .animate()
                  .fade(delay: 400.ms, duration: 300.ms)
                  .slideY(
                    begin: 1.2, 
                    end: 0, 
                    delay: 400.ms, 
                    duration: 700.ms, 
                    curve: Curves.easeOutBack // Tạo độ nảy khi tiếp đất
                  )
                  .rotate(
                    begin: -0.3, 
                    end: 0, 
                    delay: 400.ms, 
                    duration: 700.ms
                  ),
                  
            ],
          )
          // -----------------------------------------------------------
          // CHUỖI TỰ ĐỘNG CUỐI CÙNG (Gom cả cụm xe lại sau khi lắp ráp xong)
          // Tổng thời gian ráp là ~1100ms, đặt delay 1300ms là vừa đẹp
          // -----------------------------------------------------------
          .animate(delay: 1300.ms)
          // Lắc nhẹ xe để báo hiệu đã lắp ráp xong thành công
          .scaleXY(begin: 1.0, end: 1.08, duration: 150.ms, curve: Curves.easeOut)
          .then()
          .scaleXY(begin: 1.08, end: 1.0, duration: 150.ms, curve: Curves.easeIn)
          
          // Chờ một chút rồi biến mất (Phóng to hẳn hoặc thu nhỏ biến mất)
          .then(delay: 300.ms)
          .scaleXY(begin: 1.0, end: 0.0, duration: 400.ms, curve: Curves.valueInGrid)
          .fade(end: 0.0, duration: 400.ms)
          
          // Kích hoạt hàm chuyển màn hình tự động khi hiệu ứng kết thúc hoàn toàn
          .callback(callback: (_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }),
        ),
      ),
    );
  }
}

// Màn hình đích sau khi kết thúc hiệu ứng lắp ráp
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Welcome to Main Screen!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}