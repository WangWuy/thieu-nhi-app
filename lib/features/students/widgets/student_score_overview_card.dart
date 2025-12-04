import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class StudentScoreOverviewCard extends StatelessWidget {
  final StudentModel student;

  const StudentScoreOverviewCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mutedColor = theme.colorScheme.onSurface.withOpacity(0.7);
    final shadowColor =
        isDark ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng quan điểm số',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildScoreItem(
                  context,
                  'Điểm danh',
                  student.attendanceAverage?.toStringAsFixed(2) ?? '0.00',
                  AppColors.primary,
                  Icons.event_available,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreItem(
                  context,
                  'Học tập',
                  student.studyAverage?.toStringAsFixed(2) ?? '0.00',
                  AppColors.secondary,
                  Icons.school,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreItem(
                  context,
                  'Tổng kết',
                  student.finalAverage?.toStringAsFixed(2) ?? '0.00',
                  _getScoreColor(student.finalAverage ?? 0.0),
                  Icons.star,
                ),
              ),
            ],
          ),

          // Thêm progress bars
          const SizedBox(height: 20),
          _buildProgressBar(
            context,
            'Điểm danh',
            student.attendanceAverage ?? 0.0,
            10.0,
            AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            context,
            'Học tập',
            student.studyAverage ?? 0.0,
            10.0,
            AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            context,
            'Tổng kết',
            student.finalAverage ?? 0.0,
            10.0,
            _getScoreColor(student.finalAverage ?? 0.0),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreItem(
      BuildContext context, String title, String score, Color color, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            score,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
      BuildContext context, String label, double value, double maxValue, Color color) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
            Text(
              '${value.toStringAsFixed(2)}/${maxValue.toInt()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: theme.dividerColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.5) return AppColors.success;
    if (score >= 7.0) return AppColors.primary;
    if (score >= 5.5) return AppColors.warning;
    return AppColors.error;
  }
}
