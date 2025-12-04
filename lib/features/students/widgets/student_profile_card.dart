import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/services/http_client.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class StudentProfileCard extends StatelessWidget {
  final StudentModel student;

  const StudentProfileCard({super.key, required this.student});

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
          Center(
            child: GestureDetector(
              onTap: () => _showAvatarViewer(context),
              child: _buildAvatar(),
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(context, 'Lớp', '${student.className} - ${student.department}',
              Icons.class_),
          _buildInfoRow(
              context,
              'Ngày sinh', _formatDate(student.birthDate), Icons.cake),
          _buildInfoRow(
              context,
              'Điện thoại',
              student.phone.isNotEmpty ? student.phone : 'Chưa có',
              Icons.phone),
          _buildInfoRow(
              context,
              'SĐT phụ huynh 1', student.parentPhone, Icons.contact_phone),
          if (student.parentPhone2?.isNotEmpty ?? false)
            _buildInfoRow(context,
                'SĐT phụ huynh 2', student.parentPhone2!, Icons.contact_phone),
          _buildInfoRow(context, 'Địa chỉ', student.address, Icons.location_on),
          if (student.note?.isNotEmpty ?? false)
            _buildInfoRow(context, 'Ghi chú', student.note!, Icons.note_alt,
                isLast: true)
          else
            _buildInfoRow(
                context, 'Ghi chú', 'Chưa có', Icons.note_alt, isLast: true),

          // Thêm thông tin thời gian
          const SizedBox(height: 16),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: mutedColor),
              const SizedBox(width: 8),
              Text(
                'Cập nhật: ${_formatDateTime(student.updatedAt)}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: mutedColor, fontWeight: FontWeight.w500),
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

  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon,
      {bool isLast = false}) {
    final theme = Theme.of(context);
    final mutedColor = theme.colorScheme.onSurface.withOpacity(0.7);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: mutedColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: mutedColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
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
