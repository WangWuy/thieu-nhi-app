// lib/features/admin/screens/pending_users_screen.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/pending_user_model.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/auth_service.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class PendingUsersScreen extends StatefulWidget {
  const PendingUsersScreen({super.key});

  @override
  State<PendingUsersScreen> createState() => _PendingUsersScreenState();
}

class _PendingUsersScreenState extends State<PendingUsersScreen> {
  final AuthService _authService = AuthService();
  List<PendingUserModel> _pendingUsers = [];
  bool _isLoading = true;
  String? _error;

  // Department mapping
  final Map<String, int> _departmentMapping = {
    'Chiên': 1,
    'Ấu': 2,
    'Thiếu': 3,
    'Nghĩa': 4,
  };

  @override
  void initState() {
    super.initState();
    _loadPendingUsers();
  }

  Future<void> _loadPendingUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _authService.getPendingUsers();
      setState(() {
        _pendingUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Không thể tải danh sách đăng ký: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _approveUser(PendingUserModel user) async {
    // Show department selection dialog
    final departmentId = await _showDepartmentSelectionDialog();
    if (departmentId == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final success =
          await _authService.approvePendingUser(user.id, departmentId);

      if (mounted) Navigator.pop(context); // Close loading

      if (!mounted) return;

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã phê duyệt tài khoản ${user.displayName}'),
            backgroundColor: AppColors.success,
          ),
        );

        // Reload list
        _loadPendingUsers();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể phê duyệt tài khoản. Vui lòng thử lại.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context); // Close loading

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<int?> _showDepartmentSelectionDialog() async {
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngành'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _departmentMapping.keys.map((deptName) {
            return ListTile(
              title: Text(deptName),
              onTap: () => Navigator.pop(context, _departmentMapping[deptName]),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(PendingUserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chi tiết đăng ký - ${user.displayName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Tên đăng nhập:', user.username),
              _buildDetailRow('Email:', user.email),
              _buildDetailRow('Họ và tên:', user.fullName),
              if (user.saintName != null)
                _buildDetailRow('Tên thánh:', user.saintName!),
              _buildDetailRow('Vai trò:', user.role.displayName),
              _buildDetailRow('Số điện thoại:', user.phoneNumber),
              _buildDetailRow('Địa chỉ:', user.address),
              _buildDetailRow('Ngày sinh:', _formatDate(user.birthDate)),
              _buildDetailRow('Tuổi:', '${user.age} tuổi'),
              _buildDetailRow('Ngày đăng ký:', _formatDate(user.createdAt)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _approveUser(user);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child:
                const Text('Phê duyệt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Đăng ký chờ phê duyệt',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadPendingUsers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: AppColors.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPendingUsers,
                        child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : _pendingUsers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline,
                              size: 64, color: AppColors.success),
                          SizedBox(height: 16),
                          Text(
                            'Không có đăng ký nào chờ phê duyệt',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16, color: AppColors.grey600),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPendingUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pendingUsers.length,
                        itemBuilder: (context, index) {
                          final user = _pendingUsers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    AppColors.primary.withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(
                                user.displayName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      '${user.role.displayName} • ${user.age} tuổi'),
                                  Text(
                                    'Đăng ký: ${_formatDate(user.createdAt)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey600,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.visibility),
                                    onPressed: () => _showUserDetails(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.check_circle,
                                        color: AppColors.success),
                                    onPressed: () => _approveUser(user),
                                  ),
                                ],
                              ),
                              onTap: () => _showUserDetails(user),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
