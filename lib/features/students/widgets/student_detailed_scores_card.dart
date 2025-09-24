import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class StudentDetailedScoresCard extends StatelessWidget {
  final StudentModel student;

  const StudentDetailedScoresCard({super.key, required this.student});

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
            'Chi tiết điểm số',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 20),

          // Study scores section
          _buildSectionHeader('Điểm học tập', Icons.school),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildScoreDetail('45\' HK1', student.study45Hk1?.toStringAsFixed(1) ?? '0.0'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScoreDetail('Thi HK1', student.examHk1?.toStringAsFixed(1) ?? '0.0'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScoreDetail('45\' HK2', student.study45Hk2?.toStringAsFixed(1) ?? '0.0'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScoreDetail('Thi HK2', student.examHk2?.toStringAsFixed(1) ?? '0.0'),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),

          // Attendance details section
          _buildSectionHeader('Điểm danh chi tiết', Icons.event_available),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildAttendanceDetail(
                  'Thứ 5',
                  student.thursdayAttendanceCount?.toString() ?? '0',
                  'buổi',
                  AppColors.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAttendanceDetail(
                  'Chủ nhật',
                  student.sundayAttendanceCount?.toString() ?? '0',
                  'buổi',
                  AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          
          // Calculation explanation
          _buildCalculationInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDetail(String label, String score) {
    final scoreValue = double.tryParse(score) ?? 0.0;
    final color = _getScoreColor(scoreValue);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.grey600,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            score,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceDetail(String title, String count, String unit, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                count,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey200),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: AppColors.grey600),
              SizedBox(width: 8),
              Text(
                'Cách tính điểm',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '• Học tập: (45\'HK1 + 45\'HK2 + ThiHK1×2 + ThiHK2×2) ÷ 6',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '• Điểm danh: (Thứ5×0.4 + CN×0.6) × (10÷tổng tuần)',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            '• Tổng kết: Học tập×0.6 + Điểm danh×0.4',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.grey600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.5) return AppColors.success;
    if (score >= 7.0) return AppColors.primary;
    if (score >= 5.5) return AppColors.warning;
    return AppColors.error;
  }
}