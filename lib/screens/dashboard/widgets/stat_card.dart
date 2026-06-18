import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';

/// Card thống kê nhỏ trên Dashboard
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final AsyncValue<double>? valueAsync;
  final String Function(double)? formatter;
  final Color? backgroundColor;
  final Color? textColor;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.valueAsync,
    this.formatter,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Determine card background and content colors
    final Color cardBg = backgroundColor != null
        ? (isDark ? backgroundColor!.withValues(alpha: 0.12) : backgroundColor!)
        : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight);

    final Color contentColor = backgroundColor != null
        ? (isDark
            ? backgroundColor!
            : (textColor ?? AppColors.textPrimaryLight))
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    final Color labelColor = backgroundColor != null
        ? (isDark
            ? backgroundColor!.withValues(alpha: 0.7)
            : (textColor?.withValues(alpha: 0.8) ??
                AppColors.textSecondaryLight))
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight);

    final Color iconBg = backgroundColor != null
        ? (isDark
            ? backgroundColor!.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.35))
        : (iconColor.withValues(alpha: 0.12));

    final Color finalIconColor = backgroundColor != null
        ? (isDark ? backgroundColor! : (textColor ?? iconColor))
        : iconColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20), // 2D style bo góc lớn hơn
        border: Border.all(
          color: backgroundColor != null
              ? (isDark
                  ? backgroundColor!.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.04))
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle, // Dạng tròn cho icon gọn gàng
            ),
            child: Icon(icon, color: finalIconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (valueAsync != null)
                valueAsync!.when(
                  data: (v) => Text(
                    formatter != null ? formatter!(v) : v.toStringAsFixed(0),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800, // Tiêu đề bold đậm
                      fontSize: 15,
                      color: contentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  loading: () => const SizedBox(
                    height: 16,
                    width: 60,
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, __) =>
                      Text('—', style: TextStyle(color: contentColor)),
                )
              else
                Text(
                  value ?? '—',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: contentColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
