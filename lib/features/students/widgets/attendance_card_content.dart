// lib/features/students/widgets/attendance_card_content.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/models/student_attendance_history.dart';
import 'attendance_loading_state.dart';
import 'attendance_error_state.dart';
import 'attendance_quick_stats.dart';
import 'attendance_progress_overview.dart';

class AttendanceCardContent extends StatelessWidget {
  final StudentModel student;
  final StudentAttendanceHistory? attendanceHistory;
  final StudentAttendanceStats? attendanceStats;
  final bool isLoadingHistory;
  final bool isLoadingStats;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onViewAll;

  const AttendanceCardContent({
    super.key,
    required this.student,
    this.attendanceHistory,
    this.attendanceStats,
    required this.isLoadingHistory,
    required this.isLoadingStats,
    this.error,
    required this.onRetry,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading state
    if (isLoadingHistory && attendanceHistory == null) {
      return const AttendanceLoadingState();
    }

    // Show error state
    if (error != null && attendanceHistory == null) {
      return AttendanceErrorState(
        error: error!,
        onRetry: onRetry,
      );
    }

    final records = attendanceHistory?.records ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AttendanceProgressOverview(
          student: student,
          records: records,
          isLoading: isLoadingHistory,
          onViewHistory: onViewAll,
        ),

        // Quick stats (if available)
        if (attendanceStats != null) ...[
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          AttendanceQuickStats(stats: attendanceStats!),
        ],
      ],
    );
  }
}
