// lib/features/admin/widgets/account_stats_cards.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_bloc.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_state.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_event.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AccountStatsCards extends StatelessWidget {
  final AdminState state;

  const AccountStatsCards({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Handle different states
    if (state is AdminLoaded) {
      return _buildStatsCards((state as AdminLoaded).users, context);
    } else if (state is AdminRefreshing) {
      // Show previous data while refreshing
      return _buildStatsCards((state as AdminRefreshing).previousState.users, context, isRefreshing: true);
    } else if (state is AdminLoading) {
      return _buildSkeletonCards();
    } else if (state is AdminError) {
      return _buildErrorCards(context);
    }
    
    // Initial or unknown state
    return _buildSkeletonCards();
  }

  Widget _buildStatsCards(List<UserModel> users, BuildContext context, {bool isRefreshing = false}) {
    final totalUsers = users.length;
    final activeUsers = users.where((u) => u.isActive).length;
    final inactiveUsers = users.where((u) => !u.isActive).length;
    final adminCount = users.where((u) => u.role == UserRole.admin).length;
    final teacherCount = users.where((u) => u.role == UserRole.teacher).length;
    final departmentCount = users.where((u) => u.role == UserRole.department).length;

    return Column(
      children: [
        // Refreshing indicator
        if (isRefreshing)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.info.withOpacity(0.3)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.info),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Đang cập nhật...',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        
        // Stats cards
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Tổng TK',
                value: totalUsers.toString(),
                icon: Icons.people,
                color: AppColors.primary,
                subtitle: '$activeUsers hoạt động',
                onTap: () => _showStatsDetail(context, 'Tổng số tài khoản', {
                  'Tổng tài khoản': totalUsers,
                  'Đang hoạt động': activeUsers,
                  'Bị khóa': inactiveUsers,
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'BĐH',
                value: adminCount.toString(),
                icon: Icons.admin_panel_settings,
                color: AppColors.error,
                subtitle: 'Ban điều hành',
                onTap: () => _showRoleDetail(context, UserRole.admin, users),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'PDT',
                value: departmentCount.toString(),
                icon: Icons.groups,
                color: AppColors.warning,
                subtitle: 'Phân đoàn trưởng',
                onTap: () => _showRoleDetail(context, UserRole.department, users),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                title: 'GLV',
                value: teacherCount.toString(),
                icon: Icons.school,
                color: AppColors.success,
                subtitle: 'Giáo lý viên',
                onTap: () => _showRoleDetail(context, UserRole.teacher, users),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorCards(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Không thể tải thống kê',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vuốt xuống để thử lại',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.error.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<AdminBloc>().add(const LoadAllUsers());
            },
            icon: const Icon(Icons.refresh, color: AppColors.error),
            tooltip: 'Thử lại',
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonCards() {
    return Row(
      children: List.generate(4, (index) => 
        Expanded(
          child: Container(
            margin: index < 3 ? const EdgeInsets.only(right: 12) : null,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Icon skeleton
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                // Value skeleton
                Container(
                  width: 30,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 2),
                // Title skeleton
                Container(
                  width: 40,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 2),
                // Subtitle skeleton
                Container(
                  width: 35,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.grey200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStatsDetail(BuildContext context, String title, Map<String, int> stats) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: stats.entries.map((entry) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key),
                  Text(
                    entry.value.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showRoleDetail(BuildContext context, UserRole role, List<UserModel> allUsers) {
    final roleUsers = allUsers.where((u) => u.role == role).toList();
    final activeCount = roleUsers.where((u) => u.isActive).length;
    final inactiveCount = roleUsers.where((u) => !u.isActive).length;
    
    // Group by department
    final departmentGroups = <String, int>{};
    for (final user in roleUsers) {
      departmentGroups[user.department] = (departmentGroups[user.department] ?? 0) + 1;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết ${role.displayName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Tổng số', roleUsers.length.toString()),
            _buildDetailRow('Đang hoạt động', activeCount.toString()),
            _buildDetailRow('Bị khóa', inactiveCount.toString()),
            
            if (departmentGroups.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'Theo ngành:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...departmentGroups.entries.map((entry) => 
                _buildDetailRow('Ngành ${entry.key}', entry.value.toString())),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 8,
                  color: color.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}