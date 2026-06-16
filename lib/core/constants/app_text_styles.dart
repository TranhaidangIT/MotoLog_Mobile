import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _base => GoogleFonts.beVietnamPro();

  // === DISPLAY ===
  static TextStyle displayLarge(BuildContext context) => _base.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: _primaryText(context),
        height: 1.2,
      );

  static TextStyle displayMedium(BuildContext context) => _base.copyWith(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: _primaryText(context),
        height: 1.2,
      );

  // === HEADLINE ===
  static TextStyle headlineLarge(BuildContext context) => _base.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: _primaryText(context),
        height: 1.3,
      );

  static TextStyle headlineMedium(BuildContext context) => _base.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _primaryText(context),
        height: 1.3,
      );

  static TextStyle headlineSmall(BuildContext context) => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _primaryText(context),
        height: 1.3,
      );

  // === TITLE ===
  static TextStyle titleLarge(BuildContext context) => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _primaryText(context),
        height: 1.4,
      );

  static TextStyle titleMedium(BuildContext context) => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _primaryText(context),
        height: 1.4,
      );

  // === BODY ===
  static TextStyle bodyLarge(BuildContext context) => _base.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: _primaryText(context),
        height: 1.5,
      );

  static TextStyle bodyMedium(BuildContext context) => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: _primaryText(context),
        height: 1.5,
      );

  static TextStyle bodySmall(BuildContext context) => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _secondaryText(context),
        height: 1.5,
      );

  // === LABEL ===
  static TextStyle labelLarge(BuildContext context) => _base.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _primaryText(context),
      );

  static TextStyle labelMedium(BuildContext context) => _base.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _secondaryText(context),
        letterSpacing: 0.4,
      );

  static TextStyle labelSmall(BuildContext context) => _base.copyWith(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: _secondaryText(context),
        letterSpacing: 0.5,
      );

  // === SPECIAL ===
  static TextStyle amount(BuildContext context) => _base.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: -0.5,
      );

  static TextStyle currency(BuildContext context) => _base.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: _primaryText(context),
        letterSpacing: -0.3,
      );

  // === HELPERS ===
  static Color _primaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
  }

  static Color _secondaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
  }
}
