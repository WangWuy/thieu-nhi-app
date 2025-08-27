// lib/features/admin/widgets/account_management_header.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_state.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AccountManagementHeader extends StatelessWidget {
  final bool isCollapsed;
  final AdminState state;
  final List<UserModel> filteredUsers;
  final Function(String) onMenuAction;

  const AccountManagementHeader({
    super.key,
    required this.isCollapsed,
    required this.state,
    required this.filteredUsers,
    required this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0, // Không có phần mở rộng
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      flexibleSpace: null, // Không có FlexibleSpace
      title: _buildCompactTitle(), // Luôn hiển thị title thu gọn
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: onMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('Xuất danh sách'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'import',
              child: Row(
                children: [
                  Icon(Icons.upload),
                  SizedBox(width: 8),
                  Text('Nhập từ Excel'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'bulk_operations',
              child: Row(
                children: [
                  Icon(Icons.assignment_turned_in),
                  SizedBox(width: 8),
                  Text('Thao tác hàng loạt'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactTitle() {
    if (state is AdminLoaded) {
      final activeUsers = filteredUsers.where((u) => u.isActive).length;
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Quản lý tài khoản',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${filteredUsers.length} tài khoản • $activeUsers hoạt động',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      );
    }
    return const Text(
      'Quản lý tài khoản',
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}