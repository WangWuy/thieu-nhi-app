// lib/features/attendance/screens/widgets/manual_attendance_search_bar.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ManualAttendanceSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final VoidCallback onClear;
  final bool isSearching;

  const ManualAttendanceSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.isSearching,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoration =
        const InputDecoration().applyDefaults(theme.inputDecorationTheme);
    final muted = theme.colorScheme.onSurface.withOpacity(0.7);
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: theme.textTheme.bodyLarge,
        decoration: decoration.copyWith(
          hintText: 'Nhập tên thiếu nhi hoặc lớp để tìm kiếm...',
          prefixIcon: Icon(Icons.search, color: muted),
          suffixIcon: _buildSuffixIcon(theme, muted),
          filled: decoration.filled ?? true,
          fillColor: decoration.fillColor ?? theme.inputDecorationTheme.fillColor,
          contentPadding: decoration.contentPadding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(ThemeData theme, Color muted) {
    if (isSearching) {
      return Container(
        width: 20,
        height: 20,
        padding: const EdgeInsets.all(12),
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.secondary,
        ),
      );
    }
    
    if (controller.text.isNotEmpty) {
      return IconButton(
        icon: Icon(Icons.clear, color: muted),
        onPressed: onClear,
      );
    }
    
    return null;
  }
}
