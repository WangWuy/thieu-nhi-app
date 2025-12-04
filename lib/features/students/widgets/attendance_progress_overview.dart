import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AttendanceProgressOverview extends StatelessWidget {
  final StudentModel student;
  final List<AttendanceRecord> records;
  final bool isLoading;
  final VoidCallback onViewHistory;

  const AttendanceProgressOverview({
    super.key,
    required this.student,
    required this.records,
    required this.isLoading,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    final totalWeeks = student.academicYearTotalWeeks ?? 0;
    final startDate = student.academicYearStartDate;
    final hasAcademicData = totalWeeks > 0 && startDate != null;

    if (!hasAcademicData) {
      return _buildMissingAcademicYear(context);
    }

    final thursdayWeeks =
        _buildAttendanceMap('thursday', startDate!, totalWeeks);
    final sundayWeeks = _buildAttendanceMap('sunday', startDate, totalWeeks);
    final weeks = List<int>.generate(totalWeeks, (index) => index + 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        if (isLoading) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(
            minHeight: 4,
            color: AppColors.primary,
            backgroundColor: AppColors.grey200,
          ),
        ],
        const SizedBox(height: 12),
        _buildTypeRow(
          context,
          label: 'Thứ 5',
          map: thursdayWeeks,
          weeks: weeks,
        accent: AppColors.secondary,
      ),
      const SizedBox(height: 12),
      _buildTypeRow(
        context,
        label: 'Chủ nhật',
        map: sundayWeeks,
        weeks: weeks,
        accent: AppColors.primary,
      ),
      const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onViewHistory,
            icon: const Icon(Icons.history),
            label: const Text('Xem lịch sử điểm danh'),
            style: TextButton.styleFrom(
              foregroundColor:
                  Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.7);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.calendar_month, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tiến độ điểm danh',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Theo năm học ${student.academicYearName ?? ''}',
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeRow(
    BuildContext context, {
    required String label,
    required Map<int, bool> map,
    required List<int> weeks,
    required Color accent,
  }) {
    final theme = Theme.of(context);
    final presentCount = map.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accent.withOpacity(0.3)),
                    ),
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: accent.shade700OrSelf,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$presentCount/${weeks.length} buổi',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const Spacer(),
                  _buildLegend(accent, theme),
                ],
              ),
              const SizedBox(height: 6),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                      _calculateCrossAxisCount(constraints.maxWidth);
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: weeks.length,
                    itemBuilder: (context, index) {
                      final week = weeks[index];
                      final isPresent = map[week] ?? false;
                      return _WeekCell(
                        week: week,
                        isPresent: isPresent,
                        accent: accent,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(Color accent, ThemeData theme) {
    final muted = theme.colorScheme.onSurface.withOpacity(0.6);
    return Row(
      children: [
        _LegendDot(color: accent, label: 'Có mặt', textColor: muted),
        const SizedBox(width: 8),
        _LegendDot(
          color: AppColors.grey200,
          borderColor: AppColors.grey300,
          label: 'Chưa có',
          textColor: muted,
        ),
      ],
    );
  }

  Widget _buildMissingAcademicYear(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.7);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'Chưa có dữ liệu năm học',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Cần thông tin năm học để hiển thị tiến độ điểm danh.',
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onViewHistory,
            icon: const Icon(Icons.history),
            label: const Text('Xem lịch sử điểm danh'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Map<int, bool> _buildAttendanceMap(
    String type,
    DateTime startDate,
    int totalWeeks,
  ) {
    final map = <int, bool>{};
    for (final record in records) {
      if (record.attendanceType != type || !record.isPresent) continue;
      final week = _calculateWeekNumber(record.attendanceDate, startDate);
      if (week != null && week >= 1 && week <= totalWeeks) {
        map[week] = true;
      }
    }
    return map;
  }

  int? _calculateWeekNumber(DateTime attendanceDate, DateTime startDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final current =
        DateTime(attendanceDate.year, attendanceDate.month, attendanceDate.day);

    final diffDays = current.difference(start).inDays;
    if (diffDays < 0) return null;
    return (diffDays ~/ 7) + 1;
  }

  int _calculateCrossAxisCount(double maxWidth) {
    const minCellWidth = 40.0;
    final count = (maxWidth / minCellWidth).floor();
    return count.clamp(2, 6);
  }
}

class _WeekCell extends StatelessWidget {
  final int week;
  final bool isPresent;
  final Color accent;

  const _WeekCell({
    required this.week,
    required this.isPresent,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        isPresent ? accent.shade700OrSelf : theme.colorScheme.onSurface.withOpacity(0.7);

    return Container(
      decoration: BoxDecoration(
        color: isPresent ? accent.withOpacity(0.1) : theme.cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isPresent ? accent.withOpacity(0.6) : AppColors.grey200,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'T$week',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: textColor,
              fontSize: 11,
            ),
          ),
          isPresent
              ? const Icon(Icons.check, size: 11, color: Colors.green)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final String label;
  final Color textColor;

  const _LegendDot({
    required this.color,
    this.borderColor,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor ?? color),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

extension _ColorShade on Color {
  Color get shade700OrSelf {
    if (this is MaterialColor) {
      return (this as MaterialColor)[700] ?? this;
    }
    return this;
  }
}
