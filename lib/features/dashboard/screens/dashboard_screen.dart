import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/auth_service.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:thieu_nhi_app/features/dashboard/bloc/dashboard_event.dart';
import 'package:thieu_nhi_app/features/dashboard/bloc/dashboard_state.dart';
import 'package:thieu_nhi_app/features/dashboard/widgets/department_card.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = authState.user;
        return Scaffold(
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(RefreshDashboardData());
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
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoadedWithTeachers || state is DashboardLoaded) {
          final stats = state is DashboardLoadedWithTeachers
              ? state.stats
              : (state as DashboardLoaded).stats;

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
                            _getStatsSubtitle(user, stats),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatsContent(user, stats),
              ],
            ),
          );
        }
        return _buildStatsLoading();
      },
    );
  }

  Widget _buildStatsContent(UserModel user, Map<String, dynamic> stats) {
    switch (user.role) {
      case UserRole.admin:
        return Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Tổng thiếu nhi',
                stats['totalStudents'].toString(),
                Icons.groups,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                'Tổng lớp',
                stats['totalClasses'].toString(),
                Icons.school,
              ),
            ),
          ],
        );
      case UserRole.department:
        final departmentStudents = (stats['totalStudents'] as int) ~/ 4;
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
                'Lớp học',
                _getDepartmentClassCount(user.department).toString(),
                Icons.school,
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
                '25', // TODO: Get real data
                Icons.people,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatItem(
                'Có mặt hôm nay',
                '23', // TODO: Get real data
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
    switch (user.role) {
      case UserRole.admin:
        return _buildAdminContent();
      case UserRole.department:
        return _buildDepartmentContent(user);
      case UserRole.teacher:
        return _buildTeacherContent(user);
    }
  }

  Widget _buildAdminContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quản lý ngành', Icons.business),
        const SizedBox(height: 16),
        BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoadedWithTeachers ||
                state is DashboardLoaded) {
              final departments = state is DashboardLoadedWithTeachers
                  ? state.departments
                  : (state as DashboardLoaded).departments;

              return Column(
                children: [
                  // Departments + Account Management grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.9,
                    ),
                    itemCount:
                        departments.length + 1, // +1 for Account Management
                    itemBuilder: (context, index) {
                      // Account Management card
                      if (index == departments.length) {
                        return _buildAccountManagementCard();
                      }

                      // Regular department cards
                      final department = departments[index];
                      return DepartmentCard(
                        name: department.displayName,
                        totalClasses: department.totalClasses,
                        isAccessible: true,
                        onTap: () => context.push('/classes/${department.id}',
                            extra: department),
                      );
                    },
                  ),
                ],
              );
            }
            return _buildLoadingGrid();
          },
        ),
      ],
    );
  }

  Widget _buildAccountManagementCard() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        // Lấy số lượng teachers từ state
        int teacherCount = 0;
        if (state is DashboardLoadedWithTeachers) {
          teacherCount = state.teachers.length;
        } else if (state is DashboardRefreshing) {
          final prevState = state.previousState;
          if (prevState is DashboardLoadedWithTeachers) {
            teacherCount = prevState.teachers.length;
          }
        }

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
                      gradient: const LinearGradient(
                        colors: AppColors.errorGradient,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.school, // Đổi icon cho phù hợp hơn
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

                  // UPDATED: Hiển thị số lượng teachers thay vì text cố định
                  teacherCount > 0
                      ? Text(
                          '$teacherCount GLV',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        )
                      : Text(
                          'Đang tải...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey600,
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // UPDATED: Simplified Department content - only "Danh sách lớp"
  Widget _buildDepartmentContent(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Quản lý ngành ${user.department}', Icons.business),
        const SizedBox(height: 16),

        // Single centered management card
        Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.7,
            child: _buildDepartmentManagementCard(
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

  Widget _buildDepartmentManagementCard({
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
            colors: [
              color,
              color.withOpacity(0.8),
            ],
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
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
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

  Widget _buildTeacherContent(UserModel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Lớp học của tôi', Icons.school),
        const SizedBox(height: 16),

        // Single centered management card like Department style
        if (user.className != null)
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: _buildTeacherClassCard(user),
            ),
          )
        else
          _buildNoClassAssignedCard(),
      ],
    );
  }

  Widget _buildTeacherClassCard(UserModel user) {
    return GestureDetector(
      onTap: () =>
          context.push('/students/${user.classId}'), // Direct to students
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.success,
              AppColors.success.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
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
              child: const Icon(
                Icons.school,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.className!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Quản lý thiếu nhi',
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
          const SizedBox(height: 8),
          Text(
            'Vui lòng liên hệ Ban Điều Hành để được phân công lớp học',
            style: TextStyle(color: AppColors.grey600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: 5, // 4 departments + 1 account management
      itemBuilder: (context, index) => _buildLoadingCard(),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(feature),
        content: Text('Tính năng "$feature" đang được phát triển.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
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

  String _getStatsSubtitle(UserModel user, Map<String, dynamic> stats) {
    switch (user.role) {
      case UserRole.admin:
        return 'Quản lý ${stats['totalStudents']} thiếu nhi';
      case UserRole.department:
        return 'Ngành ${user.department}';
      case UserRole.teacher:
        return user.className ?? 'Chưa phân công lớp';
    }
  }

  int _getDepartmentClassCount(String department) {
    switch (department) {
      case 'Chiên':
        return 6;
      case 'Âu':
        return 2;
      case 'Thiếu':
        return 3;
      case 'Nghĩa':
        return 1;
      default:
        return 0;
    }
  }
}
