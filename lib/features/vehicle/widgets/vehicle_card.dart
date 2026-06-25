import 'package:flutter/material.dart';
import 'package:motolog_mobile/core/constants/app_colors.dart';
import 'package:motolog_mobile/core/constants/app_constants.dart';
import 'package:motolog_mobile/core/utils/formatters.dart';
import 'package:motolog_mobile/data/models/vehicle.dart';

/// Card hiển thị thông tin xe — dùng trên Dashboard (CoverFlow)
class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final bool isSelected;
  final VoidCallback? onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.isSelected = false,
    this.onTap,
  });

  Color get _vehicleColor {
    try {
      final hex = vehicle.color.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primary;
    }
  }

  // Text color that contrasts with the card background
  Color get _textOnCard {
    // For neon green cards use black text for readability
    final bg = _vehicleColor;
    final luminance = bg.computeLuminance();
    return luminance > 0.4 ? Colors.black87 : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textOnCard = _textOnCard;
    final subtleOnCard = textOnCard.withValues(alpha: 0.7);
    final extraSubtle = textOnCard.withValues(alpha: 0.15);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        curve: Curves.easeOutCubic,
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Selected: solid vehicle color; unselected: surface card
          color: isSelected
              ? _vehicleColor
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _vehicleColor.withValues(alpha: 0.45),
                    blurRadius: 24,
                    spreadRadius: -4,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Watermark icon bottom-right
            Positioned(
              right: 0,
              bottom: 0,
              child: Opacity(
                opacity: isSelected ? 0.15 : 0.08,
                child: Image.asset(
                  'img/logo/logo.png',
                  width: 90,
                  height: 90,
                  fit: BoxFit.contain,
                  color: isSelected ? Colors.white : _vehicleColor,
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── Brand / Name row ─────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: isSelected
                            ? textOnCard
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vehicle.brand} ${vehicle.model} · ${vehicle.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? subtleOnCard
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),

                // ── Plate + Odometer ─────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? extraSubtle
                            : _vehicleColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vehicle.plateNumber,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: isSelected ? textOnCard : _vehicleColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.speed_rounded,
                          size: 13,
                          color: isSelected
                              ? subtleOnCard
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.45),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppFormatters.km(vehicle.odometer),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? textOnCard.withValues(alpha: 0.9)
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.65),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Fuel type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? extraSubtle
                                : _vehicleColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            vehicle.fuelType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? textOnCard : _vehicleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
