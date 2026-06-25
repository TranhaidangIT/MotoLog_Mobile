import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'dart:ui';

/// Định nghĩa toàn bộ hằng số Màu sắc (Mã Hex) dùng trong ứng dụng
class AppColors {
  static bool get isDark => PlatformDispatcher.instance.platformBrightness == Brightness.dark;

  static Color get primary    => isDark ? const Color(0xFF388E3C) : const Color(0xFF2E7D32);
  static Color get primaryLight => isDark ? const Color(0xFF4CAF50) : const Color(0xFF4CAF50);
  static Color get accent     => isDark ? const Color(0xFF66BB6A) : const Color(0xFF66BB6A);
  static Color get background => isDark ? const Color(0xFF121212) : const Color(0xFFFFFFFF);
  static Color get backgroundLight => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF9FAFB);
  static Color get surface    => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF2F4F7);
  static Color get textPrimary   => isDark ? const Color(0xFFE0E0E0) : const Color(0xFF1A1A1A);
  static Color get textPrimaryLight => isDark ? const Color(0xFFFFFFFF) : const Color(0xFF111827);
  static Color get textSecondary => isDark ? const Color(0xFFAAAAAA) : const Color(0xFF757575);
  static Color get textSecondaryLight => isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563);
  static Color get fuelOrange => const Color(0xFFFF6F00);
  static Color get maintenanceRed => const Color(0xFFE53935);
  static Color get cardBg    => isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF2F4F7);
  static Color get divider   => isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB);
  static Color get borderLight => isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB);
  static Color get greenChip => isDark ? const Color(0xFF1B5E20) : const Color(0xFFE8F5E9);
  static Color get warningOrange => const Color(0xFFE65100);
  static Color get warningOrangeBg => isDark ? const Color(0xFF4E342E) : const Color(0xFFFFF3E0);
  static Color get dangerRed => const Color(0xFFC62828);
  static Color get dangerRedBg => isDark ? const Color(0xFF4A148C) : const Color(0xFFFFEBEE);
  static Color get maintText => isDark ? const Color(0xFFEF5350) : const Color(0xFFE53935);
  static Color get textHintLight => isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
}

/// Định nghĩa Cấu hình Giao diện chung (ThemeData) của ứng dụng (Font, Nút, Input...)
class AppTheme {
  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.beVietnamProTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      titleTextStyle: GoogleFonts.beVietnamPro(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.beVietnamPro(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  );
}
