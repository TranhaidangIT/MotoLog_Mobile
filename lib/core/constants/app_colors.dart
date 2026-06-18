import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === LIGHT MODE ===
  static const Color primary = Color(0xFF4FAF68); // Primary Green
  static const Color primaryDark = Color(0xFF3B8E53);
  static const Color primaryLight = Color(0xFFDFF3E3); // Light Green
  static const Color primaryContainer = Color(0xFFDFF3E3);

  static const Color secondary = Color(0xFFF59E0B); // Warning/Orange
  static const Color secondaryLight = Color(0xFFFEF3C7);

  static const Color success = Color(0xFF4FAF68);
  static const Color successLight = Color(0xFFDFF3E3);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);

  static const Color backgroundLight =
      Color(0xFFF8F6F0); // Warm White Background
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1EFEA); // Warm Gray
  static const Color borderLight = Color(0xFFE5E5E5); // Muted Border

  static const Color textPrimaryLight = Color(0xFF222222); // Dark text
  static const Color textSecondaryLight = Color(0xFF6B7280); // Gray text
  static const Color textHintLight = Color(0xFF9CA3AF); // Hint text

  // === DARK MODE ===
  static const Color backgroundDark = Color(0xFF1F2937);
  static const Color surfaceDark = Color(0xFF374151);
  static const Color surfaceVariantDark = Color(0xFF4B5563);
  static const Color borderDark = Color(0xFF4B5563);

  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textHintDark = Color(0xFF9CA3AF);

  // === ACCENT COLORS (backward compat) ===
  static const Color accentYellow = Color(0xFFFFD166);
  static const Color accentPurple = Color(0xFFA78BFA);
  static const Color accentMint = Color(0xFF06D6A0);
  static const Color accentCoral = Color(0xFFFF6B6B);
  static const Color accentSky = Color(0xFF38BDF8);
  static const Color accentPeach = Color(0xFFFFB347);
  static const Color accentGreen = Color(0xFF4FAF68);
  static const Color onAccentYellow = Color(0xFF7A5C00);
  static const Color onAccentPurple = Color(0xFF3B0764);
  static const Color onAccentMint = Color(0xFF014D3A);
  static const Color onAccentCoral = Color(0xFF7A1212);
  static const Color onAccentGreen = Color(0xFFFFFFFF);

  // === PASTEL ACCENTS FOR WIDGETS ===
  static const Color fuelBg = Color(0xFFDFF3E3);
  static const Color fuelText = Color(0xFF4FAF68);

  static const Color maintBg = Color(0xFFFEF3C7);
  static const Color maintText = Color(0xFFB45309);

  static const Color alertBg = Color(0xFFFEE2E2);
  static const Color alertText = Color(0xFFEF4444);

  // === CHART COLORS ===
  static const List<Color> chartColors = [
    Color(0xFF16A34A),
    Color(0xFFF97316),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
  ];

  // === FUEL TYPE COLORS ===
  static const Color fuelGasoline = Color(0xFF16A34A);
  static const Color fuelElectric = Color(0xFF10B981);
  static const Color fuelDiesel = Color(0xFF3B82F6);

  // === GRADIENT ===
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
