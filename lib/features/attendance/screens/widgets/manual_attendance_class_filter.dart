// lib/features/attendance/screens/widgets/manual_attendance_class_filter.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ManualAttendanceClassFilter extends StatelessWidget {
  final List<String> availableClasses;
  final String? selectedClass;
  final Function(String?) onClassChanged;

  const ManualAttendanceClassFilter({
    super.key,
    required this.availableClasses,
    required this.selectedClass,
    required this.onClassChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 20, color: AppColors.grey600),
          const SizedBox(width: 8),
          const Text(
            'Lọc theo lớp:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildClassFilterChip('Tất cả', null),
                  const SizedBox(width: 8),
                  ...availableClasses.map((className) =>
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildClassFilterChip(className, className),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassFilterChip(String label, String? value) {
    final isSelected = selectedClass == value;
    
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.grey700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        onClassChanged(selected ? value : null);
      },
      backgroundColor: Colors.white,
      selectedColor: AppColors.secondary,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? AppColors.secondary : AppColors.grey300,
        width: 1,
      ),
    );
  }
}