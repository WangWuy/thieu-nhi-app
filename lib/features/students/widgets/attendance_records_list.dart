import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AttendanceRecordsList extends StatelessWidget {
  final List<AttendanceRecord> records;

  const AttendanceRecordsList({
    super.key,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: records.map((record) => AttendanceRecordItem(record: record)).toList(),
    );
  }
}

class AttendanceRecordItem extends StatelessWidget {
  final AttendanceRecord record;

  const AttendanceRecordItem({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = theme.colorScheme.onSurface.withOpacity(0.7);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: record.isPresent
            ? AppColors.success.withOpacity(isDark ? 0.2 : 0.1)
            : AppColors.error.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: record.isPresent
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            record.isPresent ? Icons.check_circle : Icons.cancel,
            color: record.isPresent ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(record.attendanceDate),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Row(
                  children: [
                    Text(
                      record.attendanceType == 'thursday' ? 'Thứ 5' : 'Chủ nhật',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: mutedColor,
                      ),
                    ),
                    if (record.note?.isNotEmpty ?? false) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.note, size: 12, color: mutedColor),
                    ],
                  ],
                ),
                if (record.note?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.note!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: mutedColor,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              Text(
                record.isPresent ? 'Có mặt' : 'Vắng',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: record.isPresent ? AppColors.success : AppColors.error,
                  fontSize: 12,
                ),
              ),
              if (record.markedAt != null) ...[
                Text(
                  _formatTime(record.markedAt!),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: mutedColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
