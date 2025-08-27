import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class DepartmentStats extends StatelessWidget {
  final String departmentName;
  final int totalStudents;
  final int presentToday;
  final int totalClasses;
  final double averageAttendance;

  const DepartmentStats({
    super.key,
    required this.departmentName,
    required this.totalStudents,
    required this.presentToday,
    required this.totalClasses,
    required this.averageAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getDepartmentColor(departmentName),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Ngành $departmentName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'thiếu nhi',
                  value: totalStudents.toString(),
                  icon: Icons.people,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  label: 'Có mặt',
                  value: presentToday.toString(),
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Lớp học',
                  value: totalClasses.toString(),
                  icon: Icons.school,
                  color: AppColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  label: 'Tỷ lệ',
                  value: '${averageAttendance.toStringAsFixed(1)}%',
                  icon: Icons.trending_up,
                  color: _getAttendanceColor(averageAttendance),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    switch (department) {
      case 'Chiên':
        return AppColors.chienColor;
      case 'Âu':
        return AppColors.auColor;
      case 'Thiếu':
        return AppColors.thieuColor;
      case 'Nghĩa':
        return AppColors.nghiaColor;
      default:
        return AppColors.primary;
    }
  }

  Color _getAttendanceColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 75) return AppColors.warning;
    return AppColors.error;
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
