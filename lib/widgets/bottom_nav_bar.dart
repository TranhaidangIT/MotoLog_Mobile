import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motolog_mobile/theme/app_theme.dart';

/// Component Thanh điều hướng dưới cùng (Bottom Navigation Bar)
/// Được sử dụng chung trên các màn hình: Trang chủ, Lịch sử, Cá nhân
class MotoBottomNavBar extends StatelessWidget {
  /// Chỉ số màn hình đang chọn: 0=Trang chủ, 1=Lịch sử, 2=Cá nhân
  final int currentIndex;
  /// Callback khi nhấn chuyển Tab
  final ValueChanged<int> onTap;
  final VoidCallback onAddTap;

  const MotoBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      margin: EdgeInsets.only(
        left: 20, 
        right: 20, 
        bottom: bottomPadding > 0 ? bottomPadding : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(icon: Icons.home_outlined, label: 'Trang chủ', index: 0, current: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.history, label: 'Lịch sử', index: 1, current: currentIndex, onTap: onTap),
          _NavItem(icon: Icons.person_outline, label: 'Cá nhân', index: 2, current: currentIndex, onTap: onTap),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index, current;
  final ValueChanged<int> onTap;
  const _NavItem({required this.icon, required this.label, required this.index, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    final color = active ? AppColors.primary : const Color(0xFF757575);
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.beVietnamPro(
          fontSize: 10, color: color, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
        )),
      ]),
    );
  }
}
