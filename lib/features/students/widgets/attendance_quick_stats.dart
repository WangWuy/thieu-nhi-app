// lib/features/students/widgets/attendance_quick_stats.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_attendance_history.dart';
import 'package:thieu_nhi_app/features/students/widgets/attendance_stat_item.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AttendanceQuickStats extends StatelessWidget {
  final StudentAttendanceStats stats;

  const AttendanceQuickStats({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AttendanceStatItem(
            label: 'Tổng buổi',
            value: '${stats.typeStats.totalPresent}',
            icon: Icons.event_available,
            color: AppColors.primary,
          ),
        ),
        Expanded(
          child: AttendanceStatItem(
            label: 'Thứ 5',
            value: '${stats.typeStats.thursday.present}',
            icon: Icons.event,
            color: AppColors.secondary,
          ),
        ),
        Expanded(
          child: AttendanceStatItem(
            label: 'Chủ nhật',
            value: '${stats.typeStats.sunday.present}',
            icon: Icons.church,
            color: AppColors.primary,
          ),
        ),
        Expanded(
          child: AttendanceStatItem(
            label: 'Tỷ lệ',
            value: '${stats.typeStats.overallPercentage.toStringAsFixed(0)}%',
            icon: Icons.analytics,
            color: _getAttendanceColor(stats.typeStats.overallPercentage),
          ),
        ),
      ],
    );
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 75) return AppColors.primary;
    if (percentage >= 60) return AppColors.warning;
    return AppColors.error;
  }
}