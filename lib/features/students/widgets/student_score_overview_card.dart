import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class StudentScoreOverviewCard extends StatelessWidget {
  final StudentModel student;

  const StudentScoreOverviewCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng quan điểm số',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildScoreItem(
                  'Điểm danh',
                  student.attendanceAverage?.toStringAsFixed(1) ?? '0.0',
                  AppColors.primary,
                  Icons.event_available,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreItem(
                  'Học tập',
                  student.studyAverage?.toStringAsFixed(1) ?? '0.0',
                  AppColors.secondary,
                  Icons.school,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreItem(
                  'Tổng kết',
                  student.finalAverage?.toStringAsFixed(1) ?? '0.0',
                  _getScoreColor(student.finalAverage ?? 0.0),
                  Icons.star,
                ),
              ),
            ],
          ),

          // Thêm progress bars
          const SizedBox(height: 20),
          _buildProgressBar(
            'Điểm danh',
            student.attendanceAverage ?? 0.0,
            10.0,
            AppColors.primary,
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            'Học tập',
            student.studyAverage ?? 0.0,
            10.0,
            AppColors.secondary,
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
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
      String title, String score, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
      String label, double value, double maxValue, Color color) {
    final percentage = (value / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}/${maxValue.toInt()}',
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
            color: AppColors.grey200,
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
