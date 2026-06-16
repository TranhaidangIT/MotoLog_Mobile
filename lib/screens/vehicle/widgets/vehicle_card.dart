import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/vehicle.dart';

/// Card hiển thị thông tin xe — dùng trên Dashboard
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animNormal,
        width: 280,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    _vehicleColor,
                    _vehicleColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
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
                    color: _vehicleColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Background icon
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                Icons.two_wheeler_rounded,
                size: 80,
                color: isSelected
                    ? Colors.white.withOpacity(0.15)
                    : _vehicleColor.withOpacity(0.08),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand / Model
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vehicle.brand} ${vehicle.model} · ${vehicle.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? Colors.white.withOpacity(0.8)
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                      ),
                    ),
                  ],
                ),

                // Plate + Odometer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.2)
                            : _vehicleColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vehicle.plateNumber,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: isSelected ? Colors.white : _vehicleColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.speed_rounded,
                          size: 14,
                          color: isSelected
                              ? Colors.white.withOpacity(0.8)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.5),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppFormatters.km(vehicle.odometer),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white.withOpacity(0.9)
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.7),
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
