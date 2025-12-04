import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/class_model.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ManualAttendanceClassFilter extends StatelessWidget {
  final List<ClassModel> classes;
  final String? selectedClassId;
  final ValueChanged<String?> onClassChanged;
  final bool isLoading;

  const ManualAttendanceClassFilter({
    super.key,
    required this.classes,
    required this.selectedClassId,
    required this.onClassChanged,
    this.isLoading = false,
  });

  int get _totalStudents =>
      classes.fold(0, (sum, classItem) => sum + classItem.totalStudents);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.7);
    final borderColor = theme.dividerColor;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, size: 20, color: muted),
              const SizedBox(width: 8),
              Text('Lọc theo lớp:',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(8),
                    color: theme.cardColor,
                  ),
                  child: isLoading
                      ? _buildLoadingState(context)
                      : DropdownButton<String?>(
                          value: selectedClassId,
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: Text(
                            'Tất cả ($_totalStudents học sinh)',
                            style:
                                theme.textTheme.bodyMedium?.copyWith(color: muted),
                          ),
                          icon: Icon(Icons.keyboard_arrow_down, color: muted),
                          items: _buildDropdownItems(context),
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

  Widget _buildLoadingState(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text(
          'Đang tải danh sách lớp...',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String?>> _buildDropdownItems(BuildContext context) {
    return [
      DropdownMenuItem<String?>(
        value: null,
        child: Row(
          children: [
            const Icon(Icons.select_all, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Tất cả'),
            const Spacer(),
            _buildCountBadge(context, _totalStudents, AppColors.primary),
          ],
        ),
      ),
      ...classes.map((classItem) {
        return DropdownMenuItem<String?>(
          value: classItem.id,
          child: Row(
            children: [
              const Icon(Icons.class_, size: 16, color: AppColors.secondary),
              const SizedBox(width: 8),
              Expanded(child: Text(classItem.name)),
              _buildCountBadge(
                  context, classItem.totalStudents, AppColors.secondary),
            ],
          ),
        );
      }),
    ];
  }

  Widget _buildCountBadge(BuildContext context, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
