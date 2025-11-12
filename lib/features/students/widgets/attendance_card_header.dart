// lib/features/students/widgets/attendance_card_header.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_attendance_history.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AttendanceCardHeader extends StatelessWidget {
  final StudentAttendanceHistory? attendanceHistory;
  final bool isLoading;
  final VoidCallback onRefresh;

  const AttendanceCardHeader({
    super.key,
    this.attendanceHistory,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.event_available, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        const Text(
          'Lịch sử điểm danh',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.grey800,
          ),
        ),
        const Spacer(),

        // Records count chip
        if (_hasRecentAttendance())
          Chip(
            label: Text(
              '${attendanceHistory!.records.length} gần nhất',
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: AppColors.primary.withOpacity(0.1),
          ),

        // Refresh button
        // IconButton(
        //   icon: Icon(
        //     Icons.refresh,
        //     size: 20,
        //     color: isLoading ? AppColors.grey400 : AppColors.primary,
        //   ),
        //   onPressed: isLoading ? null : onRefresh,
        //   tooltip: 'Làm mới',
        // ),
      ],
    );
  }

  bool _hasRecentAttendance() {
    return attendanceHistory?.records.isNotEmpty ?? false;
  }
}
