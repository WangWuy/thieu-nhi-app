import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class StudentProfileCard extends StatelessWidget {
  final StudentModel student;

  const StudentProfileCard({super.key, required this.student});

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
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getDepartmentGradient(student.department),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey800,
                      ),
                    ),
                    if (student.saintName?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tên Thánh: ${student.saintName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Mã TN: ${student.qrId ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Lớp', '${student.className} - ${student.department}',
              Icons.class_),
          _buildInfoRow(
              'Ngày sinh', _formatDate(student.birthDate), Icons.cake),
          _buildInfoRow(
              'Điện thoại',
              student.phone.isNotEmpty ? student.phone : 'Chưa có',
              Icons.phone),
          _buildInfoRow(
              'SĐT phụ huynh 1', student.parentPhone, Icons.contact_phone),
          if (student.parentPhone2?.isNotEmpty ?? false)
            _buildInfoRow(
                'SĐT phụ huynh 2', student.parentPhone2!, Icons.contact_phone),
          _buildInfoRow('Địa chỉ', student.address, Icons.location_on,
              isLast: true),

          // Thêm thông tin thời gian
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: AppColors.grey600),
              const SizedBox(width: 8),
              Text(
                'Cập nhật: ${_formatDateTime(student.updatedAt)}',
                style: TextStyle(
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

  Widget _buildInfoRow(String label, String value, IconData icon,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.grey600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  List<Color> _getDepartmentGradient(String department) {
    switch (department.toLowerCase()) {
      case 'chien':
      case 'chiên':
        return [const Color(0xFFE53E3E), const Color(0xFFFC8181)];
      case 'au':
      case 'âu':
        return [const Color(0xFF3182CE), const Color(0xFF63B3ED)];
      case 'thieu':
      case 'thiếu':
        return [const Color(0xFF38A169), const Color(0xFF68D391)];
      case 'nghia':
      case 'nghĩa':
        return [const Color(0xFF805AD5), const Color(0xFFB794F6)];
      default:
        return [AppColors.primary, AppColors.secondary];
    }
  }
}
