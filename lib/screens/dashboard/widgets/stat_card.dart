import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Card thống kê nhỏ trên Dashboard
class StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? value;
  final AsyncValue<double>? valueAsync;
  final String Function(double)? formatter;

  const StatCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    this.value,
    this.valueAsync,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
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
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (valueAsync != null)
                valueAsync!.when(
                  data: (v) => Text(
                    formatter != null ? formatter!(v) : v.toStringAsFixed(0),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  loading: () => const SizedBox(
                    height: 16,
                    width: 60,
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, __) => const Text('—'),
                )
              else
                Text(
                  value ?? '—',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
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
