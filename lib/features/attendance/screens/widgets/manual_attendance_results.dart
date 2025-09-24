// lib/features/attendance/screens/widgets/manual_attendance_results.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_state.dart';
import 'package:thieu_nhi_app/features/attendance/screens/widgets/manual_attendance_student_item.dart';

class ManualAttendanceResults extends StatelessWidget {
  final TextEditingController searchController;
  final List<StudentModel> filteredResults;
  final String? selectedClassFilter;
  final TodayAttendanceStatus? todayStatus;
  final AttendanceState attendanceState;
  final Function(StudentModel) onMarkAttendance; // ✅ SIMPLIFIED
  final Function(StudentModel) onUndoAttendance; // ✅ NEW
  final VoidCallback onClearClassFilter;

  const ManualAttendanceResults({
    super.key,
    required this.searchController,
    required this.filteredResults,
    required this.selectedClassFilter,
    required this.todayStatus,
    required this.attendanceState,
    required this.onMarkAttendance,
    required this.onUndoAttendance,
    required this.onClearClassFilter,
  });

  @override
  Widget build(BuildContext context) {
    if (filteredResults.isEmpty) {
      // Nếu có search text thì hiện "không tìm thấy"
      // Nếu không có search text thì hiện "chưa có dữ liệu"
      if (searchController.text.trim().isNotEmpty) {
        return _buildNoResultsState();
      } else {
        return _buildNoDataState(); // Trạng thái chưa load data
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredResults.length,
      itemBuilder: (context, index) {
        final student = filteredResults[index];
        final studentCode = student.qrId ?? student.id;
        final attendanceStatus = todayStatus?.getStudentStatus(studentCode);
        final isProcessing = attendanceState is AttendanceProcessing &&
            (attendanceState as AttendanceProcessing).studentCode ==
                studentCode;

        return ManualAttendanceStudentItem(
          student: student,
          attendanceStatus: attendanceStatus,
          isProcessing: isProcessing,
          onMarkAttendance: onMarkAttendance,
          onUndoAttendance: onUndoAttendance, // ✅ NEW
        );
      },
    );
  }

  Widget _buildNoDataState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Đang tải dữ liệu...',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            selectedClassFilter != null
                ? 'Không tìm thấy thiếu nhi nào trong lớp "$selectedClassFilter"'
                : 'Không tìm thấy thiếu nhi nào',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (selectedClassFilter != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onClearClassFilter,
              child: const Text('Xem tất cả kết quả'),
            ),
          ],
        ],
      ),
    );
  }
}
