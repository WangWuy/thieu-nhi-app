// lib/features/admin/widgets/account_user_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/permission_service.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_bloc.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_event.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_state.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AccountUserList extends StatelessWidget {
  final AdminState state;
  final UserModel currentUser;
  final List<UserModel> filteredUsers;
  final Function(String, UserModel) onUserAction;

  const AccountUserList({
    super.key,
    required this.state,
    required this.currentUser,
    required this.filteredUsers,
    required this.onUserAction,
  });

  @override
  Widget build(BuildContext context) {
    if (state is AdminLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is AdminError) {
      return _buildErrorState(context);
    }

    if (state is AdminLoaded) {
      if (filteredUsers.isEmpty) {
        return _buildEmptyState();
      }

      return _buildUserList();
    }

    return const SliverFillRemaining(
      child: Center(child: Text('Không có dữ liệu')),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text((state as AdminError).message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<AdminBloc>().add(const LoadAllUsers()),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.grey400),
            SizedBox(height: 16),
            Text('Không tìm thấy tài khoản nào'),
            SizedBox(height: 8),
            Text(
              'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
              style: TextStyle(color: AppColors.grey600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100), // Tăng top padding từ 0 lên 16
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final user = filteredUsers[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: UserCard(
                user: user,
                currentUser: currentUser,
                onAction: onUserAction,
              ),
            );
          },
          childCount: filteredUsers.length,
        ),
      ),
    );
  }
}

class UserCard extends StatelessWidget {
  final UserModel user;
  final UserModel currentUser;
  final Function(String, UserModel) onAction;

  const UserCard({
    super.key,
    required this.user,
    required this.currentUser,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final permissionService = PermissionService();
    final canEdit = permissionService.canEditUser(currentUser, user);
    final canDelete = permissionService.canDeleteUser(currentUser, user);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: user.isActive 
              ? AppColors.grey200 
              : AppColors.error.withOpacity(0.3),
          width: user.isActive ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUserHeader(canEdit, canDelete),
          const SizedBox(height: 16),
          _buildUserDetails(),
        ],
      ),
    );
  }

  Widget _buildUserHeader(bool canEdit, bool canDelete) {
    return Row(
      children: [
        // Avatar
        UserAvatar(user: user),
        const SizedBox(width: 16),
        
        // User info
        Expanded(child: UserInfo(user: user)),
        
        // Actions
        UserActionMenu(
          user: user,
          canEdit: canEdit,
          canDelete: canDelete,
          onAction: onAction,
        ),
      ],
    );
  }

  Widget _buildUserDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          UserDetailRow(
            icon: Icons.email,
            label: 'Email',
            value: user.email,
          ),
          UserDetailRow(
            icon: Icons.phone,
            label: 'SĐT',
            value: user.phoneNumber ?? 'Chưa cập nhật',
          ),
          UserDetailRow(
            icon: Icons.business,
            label: 'Ngành',
            value: 'Ngành ${user.department}',
          ),
          if (user.className != null && user.className!.isNotEmpty)
            UserDetailRow(
              icon: Icons.school,
              label: 'Lớp',
              value: user.className!,
            ),
          if (user.lastLogin != null)
            UserDetailRow(
              icon: Icons.access_time,
              label: 'Lần cuối',
              value: _formatLastLogin(user.lastLogin!),
            ),
        ],
      ),
    );
  }

  String _formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}

class UserAvatar extends StatelessWidget {
  final UserModel user;

  const UserAvatar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _getRoleColor(user.role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getRoleColor(user.role).withOpacity(0.3),
        ),
      ),
      child: Icon(
        _getRoleIcon(user.role),
        color: _getRoleColor(user.role),
        size: 28,
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.department:
        return AppColors.primary;
      case UserRole.teacher:
        return AppColors.success;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.department:
        return Icons.groups;
      case UserRole.teacher:
        return Icons.school;
    }
  }
}

class UserInfo extends StatelessWidget {
  final UserModel user;

  const UserInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                user.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: user.isActive 
                    ? AppColors.success 
                    : AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: _getRoleColor(user.role).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            user.role.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getRoleColor(user.role),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@${user.username}',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.grey600,
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.error;
      case UserRole.department:
        return AppColors.primary;
      case UserRole.teacher:
        return AppColors.success;
    }
  }
}

class UserActionMenu extends StatelessWidget {
  final UserModel user;
  final bool canEdit;
  final bool canDelete;
  final Function(String, UserModel) onAction;

  const UserActionMenu({
    super.key,
    required this.user,
    required this.canEdit,
    required this.canDelete,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleAction(context, value),
      itemBuilder: (context) => [
        if (canEdit)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text('Chỉnh sửa'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'view',
          child: Row(
            children: [
              Icon(Icons.visibility),
              SizedBox(width: 8),
              Text('Xem chi tiết'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'reset_password',
          child: Row(
            children: [
              Icon(Icons.lock_reset),
              SizedBox(width: 8),
              Text('Đặt lại mật khẩu'),
            ],
          ),
        ),
        PopupMenuItem(
          value: user.isActive ? 'deactivate' : 'activate',
          child: Row(
            children: [
              Icon(user.isActive 
                  ? Icons.pause_circle 
                  : Icons.play_circle),
              const SizedBox(width: 8),
              Text(user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt'),
            ],
          ),
        ),
        if (canDelete)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Xóa', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
      ],
    );
  }

  void _handleAction(BuildContext context, String action) {
    if (action == 'edit') {
      // Navigate trực tiếp đến màn hình edit với user data
      context.push('/admin/accounts/edit/${user.id}', extra: user);
    } else {
      // Gọi callback cho các action khác
      onAction(action, user);
    }
  }
}

class UserDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const UserDetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.grey600),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey800,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}