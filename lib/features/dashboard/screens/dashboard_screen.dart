// lib/features/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/department_model.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/dashboard_service.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:thieu_nhi_app/features/dashboard/widgets/department_card.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(DashboardService())..loadDashboard(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authState.user;
          return Scaffold(
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardCubit>().refreshDashboard();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(user),
                        const SizedBox(height: 20),
                        _buildStatsSection(user),
                        const SizedBox(height: 24),
                        _buildMainContent(user),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Xin chào,',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getRoleColor(user.role).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
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
      ],
    );
  }

  Widget _buildStatsSection(UserModel user) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded || state is DashboardRefreshing) {
          final data = state is DashboardLoaded
              ? state.data
              : (state as DashboardRefreshing).previousData;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getRoleGradient(user.role),
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _getRoleColor(user.role).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getRoleIcon(user.role),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatsTitle(user.role),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getStatsSubtitle(user, data),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Refresh indicator
                    if (state is DashboardRefreshing)
                      Container(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatsContent(user, data),
              ],
            ),
          );
        }
        return _buildStatsLoading();
      },
    );
  }

  Widget _buildStatsContent(UserModel user, data) {
    switch (user.role) {
      case UserRole.admin:
        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Tổng thiếu nhi',
                data.totalStudents.toString(),
                Icons.groups,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                'Tổng lớp',
                data.totalClasses.toString(),
                Icons.school,
              ),
            ),
          ],
        );
      case UserRole.department:
        final departmentStudents = (data.totalStudents as int) ~/ 4;
        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'thiếu nhi ngành',
                departmentStudents.toString(),
                Icons.people,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                'Có mặt hôm nay',
                data.presentToday.toString(),
                Icons.check_circle,
              ),
            ),
          ],
        );
      case UserRole.teacher:
        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'thiếu nhi lớp',
                '25', // TODO: Get real data from class
                Icons.people,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                'Có mặt hôm nay',
                '23', // TODO: Get real data from class
                Icons.check_circle,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildMainContent(UserModel user) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoaded || state is DashboardRefreshing) {
          final data = state is DashboardLoaded
              ? state.data
              : (state as DashboardRefreshing).previousData;

          switch (user.role) {
            case UserRole.admin:
              return _buildAdminContent(context, data);
            case UserRole.department:
              return _buildDepartmentContent(context, user);
            case UserRole.teacher:
              return _buildTeacherContent(context, user);
          }
        } else if (state is DashboardError) {
          return _buildErrorContent(state.message);
        }
        return _buildLoadingContent();
      },
    );
  }

  Widget _buildAdminContent(BuildContext context, data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quản lý ngành', Icons.business),
        const SizedBox(height: 16),

        // Convert data.departments to DepartmentModels for compatibility
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: data.departments.length + 1, // +1 for Account Management
          itemBuilder: (context, index) {
            if (index == data.departments.length) {
              return _buildAccountManagementCard(
                  context, data.usersByRole['giao_ly_vien'] ?? 0);
            }

            final dept = data.departments[index];
            // Convert DepartmentSummary to DepartmentModel
            final departmentModel = DepartmentModel(
              id: int.tryParse(dept.id) ?? 0,
              name: dept.name,
              displayName: dept.displayName,
              description: null,
              classIds: [],
              totalClasses: dept.totalClasses,
              totalStudents: dept.totalStudents,
              totalTeachers: dept.totalTeachers,
              isActive: true,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            return DepartmentCard(
              name: dept.displayName,
              totalClasses: dept.totalClasses,
              isAccessible: true,
              onTap: () =>
                  context.push('/classes/${dept.id}', extra: departmentModel),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAccountManagementCard(BuildContext context, int teacherCount) {
    return GestureDetector(
      onTap: () => context.push('/admin/accounts'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(colors: AppColors.errorGradient),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Giáo lý viên',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$teacherCount GLV',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentContent(BuildContext context, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quản lý ngành ${user.department}', Icons.business),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: _buildManagementCard(
              context: context,
              title: 'Danh sách lớp',
              subtitle: 'Quản lý lớp và thiếu nhi',
              icon: Icons.school,
              color: AppColors.primary,
              onTap: () => context.push('/classes/${user.department}'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherContent(BuildContext context, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Lớp học của tôi', Icons.school),
        const SizedBox(height: 16),
        if (user.className != null)
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: _buildManagementCard(
                context: context,
                title: user.className!,
                subtitle: 'Quản lý thiếu nhi',
                icon: Icons.school,
                color: AppColors.success,
                onTap: () => context.push('/students/${user.classId}'),
              ),
            ),
          )
        else
          _buildNoClassAssignedCard(),
      ],
    );
  }

  Widget _buildManagementCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoClassAssignedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.warning, color: AppColors.warning, size: 48),
          const SizedBox(height: 16),
          Text(
            'Chưa được phân công lớp',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Có lỗi xảy ra',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildLoadingContent() {
    return Container(
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.grey800,
          ),
        ),
      ],
    );
  }

  // Helper methods
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

  List<Color> _getRoleGradient(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [AppColors.error, const Color(0xFFFC8181)];
      case UserRole.department:
        return AppColors.primaryGradient;
      case UserRole.teacher:
        return AppColors.successGradient;
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

  String _getStatsTitle(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Tổng quan hệ thống';
      case UserRole.department:
        return 'Tổng quan ngành';
      case UserRole.teacher:
        return 'Tổng quan lớp học';
    }
  }

  String _getStatsSubtitle(UserModel user, data) {
    switch (user.role) {
      case UserRole.admin:
        return 'Quản lý ${data.totalStudents} thiếu nhi';
      case UserRole.department:
        return 'Ngành ${user.department}';
      case UserRole.teacher:
        return user.className ?? 'Chưa phân công lớp';
    }
  }
}
