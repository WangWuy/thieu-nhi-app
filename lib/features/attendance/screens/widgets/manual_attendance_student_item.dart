// lib/features/attendance/screens/widgets/manual_attendance_student_item.dart - SIMPLIFIED
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:thieu_nhi_app/core/services/http_client.dart';
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
    final studentClass = student.className;
    final parentPhone = student.parentPhone;
    final parentPhone2 = student.parentPhone2;
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
        subtitle: _buildSubtitle(
            studentClass, hasAttendance, parentPhone, parentPhone2),
        trailing: _buildActionButton(hasAttendance),
      ),
    );
  }

  Widget _buildLeadingAvatar(bool hasAttendance) {
    final imageUrl = _resolveAvatarUrl(student.avatarUrl ?? student.photoUrl);

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: hasAttendance
              ? AppColors.success.withOpacity(0.2)
              : AppColors.grey200,
          child: ClipOval(
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(hasAttendance),
                  )
                : _buildPlaceholder(hasAttendance),
          ),
        ),
        if (isProcessing)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
      ],
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

  Widget _buildSubtitle(String studentClass, bool hasAttendance,
      String parentPhone, String? parentPhone2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$studentClass'),
        Text('SĐT1: $parentPhone'),
        if (parentPhone2 == null || parentPhone2.isEmpty) ...[
          const Text(
            'SĐT2: Chưa cập nhật',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: AppColors.grey600,
            ),
          ),
        ] else ...[
          Text('SĐT2: $parentPhone2'),
        ],
        if (hasAttendance && attendanceStatus?.markedAt != null) ...[
          const SizedBox(height: 4),
          Text(
            'Đã điểm danh lúc: ${_formatVietnamAttendanceTime(attendanceStatus!.markedAt)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
          if ((attendanceStatus?.markedBy ?? '').isNotEmpty)
            Text(
              'Điểm danh bởi: ${attendanceStatus!.markedBy}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.grey700,
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

  String _formatVietnamAttendanceTime(DateTime dateTime) {
    const weekdayNames = [
      'Chủ nhật',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
    ];

    final vietnamTime = dateTime.toUtc().add(const Duration(hours: 7));
    final weekdayLabel = weekdayNames[vietnamTime.weekday % 7];
    final day = vietnamTime.day.toString().padLeft(2, '0');
    final month = vietnamTime.month.toString().padLeft(2, '0');
    final year = vietnamTime.year.toString();
    final hour = vietnamTime.hour.toString().padLeft(2, '0');
    final minute = vietnamTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute, $day/$month/$year, $weekdayLabel';
  }

  Widget _buildPlaceholder(bool hasAttendance) {
    return Container(
      color: hasAttendance ? AppColors.success : AppColors.grey400,
      width: 44,
      height: 44,
      child: Icon(
        hasAttendance ? Icons.check : Icons.person,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  String? _resolveAvatarUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    final base = HttpClient().apiBaseUrl;
    if (path.startsWith('/')) return '$base$path';
    return '$base/$path';
  }
}
