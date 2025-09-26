// lib/features/attendance/screens/widgets/manual_attendance_student_item.dart - SIMPLIFIED
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ManualAttendanceStudentItem extends StatelessWidget {
  final StudentModel student;
  final StudentAttendanceStatus? attendanceStatus;
  final bool isProcessing;
  final Function(StudentModel) onMarkAttendance;
  final Function(StudentModel) onUndoAttendance;

  const ManualAttendanceStudentItem({
    super.key,
    required this.student,
    required this.attendanceStatus,
    required this.isProcessing,
    required this.onMarkAttendance,
    required this.onUndoAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final studentCode = student.qrId ?? student.id;
    final hasAttendance = attendanceStatus != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasAttendance
              ? AppColors.success.withOpacity(0.3)
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
        leading: _buildLeadingAvatar(hasAttendance),
        title: _buildTitle(hasAttendance),
        subtitle: _buildSubtitle(studentCode, hasAttendance),
        trailing: _buildActionButton(hasAttendance),
      ),
    );
  }

  Widget _buildLeadingAvatar(bool hasAttendance) {
    return CircleAvatar(
      backgroundColor: hasAttendance
          ? AppColors.success
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
              hasAttendance ? Icons.check : Icons.person,
              color: Colors.white,
              size: 20,
            ),
    );
  }

  Widget _buildTitle(bool hasAttendance) {
    return Text(
      student.name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: hasAttendance ? AppColors.success : AppColors.grey800,
      ),
    );
  }

  Widget _buildSubtitle(String studentCode, bool hasAttendance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mã: $studentCode'),
        if (hasAttendance && attendanceStatus?.markedAt != null) ...[
          const SizedBox(height: 4),
          Text(
            'Đã điểm danh lúc: ${_formatTime(attendanceStatus!.markedAt)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(bool hasAttendance) {
    if (isProcessing) {
      return const SizedBox(
        width: 80,
        child: Center(
          child: Text(
            'Đang xử lý...',
            style: TextStyle(fontSize: 12),
          ),
        ),
      );
    }

    if (!hasAttendance) {
      // Chưa điểm danh - hiện nút "Có mặt"
      return Container(
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onMarkAttendance(student),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Có mặt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Đã điểm danh - chỉ hiện nút "Hủy"
      return Container(
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error.withOpacity(0.3)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => onUndoAttendance(student),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.undo, color: AppColors.error, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Hủy',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}