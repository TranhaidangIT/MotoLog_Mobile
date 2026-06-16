import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === LIGHT MODE ===
  static const Color primary = Color(0xFFFF6B00);
  static const Color primaryDark = Color(0xFFE55A00);
  static const Color primaryLight = Color(0xFFFF8C42);
  static const Color primaryContainer = Color(0xFFFFE0CC);

  static const Color secondary = Color(0xFF2563EB);
  static const Color secondaryLight = Color(0xFF60A5FA);

  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F3F5);
  static const Color borderLight = Color(0xFFE5E7EB);

  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textHintLight = Color(0xFF9CA3AF);

  // === DARK MODE ===
  static const Color backgroundDark = Color(0xFF0F0F1A);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color surfaceVariantDark = Color(0xFF252540);
  static const Color borderDark = Color(0xFF374151);

  static const Color textPrimaryDark = Color(0xFFE2E8F0);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textHintDark = Color(0xFF6B7280);

  // === CHART COLORS ===
  static const List<Color> chartColors = [
    Color(0xFFFF6B00),
    Color(0xFF2563EB),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  // === FUEL TYPE COLORS ===
  static const Color fuelGasoline = Color(0xFFFF6B00);
  static const Color fuelElectric = Color(0xFF10B981);
  static const Color fuelDiesel = Color(0xFF6366F1);

  // === GRADIENT ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF8C42)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF252540)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
