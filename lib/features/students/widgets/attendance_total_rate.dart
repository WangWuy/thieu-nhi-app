// lib/features/students/widgets/attendance_total_rate.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AttendanceTotalRate extends StatelessWidget {
  final int thursdayCount;
  final int sundayCount;
  final int totalWeeks;

  const AttendanceTotalRate({
    super.key,
    required this.thursdayCount,
    required this.sundayCount,
    required this.totalWeeks,
  });

  @override
  Widget build(BuildContext context) {
    final totalPossible = totalWeeks * 2;
    final totalAttended = thursdayCount + sundayCount;
    final overallPercentage =
        totalPossible > 0 ? (totalAttended / totalPossible * 100) : 0.0;
    final color = _getAttendanceColor(overallPercentage);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tỷ lệ điểm danh tổng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalAttended/$totalPossible buổi',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${overallPercentage.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 75) return AppColors.primary;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }
}
