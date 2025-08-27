import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class MiniClassCard extends StatelessWidget {
  final String className;
  final String department;
  final int totalStudents;
  final int presentToday;
  final VoidCallback onTap;

  const MiniClassCard({
    super.key,
    required this.className,
    required this.department,
    required this.totalStudents,
    required this.presentToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final attendanceRate =
        totalStudents > 0 ? (presentToday / totalStudents) * 100 : 0.0;

    return Material(
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getDepartmentColor(department).withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
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
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getDepartmentColor(department).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.school,
                      color: _getDepartmentColor(department),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          className,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.grey800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$totalStudents thiếu nhi',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$presentToday có mặt',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${attendanceRate.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getAttendanceRateColor(attendanceRate),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  Color _getAttendanceRateColor(double rate) {
    if (rate >= 90) return AppColors.success;
    if (rate >= 75) return AppColors.warning;
    return AppColors.error;
  }
}
