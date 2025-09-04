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
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Nhập tên thiếu nhi hoặc lớp để tìm kiếm...',
          prefixIcon: const Icon(Icons.search, color: AppColors.grey600),
          suffixIcon: _buildSuffixIcon(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.grey300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.secondary),
          ),
          filled: true,
          fillColor: AppColors.grey50,
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon() {
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
        icon: const Icon(Icons.clear, color: AppColors.grey600),
        onPressed: onClear,
      );
    }
    
    return null;
  }
}