import 'package:flutter/material.dart';

/// Tile hiển thị hoạt động gần đây
class RecentActivityTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String date;

  const RecentActivityTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          date,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ),
    );
  }
}
