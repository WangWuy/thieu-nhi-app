import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ManualAttendanceSummary extends StatelessWidget {
  final TodayAttendanceStatus? todayStatus;
  final List<String> filteredStudentCodes;
  final String? selectedClass;

  const ManualAttendanceSummary({
    super.key,
    required this.todayStatus,
    required this.filteredStudentCodes,
    this.selectedClass,
  });

  @override
  Widget build(BuildContext context) {
    final summary = _calculateFilteredSummary();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          if (selectedClass != null) ...[
            Text(
              'Thống kê lớp: $selectedClass',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Có mặt',
                summary.attended.toString(),
                AppColors.success,
              ),
              _buildSummaryItem(
                'Chưa điểm danh',
                summary.notMarked.toString(),
                AppColors.grey600,
              ),
              _buildSummaryItem(
                'Tổng cộng',
                summary.total.toString(),
                AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  FilteredAttendanceSummary _calculateFilteredSummary() {
    if (todayStatus == null || filteredStudentCodes.isEmpty) {
      return FilteredAttendanceSummary(
        total: filteredStudentCodes.length,
        attended: 0,
        notMarked: filteredStudentCodes.length,
      );
    }

    int attended = 0;
    int notMarked = 0;

    for (final code in filteredStudentCodes) {
      final status = todayStatus!.getStudentStatus(code);
      if (status != null && status.isPresent) {
        attended++;
      } else {
        notMarked++;
      }
    }

    return FilteredAttendanceSummary(
      total: filteredStudentCodes.length,
      attended: attended,
      notMarked: notMarked,
    );
  }

  Widget _buildSummaryItem(String label, String count, Color color) {
    return Column(
      children: [
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

class FilteredAttendanceSummary {
  final int total;
  final int attended;
  final int notMarked;

  FilteredAttendanceSummary({
    required this.total,
    required this.attended,
    required this.notMarked,
  });
}
