// lib/features/dashboard/dashboard_screen.dart - UPDATED WITH SIMPLIFIED CARDS
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/dashboard_service.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withOpacity(0.7);

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
                        _buildHeader(context, user, onSurface, muted),
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

  Widget _buildHeader(
      BuildContext context, UserModel user, Color onSurface, Color muted) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.displayName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
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
            color: _getRoleColor(user.role)
                .withOpacity(isDark ? 0.25 : 0.1),
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
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final overlayColor = Colors.black.withOpacity(isDark ? 0.25 : 0.12);

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getRoleGradient(user.role),
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: _getRoleColor(user.role).withOpacity(0.18),
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
                      color: overlayColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getRoleIcon(user.role),
                      color: Colors.white.withOpacity(0.9),
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
                      const SizedBox(
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
                _buildStatsContent(context, user, data),
              ],
            ),
          );
        }
        return _buildStatsLoading(context);
      },
    );
  }

  Widget _buildStatsContent(BuildContext context, UserModel user, data) {
    switch (user.role) {
      case UserRole.admin:
        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                'Tổng thiếu nhi',
                data.totalStudents.toString(),
                Icons.groups,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                context,
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
                context,
                'thiếu nhi ngành',
                departmentStudents.toString(),
                Icons.people,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                context,
                'Có mặt hôm nay',
                data.presentToday.toString(),
                Icons.check_circle,
              ),
            ),
          ],
        );
      case UserRole.teacher:
        final classStudentCount = user.classStudentCount ?? data.totalStudents;
        final presentCount = data.presentToday;
        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                'thiếu nhi lớp',
                classStudentCount.toString(),
                Icons.people,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                context,
                'Có mặt hôm nay',
                presentCount.toString(),
                Icons.check_circle,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final overlay = Colors.black.withOpacity(isDark ? 0.2 : 0.1);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: overlay,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.9), size: 24),
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
                    color: Colors.white.withOpacity(0.85),
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

  Widget _buildStatsLoading(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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

  // 🔄 UPDATED: Simplified admin content - only 2 cards
  Widget _buildAdminContent(BuildContext context, data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Quản lý hệ thống', Icons.admin_panel_settings),
        const SizedBox(height: 16),
        
        // 2 cards in a row
        Row(
          children: [
            // Card 1: Giáo lý viên
            Expanded(
              child: _buildManagementCard(
                context: context,
                title: 'Giáo lý viên',
                subtitle: '${data.usersByRole['giao_ly_vien'] ?? 0} GLV',
                icon: Icons.school,
                color: AppColors.error,
                onTap: () => context.push('/admin/accounts'),
              ),
            ),
            const SizedBox(width: 16),
            // Card 2: Quản lý lớp  
            Expanded(
              child: _buildManagementCard(
                context: context,
                title: 'Quản lý lớp',
                subtitle: 'Tất cả ngành',
                icon: Icons.class_,
                color: AppColors.primary,
                onTap: () => context.push('/classes/all'), // Filter all departments
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 🔄 UPDATED: Simplified department content - only 1 card
  Widget _buildDepartmentContent(BuildContext context, UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Quản lý ngành ${user.department}', Icons.business),
        const SizedBox(height: 16),
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: _buildManagementCard(
              context: context,
              title: 'Quản lý lớp',
              subtitle: 'Ngành ${user.department}',
              icon: Icons.school,
              color: AppColors.primary,
              onTap: () => context.push('/classes/THIEU'), // Filter user's department
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
        _buildSectionHeader(context, 'Lớp học của tôi', Icons.school),
        const SizedBox(height: 16),
        if (user.className != null)
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: _buildManagementCard(
                context: context,
                title: user.className!,
                subtitle:
                    '${user.classStudentCount ?? 0} thiếu nhi • nhấn để xem danh sách',
                icon: Icons.groups,
                color: AppColors.success,
                onTap: () {
                  final classId = user.classId;
                  if (classId == null) return;
                  context.push('/students/$classId?isTeacherView=true');
                },
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
      child: const Column(
        children: [
          Icon(Icons.warning, color: AppColors.warning, size: 48),
          SizedBox(height: 16),
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
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          const Text(
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
    return const SizedBox(
      height: 200,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Helper methods remain the same
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
        if (user.className != null) {
          final count = user.classStudentCount;
          final countText =
              count != null ? ' • $count thiếu nhi' : '';
          return '${user.className}$countText';
        }
        return 'Chưa phân công lớp';
    }
  }
}
