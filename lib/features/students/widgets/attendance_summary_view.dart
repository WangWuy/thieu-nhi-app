// lib/features/students/widgets/attendance_summary_view.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/features/students/widgets/attendance_total_rate.dart';
import 'package:thieu_nhi_app/features/students/widgets/attendance_type_summary.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AttendanceSummaryView extends StatelessWidget {
  final StudentModel student;

  const AttendanceSummaryView({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    final thursdayCount = student.thursdayAttendanceCount ?? 0;
    final sundayCount = student.sundayAttendanceCount ?? 0;
    final totalWeeks = student.academicYearTotalWeeks ?? 40;

    return Column(
      children: [
        // Info notice
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Chỉ hiển thị tổng kết điểm danh. Chi tiết từng buổi đang tải...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),

        // Thursday summary
        AttendanceTypeSummary(
          title: 'Điểm danh Thứ 5',
          attendedCount: thursdayCount,
          totalWeeks: totalWeeks,
          color: AppColors.secondary,
          icon: Icons.event,
        ),

        const SizedBox(height: 16),

        // Sunday summary
        AttendanceTypeSummary(
          title: 'Điểm danh Chủ nhật',
          attendedCount: sundayCount,
          totalWeeks: totalWeeks,
          color: AppColors.primary,
          icon: Icons.church,
        ),

        const SizedBox(height: 16),

        // Total rate
        AttendanceTotalRate(
          thursdayCount: thursdayCount,
          sundayCount: sundayCount,
          totalWeeks: totalWeeks,
        ),
      ],
    );
  }
}