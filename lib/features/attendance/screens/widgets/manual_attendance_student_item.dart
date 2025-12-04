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
    final hasAvatar = (student.avatarUrl ?? student.photoUrl)?.isNotEmpty ?? false;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = hasAttendance
        ? AppColors.success.withOpacity(0.4)
        : theme.dividerColor;
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.05);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: hasAttendance ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: InkWell(
          onTap: hasAvatar && !isProcessing ? () => _showAvatarViewer(context) : null,
          customBorder: const CircleBorder(),
          child: _buildLeadingAvatar(context, hasAttendance),
        ),
        title: _buildTitle(context, hasAttendance),
        subtitle: _buildSubtitle(
            context, studentClass, hasAttendance, parentPhone, parentPhone2),
        trailing: _buildActionButton(hasAttendance),
      ),
    );
  }

  Widget _buildLeadingAvatar(BuildContext context, bool hasAttendance) {
    final imageUrl = _resolveAvatarUrl(student.avatarUrl ?? student.photoUrl);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: hasAttendance
              ? AppColors.success.withOpacity(0.2)
              : theme.dividerColor.withOpacity(isDark ? 0.6 : 0.3),
          child: ClipOval(
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildPlaceholder(context, hasAttendance),
                  )
                : _buildPlaceholder(context, hasAttendance),
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

  Widget _buildTitle(BuildContext context, bool hasAttendance) {
    final theme = Theme.of(context);
    return Text(
      student.name,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: hasAttendance
            ? AppColors.success
            : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, String studentClass,
      bool hasAttendance, String parentPhone, String? parentPhone2) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withOpacity(0.7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$studentClass',
          style: theme.textTheme.bodyMedium,
        ),
        Text(
          'SĐT1: $parentPhone',
          style: theme.textTheme.bodyMedium?.copyWith(color: mutedColor),
        ),
        if (parentPhone2 == null || parentPhone2.isEmpty) ...[
          Text(
            'SĐT2: Chưa cập nhật',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: mutedColor,
            ),
          ),
        ] else ...[
          Text(
            'SĐT2: $parentPhone2',
            style: theme.textTheme.bodyMedium?.copyWith(color: mutedColor),
          ),
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
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: mutedColor,
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

  Widget _buildPlaceholder(BuildContext context, bool hasAttendance) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = hasAttendance
        ? AppColors.success
        : theme.dividerColor.withOpacity(isDark ? 0.7 : 0.9);

    return Container(
      color: baseColor,
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

  void _showAvatarViewer(BuildContext context) {
    final imageUrl = _resolveAvatarUrl(student.avatarUrl ?? student.photoUrl);
    if (imageUrl == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) {
        return GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Center(
              child: Hero(
                tag: 'student-avatar-${student.id}',
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white70,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
