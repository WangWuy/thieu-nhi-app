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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: record.isPresent
            ? AppColors.success.withOpacity(0.1)
            : AppColors.error.withOpacity(0.1),
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
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    Text(
                      record.attendanceType == 'thursday' ? 'Thứ 5' : 'Chủ nhật',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.grey600,
                      ),
                    ),
                    if (record.note?.isNotEmpty ?? false) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.note, size: 12, color: AppColors.grey500),
                    ],
                  ],
                ),
                if (record.note?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.note!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey500,
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
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.grey500,
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