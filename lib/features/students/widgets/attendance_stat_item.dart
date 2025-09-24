// lib/features/students/widgets/attendance_stat_item.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AttendanceStatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const AttendanceStatItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}