import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/services/http_client.dart';
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
          Center(
            child: GestureDetector(
              onTap: () => _showAvatarViewer(context),
              child: _buildAvatar(),
            ),
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
          _buildInfoRow('Địa chỉ', student.address, Icons.location_on),
          if (student.note?.isNotEmpty ?? false)
            _buildInfoRow('Ghi chú', student.note!, Icons.note_alt,
                isLast: true)
          else
            _buildInfoRow('Ghi chú', 'Chưa có', Icons.note_alt, isLast: true),

          // Thêm thông tin thời gian
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.schedule, size: 16, color: AppColors.grey600),
              const SizedBox(width: 8),
              Text(
                'Cập nhật: ${_formatDateTime(student.updatedAt)}',
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

  Widget _buildAvatar() {
    final imageUrl = _resolveAvatarUrl(student.avatarUrl ?? student.photoUrl);

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getDepartmentGradient(student.department),
        ),
        borderRadius: BorderRadius.circular(90),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(90),
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 132,
                ),
              )
            : const Icon(
                Icons.person,
                color: Colors.white,
                size: 132,
              ),
      ),
    );
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
                  style: const TextStyle(
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

  String? _resolveAvatarUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    final base = HttpClient().apiBaseUrl;
    if (path.startsWith('/')) return '$base$path';
    return '$base/$path';
  }
}
