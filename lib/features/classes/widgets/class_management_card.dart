// lib/features/classes/widgets/class_management_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/class_model.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ClassManagementCard extends StatelessWidget {
  final ClassModel classModel;
  final String department;
  final bool canManage;
  final Function(String action, ClassModel classModel)? onActionSelected;
  final VoidCallback? onQRTap;

  const ClassManagementCard({
    super.key,
    required this.classModel,
    required this.department,
    this.canManage = false,
    this.onActionSelected,
    this.onQRTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/students/${classModel.id}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getDepartmentColor(department).withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildClassIcon(),
            const SizedBox(width: 16),
            Expanded(child: _buildSimpleClassInfo()),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.grey600,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getDepartmentGradient(department),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getDepartmentColor(department).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.school,
        color: Colors.white,
        size: 28,
      ),
    );
  }

  Widget _buildSimpleClassInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tên lớp và số thiếu nhi cùng dòng
        Row(
          children: [
            Text(
              classModel.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.grey800,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${classModel.totalStudents} thiếu nhi',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // GLV hiển thị đầy đủ
        Text(
          'GLV: ${classModel.teachersDisplay}',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getDepartmentColor(String department) {
    switch (department) {
      case 'Chiên':
        return AppColors.chienColor;
      case 'Âu':
        return AppColors.auColor;
      case 'Thiếu':
        return AppColors.thieuColor;
      case 'Nghĩa':
        return AppColors.nghiaColor;
      default:
        return AppColors.primary;
    }
  }

  List<Color> _getDepartmentGradient(String department) {
    switch (department) {
      case 'Chiên':
        return [AppColors.chienColor, const Color(0xFFFC8181)];
      case 'Âu':
        return [AppColors.auColor, const Color(0xFF63B3ED)];
      case 'Thiếu':
        return [AppColors.thieuColor, const Color(0xFF68D391)];
      case 'Nghĩa':
        return [AppColors.nghiaColor, const Color(0xFFB794F6)];
      default:
        return AppColors.primaryGradient;
    }
  }
}
