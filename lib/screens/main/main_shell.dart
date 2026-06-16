import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';

class MainShell extends StatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      label: 'Tổng quan',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      route: AppRoutes.dashboard,
    ),
    _NavItem(
      label: 'Xăng',
      icon: Icons.local_gas_station_outlined,
      activeIcon: Icons.local_gas_station_rounded,
      route: AppRoutes.fuelList,
    ),
    _NavItem(
      label: 'Bảo dưỡng',
      icon: Icons.build_outlined,
      activeIcon: Icons.build_rounded,
      route: AppRoutes.maintenanceList,
    ),
    _NavItem(
      label: 'Thống kê',
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      route: AppRoutes.statistics,
    ),
    _NavItem(
      label: 'Tài khoản',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      route: AppRoutes.profile,
    ),
  ];

  void _onTap(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
    context.go(_navItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navItems.length,
                (i) => _NavBarItem(
                  item: _navItems[i],
                  isActive: _currentIndex == i,
                  onTap: () => _onTap(i),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive ? AppColors.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.5);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
