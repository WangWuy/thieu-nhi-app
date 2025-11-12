// lib/features/admin/screens/account_management_screen.dart - COMPACT VERSION
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/permission_service.dart';
import 'package:thieu_nhi_app/core/services/auth_service.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_bloc.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_event.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_state.dart';
import 'package:thieu_nhi_app/features/admin/widgets/user_details_dialog.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late final ScrollController _scrollController;
  
  String _searchQuery = '';
  String? _selectedDepartmentFilter;
  bool _showInactiveOnly = false;
  bool _isLoadingMore = false;

  // Department mapping name -> ID (từ backend schema)
  final Map<String, int> _departmentMapping = {
    'Chiên': 1,
    'Ấu': 2, 
    'Thiếu': 3,
    'Nghĩa': 4,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _scrollController = ScrollController()..addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _loadUsers() {
    final adminBloc = context.read<AdminBloc>();
    if (adminBloc.state is AdminInitial || adminBloc.state is AdminError) {
      adminBloc.add(const LoadAllUsers());
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _searchQuery) {
      setState(() => _searchQuery = query);
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (query == _searchController.text.trim()) {
          _applyFilters();
        }
      });
    }
  }

  // Apply all active filters
  void _applyFilters() {
    final adminBloc = context.read<AdminBloc>();
    _isLoadingMore = false;
    
    if (_searchQuery.isNotEmpty) {
      // If searching, use search API
      adminBloc.add(SearchUsers(_searchQuery));
    } else {
      // Load users with current filters
      adminBloc.add(LoadAllUsers(
        departmentId: _selectedDepartmentFilter != null 
            ? _departmentMapping[_selectedDepartmentFilter!] 
            : null,
      ));
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients ||
        _isLoadingMore ||
        _searchQuery.isNotEmpty) {
      return;
    }

    final adminState = context.read<AdminBloc>().state;
    if (adminState is! AdminLoaded || !adminState.hasMore) {
      return;
    }

    if (_scrollController.position.extentAfter > 300) {
      return;
    }

    _isLoadingMore = true;
    final nextPage = adminState.currentPage + 1;

    context.read<AdminBloc>().add(LoadAllUsers(
      page: nextPage,
      departmentId: _selectedDepartmentFilter != null
          ? _departmentMapping[_selectedDepartmentFilter!] 
          : null,
    ));
  }

  // Clear all filters and reload
  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedDepartmentFilter = null;
      _showInactiveOnly = false;
    });
    context.read<AdminBloc>().add(const LoadAllUsers());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final currentUser = authState.user;
        final permissionService = PermissionService();

        if (!permissionService.canCreateUser(currentUser)) {
          return _buildAccessDenied();
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          body: BlocConsumer<AdminBloc, AdminState>(
            listener: _handleBlocStateChange,
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<AdminBloc>().add(const RefreshUsers());
                },
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    _buildCompactAppBar(),
                    _buildCompactFilter(),
                    _buildTabBar(),
                    _buildUserList(state, currentUser),
                    _buildLoadMoreIndicator(state),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/admin/accounts/add'),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.person_add, color: Colors.white),
            label: const Text(
              'Thêm TK',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  // COMPACT APP BAR - No expandable space
  Widget _buildCompactAppBar() {
    return SliverAppBar(
      pinned: true,
      floating: false,
      backgroundColor: AppColors.primary,
      elevation: 2,
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      ),
      title: const Text(
        'Quản lý tài khoản',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () => context.read<AdminBloc>().add(const RefreshUsers()),
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  // COMPACT FILTER - Single row, minimal padding
  Widget _buildCompactFilter() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        color: Colors.white,
        child: Column(
          children: [
            // Search bar
            SizedBox(
              height: 40,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm...',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _clearAllFilters();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.grey300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.grey300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Filter chips in single row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        hint: const Text('Ngành', style: TextStyle(fontSize: 13)),
                        value: _selectedDepartmentFilter,
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text('Tất cả', style: TextStyle(fontSize: 13)),
                          ),
                          ...['Chiên', 'Ấu', 'Thiếu', 'Nghĩa'].map((dept) => 
                            DropdownMenuItem<String?>(
                              value: dept,
                              child: Text(dept, style: const TextStyle(fontSize: 13)),
                            )),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedDepartmentFilter = value);
                          _applyFilters();
                        },
                        isExpanded: true,
                        style: const TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Inactive filter chip
                FilterChip(
                  label: const Text('Bị khóa', style: TextStyle(fontSize: 12)),
                  selected: _showInactiveOnly,
                  onSelected: (value) {
                    setState(() => _showInactiveOnly = value);
                    _applyFilters();
                  },
                  selectedColor: AppColors.error.withOpacity(0.2),
                  checkmarkColor: AppColors.error,
                  side: BorderSide(
                    color: _showInactiveOnly ? AppColors.error : AppColors.grey300,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // SIMPLE TAB BAR - No counts
  Widget _buildTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            onTap: (_) {
              setState(() {});
              // Apply filters when tab changes
              _applyFilters();
            },
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 14),
            tabs: const [
              Tab(text: 'Tất cả'),
              Tab(text: 'BĐH'),
              Tab(text: 'GLV'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserList(AdminState state, UserModel currentUser) {
    final AdminState effectiveState =
        state is AdminRefreshing ? state.previousState : state;

    if (effectiveState is AdminLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is AdminError) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(state.message),
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

    if (effectiveState is! AdminLoaded) {
      return const SliverFillRemaining(
        child: Center(child: Text('Không có dữ liệu')),
      );
    }

    final filteredUsers = _getFilteredUsers(effectiveState.users);

    if (filteredUsers.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Không tìm thấy tài khoản nào'),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final user = filteredUsers[index];
            return _buildCompactUserCard(user, currentUser);
          },
          childCount: filteredUsers.length,
        ),
      ),
    );
  }

  Widget _buildLoadMoreIndicator(AdminState state) {
    final bool showIndicator = _isLoadingMore &&
        state is AdminLoaded &&
        state.hasMore;

    if (!showIndicator) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }

  // COMPACT USER CARD
  Widget _buildCompactUserCard(UserModel user, UserModel currentUser) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: _getRoleColor(user.role),
          child: Text(
            _getUserInitials(user),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        title: Text(
          user.displayName,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('@${user.username}', style: const TextStyle(fontSize: 13)),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.role.displayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: _getRoleColor(user.role),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(user.department?.displayName ?? '', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!user.isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Khóa',
                  style: TextStyle(color: Colors.red, fontSize: 10),
                ),
              ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (action) => _handleUserAction(action, user),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('Xem')),
                const PopupMenuItem(value: 'edit', child: Text('Sửa')),
                const PopupMenuItem(value: 'reset_password', child: Text('Reset MK')),
                PopupMenuItem(
                  value: user.isActive ? 'deactivate' : 'activate',
                  child: Text(user.isActive ? 'Khóa' : 'Mở khóa'),
                ),
                if (currentUser.id != user.id) ...[
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Xóa', style: TextStyle(color: Colors.red)),
                  ),
                  const PopupMenuItem(
                    value: 'delete_permanently',
                    child: Text('Xóa vĩnh viễn', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ],
            ),
          ],
        ),
        onTap: () => _showUserDetailsDialog(user),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text('Không có quyền truy cập'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBlocStateChange(BuildContext context, AdminState state) {
    if (state is AdminLoaded ||
        state is AdminError ||
        state is AdminRefreshing ||
        state is UserOperationSuccess) {
      _isLoadingMore = false;
    }

    if (state is AdminError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
        ),
      );
    }

    if (state is UserOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  List<UserModel> _getFilteredUsers(List<UserModel> users) {
    var filtered = users;

    // Apply department filter
    if (_selectedDepartmentFilter != null) {
      filtered = filtered
          .where((user) => user.department?.displayName == _selectedDepartmentFilter)
          .toList();
    }

    // Apply active/inactive filter
    if (_showInactiveOnly) {
      filtered = filtered.where((user) => !user.isActive).toList();
    }

    // Apply tab filter
    switch (_tabController.index) {
      case 1: // BĐH
        filtered = filtered.where((user) => user.role == UserRole.admin).toList();
        break;
      case 2: // GLV
        filtered = filtered.where((user) => user.role == UserRole.teacher).toList();
        break;
    }

    return filtered;
  }

  void _handleUserAction(String action, UserModel user) {
    switch (action) {
      case 'edit':
        context.push('/admin/accounts/add', extra: user);
        break;
      case 'view':
        _showUserDetailsDialog(user);
        break;
      case 'reset_password':
        _showResetPasswordDialog(user);
        break;
      case 'activate':
      case 'deactivate':
        _showToggleStatusDialog(user);
        break;
      case 'delete':
        _showDeleteUserDialog(user);
        break;
      case 'delete_permanently':
        _showPermanentDeleteDialog(user);
        break;
    }
  }

  void _showUserDetailsDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user),
    );
  }

  void _showResetPasswordDialog(UserModel user) {
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đặt lại mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Đặt lại mật khẩu cho tài khoản ${user.displayName}'),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final newPassword = passwordController.text.trim();
              if (newPassword.length >= 6) {
                Navigator.pop(context);
                context.read<AdminBloc>().add(
                  ResetUserPassword(userId: user.id, newPassword: newPassword),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mật khẩu phải có ít nhất 6 ký tự')),
                );
              }
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  void _showToggleStatusDialog(UserModel user) {
    final action = user.isActive ? 'vô hiệu hóa' : 'kích hoạt';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.capitalize()} tài khoản'),
        content: Text('Bạn có chắc muốn $action tài khoản ${user.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (user.isActive) {
                context.read<AdminBloc>().add(DeactivateUser(user.id));
              } else {
                context.read<AdminBloc>().add(ActivateUser(user.id));
              }
            },
            child: const Text('Đồng ý'),
          ),
        ],
      ),
    );
  }

  void _showDeleteUserDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc muốn xóa tài khoản ${user.displayName}?'),
            const SizedBox(height: 8),
            const Text(
              'Hành động này không thể hoàn tác!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminBloc>().add(DeleteUser(user.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showPermanentDeleteDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error, size: 28),
            const SizedBox(width: 8),
            const Text('Xóa vĩnh viễn'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bạn có chắc muốn xóa vĩnh viễn tài khoản ${user.displayName}?',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              
              // Cảnh báo về hậu quả
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ CẢNH BÁO: Hành động này không thể hoàn tác!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Khi xóa vĩnh viễn, tất cả dữ liệu sẽ bị xóa:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '• Thông tin cá nhân\n'
                      '• Lịch sử điểm danh\n'
                      '• Dữ liệu học tập\n'
                      '• Tất cả hoạt động liên quan',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _permanentlyDeleteUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa vĩnh viễn'),
          ),
        ],
      ),
    );
  }

  Future<void> _permanentlyDeleteUser(UserModel user) async {
    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await AuthService().deleteUserAccount(user.id);

    // Đóng dialog loading
    if (mounted) Navigator.pop(context);

    if (!mounted) return;

    if (success) {
      // Thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa vĩnh viễn tài khoản ${user.displayName}'),
          backgroundColor: AppColors.success,
        ),
      );
      
      // Refresh danh sách
      context.read<AdminBloc>().add(const RefreshUsers());
    } else {
      // Thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể xóa tài khoản. Vui lòng thử lại.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.department:
        return Colors.orange;
      case UserRole.teacher:
        return Colors.green;
    }
  }

  String _getUserInitials(UserModel user) {
    if (user.fullName != null && user.fullName!.isNotEmpty) {
      final parts = user.fullName!.split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return user.fullName![0].toUpperCase();
    }
    return user.username[0].toUpperCase();
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return tabBar;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
