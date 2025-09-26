import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ManualAttendanceClassFilter extends StatelessWidget {
  final List<String> availableClasses;
  final String? selectedClass;
  final Function(String?) onClassChanged;
  final Map<String, int> classStudentCounts; // NEW: Số lượng học sinh theo lớp

  const ManualAttendanceClassFilter({
    super.key,
    required this.availableClasses,
    required this.selectedClass,
    required this.onClassChanged,
    required this.classStudentCounts,
  });

  @override
  Widget build(BuildContext context) {
    final totalStudents = classStudentCounts.values.fold(0, (sum, count) => sum + count);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header với dropdown
          Row(
            children: [
              const Icon(Icons.filter_list, size: 20, color: AppColors.grey600),
              const SizedBox(width: 8),
              const Text(
                'Lọc theo lớp:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey300),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: DropdownButton<String?>(
                    value: selectedClass,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: Text(
                      'Tất cả ($totalStudents học sinh)',
                      style: const TextStyle(color: AppColors.grey600),
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey600),
                    items: _buildDropdownItems(),
                    onChanged: onClassChanged,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String?>> _buildDropdownItems() {
    final totalStudents = classStudentCounts.values.fold(0, (sum, count) => sum + count);
    
    return [
      DropdownMenuItem<String?>(
        value: null,
        child: Row(
          children: [
            const Icon(Icons.select_all, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Tất cả'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$totalStudents',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      ...availableClasses.map((className) {
        final count = classStudentCounts[className] ?? 0;
        return DropdownMenuItem<String?>(
          value: className,
          child: Row(
            children: [
              const Icon(Icons.class_, size: 16, color: AppColors.secondary),
              const SizedBox(width: 8),
              Expanded(child: Text(className)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    ];
  }
}