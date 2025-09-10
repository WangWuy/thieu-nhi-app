// lib/features/attendance/screens/widgets/manual_attendance_student_item.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ManualAttendanceStudentItem extends StatelessWidget {
  final StudentModel student;
  final StudentAttendanceStatus? attendanceStatus;
  final bool isProcessing;
  final Function(StudentModel, bool) onMarkAttendance;

  const ManualAttendanceStudentItem({
    super.key,
    required this.student,
    required this.attendanceStatus,
    required this.isProcessing,
    required this.onMarkAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final studentCode = student.qrId ?? student.id;
    final hasAttendance = attendanceStatus != null;
    final isPresent = attendanceStatus?.isPresent ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasAttendance
              ? (isPresent
                  ? AppColors.success.withOpacity(0.3)
                  : AppColors.error.withOpacity(0.3))
              : AppColors.grey200,
          width: hasAttendance ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildLeadingAvatar(hasAttendance, isPresent),
        title: _buildTitle(hasAttendance, isPresent),
        subtitle: _buildSubtitle(studentCode, hasAttendance),
        trailing: _buildActionButtons(context),
      ),
    );
  }

  Widget _buildLeadingAvatar(bool hasAttendance, bool isPresent) {
    return CircleAvatar(
      backgroundColor: hasAttendance
          ? (isPresent ? AppColors.success : AppColors.error)
          : isProcessing
              ? AppColors.secondary
              : AppColors.grey300,
      child: isProcessing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(
              hasAttendance
                  ? (isPresent ? Icons.check : Icons.person)
                  : Icons.person,
              color: Colors.white,
              size: 20,
            ),
    );
  }

  Widget _buildTitle(bool hasAttendance, bool isPresent) {
    return Text(
      student.name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: hasAttendance
            ? (isPresent ? AppColors.success : AppColors.error)
            : AppColors.grey800,
      ),
    );
  }

  Widget _buildSubtitle(String studentCode, bool hasAttendance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mã: $studentCode'),
        Text('Lớp: ${student.className}'),
        if (student.department.isNotEmpty) Text('Ngành: ${student.department}'),
        if (hasAttendance) ...[
          const SizedBox(height: 4),
          Text(
            'Đã điểm danh: ${attendanceStatus!.statusText}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: attendanceStatus!.isPresent
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (isProcessing) {
      return const SizedBox(
        width: 60,
        child: Center(
            child: Text('Đang xử lý...', style: TextStyle(fontSize: 12))),
      );
    }

    final hasAttendance = attendanceStatus != null;
    final isPresent = attendanceStatus?.isPresent ?? false;

    if (!hasAttendance) {
      // Chưa điểm danh - chỉ hiện nút check, không hiện nút X
      return GestureDetector(
        onDoubleTap: null, // Không làm gì khi double tap vì chưa có trạng thái
        child: IconButton(
          onPressed: () => onMarkAttendance(student, true),
          icon: const Icon(Icons.check_circle, color: AppColors.success),
          tooltip: 'Có mặt',
        ),
      );
    } else {
      if (isPresent) {
        return InkWell(
          onDoubleTap: () => onMarkAttendance(student, false),
          child: const IconButton(
            onPressed: null, // Không cho nhấn single tap
            icon: Icon(Icons.check_circle, color: AppColors.success),
            tooltip: 'Double tap để chuyển sang vắng mặt',
          ),
        );
      } else {
        return IconButton(
          onPressed: () => onMarkAttendance(student, true),
          icon: const Icon(Icons.check_circle, color: AppColors.error),
          tooltip: 'Chuyển sang có mặt',
        );
      }
    }
  }
}
