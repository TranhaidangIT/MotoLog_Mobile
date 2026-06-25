import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // === LIGHT MODE ===
  static Color primary = const Color(0xFF4FAF68); // Primary Green
  static Color primaryDark = const Color(0xFF3B8E53);
  static Color primaryLight = const Color(0xFFDFF3E3); // Light Green
  static Color primaryContainer = const Color(0xFFDFF3E3);

  static Color secondary = const Color(0xFFF59E0B); // Warning/Orange
  static Color secondaryLight = const Color(0xFFFEF3C7);

  static Color success = const Color(0xFF4FAF68);
  static Color successLight = const Color(0xFFDFF3E3);
  static Color warning = const Color(0xFFF59E0B);
  static Color warningLight = const Color(0xFFFEF3C7);
  static Color error = const Color(0xFFEF4444);
  static Color errorLight = const Color(0xFFFEE2E2);

  static Color backgroundLight =
      const Color(0xFFF8F6F0); // Warm White Background
  static Color surfaceLight = const Color(0xFFFFFFFF);
  static Color surfaceVariantLight = const Color(0xFFF1EFEA); // Warm Gray
  static Color borderLight = const Color(0xFFE5E5E5); // Muted Border

  static Color textPrimaryLight = const Color(0xFF222222); // Dark text
  static Color textSecondaryLight = const Color(0xFF6B7280); // Gray text
  static Color textHintLight = const Color(0xFF9CA3AF); // Hint text

  // === DARK MODE ===
  static Color backgroundDark = const Color(0xFF1F2937);
  static Color surfaceDark = const Color(0xFF374151);
  static Color surfaceVariantDark = const Color(0xFF4B5563);
  static Color borderDark = const Color(0xFF4B5563);

  static Color textPrimaryDark = const Color(0xFFF9FAFB);
  static Color textSecondaryDark = const Color(0xFFD1D5DB);
  static Color textHintDark = const Color(0xFF9CA3AF);

  // === ACCENT COLORS (backward compat) ===
  static Color accentYellow = const Color(0xFFFFD166);
  static Color accentPurple = const Color(0xFFA78BFA);
  static Color accentMint = const Color(0xFF06D6A0);
  static Color accentCoral = const Color(0xFFFF6B6B);
  static Color accentSky = const Color(0xFF38BDF8);
  static Color accentPeach = const Color(0xFFFFB347);
  static Color accentGreen = const Color(0xFF4FAF68);
  static Color onAccentYellow = const Color(0xFF7A5C00);
  static Color onAccentPurple = const Color(0xFF3B0764);
  static Color onAccentMint = const Color(0xFF014D3A);
  static Color onAccentCoral = const Color(0xFF7A1212);
  static Color onAccentGreen = const Color(0xFFFFFFFF);

  // === PASTEL ACCENTS FOR WIDGETS ===
  static Color fuelBg = const Color(0xFFDFF3E3);
  static Color fuelText = const Color(0xFF4FAF68);

  static Color maintBg = const Color(0xFFFEF3C7);
  static Color maintText = const Color(0xFFB45309);

  static Color alertBg = const Color(0xFFFEE2E2);
  static Color alertText = const Color(0xFFEF4444);

  // === CHART COLORS ===
  static List<Color> chartColors = [
    const Color(0xFF16A34A),
    const Color(0xFFF97316),
    const Color(0xFF3B82F6),
    const Color(0xFFF59E0B),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
  ];

  // === FUEL TYPE COLORS ===
  static Color fuelGasoline = const Color(0xFF16A34A);
  static Color fuelElectric = const Color(0xFF10B981);
  static Color fuelDiesel = const Color(0xFF3B82F6);

  // === GRADIENT ===
  static LinearGradient primaryGradient = const LinearGradient(
    colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient darkGradient = const LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient cardGradient = const LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
