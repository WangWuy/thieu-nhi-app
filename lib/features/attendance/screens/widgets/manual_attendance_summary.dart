// lib/features/attendance/screens/widgets/manual_attendance_summary.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ManualAttendanceSummary extends StatelessWidget {
  final TodayAttendanceStatus todayStatus;

  const ManualAttendanceSummary({
    super.key,
    required this.todayStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Có mặt',
            todayStatus.summary.attended.toString(),
            AppColors.success,
            Icons.check_circle,
          ),
          _buildSummaryItem(
            'Vắng mặt',
            todayStatus.summary.absent.toString(),
            AppColors.error,
            Icons.cancel,
          ),
          _buildSummaryItem(
            'Chưa điểm danh',
            todayStatus.summary.notMarked.toString(),
            AppColors.grey600,
            Icons.help_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }
}