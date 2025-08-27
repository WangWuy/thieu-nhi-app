// lib/features/students/widgets/attendance_card_content.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/models/student_attendance_history.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';
import 'attendance_loading_state.dart';
import 'attendance_error_state.dart';
import 'attendance_records_list.dart';
import 'attendance_summary_view.dart';
import 'attendance_quick_stats.dart';

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

    // Show content based on available data
    return Column(
      children: [
        // Main content
        if (_hasRecentAttendance()) ...[
          AttendanceRecordsList(
            records: attendanceHistory!.records.take(10).toList(),
          ),
          if (attendanceHistory!.pagination.total > 10) ...[
            const SizedBox(height: 12),
            _buildViewAllButton(),
          ],
        ] else ...[
          AttendanceSummaryView(student: student),
        ],

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

  Widget _buildViewAllButton() {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onViewAll,
        icon: const Icon(Icons.visibility, size: 18),
        label: Text('Xem tất cả (${attendanceHistory!.pagination.total})'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
    );
  }

  bool _hasRecentAttendance() {
    return attendanceHistory?.records.isNotEmpty ?? false;
  }
}