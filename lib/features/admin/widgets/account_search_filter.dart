// lib/features/admin/widgets/account_search_filter.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AccountSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String? selectedDepartmentFilter;
  final bool showInactiveOnly;
  final Function(String?) onDepartmentChanged;
  final Function(bool) onInactiveFilterChanged;

  const AccountSearchFilter({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedDepartmentFilter,
    required this.showInactiveOnly,
    required this.onDepartmentChanged,
    required this.onInactiveFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, email, username...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.grey300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Filter row
            Row(
              children: [
                Expanded(
                  child: _DepartmentFilterDropdown(
                    selectedValue: selectedDepartmentFilter,
                    onChanged: onDepartmentChanged,
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('Chỉ tài khoản bị khóa'),
                  selected: showInactiveOnly,
                  onSelected: onInactiveFilterChanged,
                  selectedColor: AppColors.error.withOpacity(0.2),
                  checkmarkColor: AppColors.error,
                  side: BorderSide(
                    color:
                        showInactiveOnly ? AppColors.error : AppColors.grey300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentFilterDropdown extends StatelessWidget {
  final String? selectedValue;
  final Function(String?) onChanged;

  const _DepartmentFilterDropdown({
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: const Text('Chọn ngành'),
          value: selectedValue,
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Tất cả ngành'),
            ),
            ...['Chiên', 'Âu', 'Thiếu', 'Nghĩa'].map((dept) => DropdownMenuItem(
                  value: dept,
                  child: Text('Ngành $dept'),
                )),
          ],
          onChanged: onChanged,
          isExpanded: true,
        ),
      ),
    );
  }
}
