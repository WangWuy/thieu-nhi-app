// lib/features/profile/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/auth_service.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_event.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/profile/widgets/edit_profile_dialog.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'Tiếng Việt';
  String _deleteConfirmationText = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final user = state.user;
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(user),
                const SizedBox(height: 20),
                _buildProfileInfo(user),
                const SizedBox(height: 20),
                _buildMenuSections(user),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: _getRoleGradient(user.role)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.role.displayName,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(UserModel user) {
    final infoItems = [
      ('Tên Thánh', user.saintName ?? 'Chưa cập nhật', Icons.auto_awesome),
      ('Họ và tên', user.fullName ?? user.username, Icons.person),
      ('Email', user.email, Icons.email),
      ('Số điện thoại', user.phoneNumber ?? 'Chưa cập nhật', Icons.phone),
      ('Địa chỉ', user.address ?? 'Chưa cập nhật', Icons.location_on),
      ('Ngành', user.department, Icons.business),
      if (user.className != null) ('Lớp', user.className!, Icons.school),
      (
        'Ngày sinh',
        user.birthDate != null ? _formatDate(user.birthDate!) : 'Chưa cập nhật',
        Icons.cake
      ),
    ];

    return _buildCard(
      'Thông tin cá nhân',
      Icons.info_outline,
      Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thông tin cá nhân',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton.icon(
                onPressed: () => _showEditProfileDialog(user),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Chỉnh sửa'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...infoItems.map((item) => _buildInfoRow(item.$1, item.$2, item.$3)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.grey500),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: AppColors.grey500)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSections(UserModel user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildMenuSection('Tài khoản', [
            _MenuItem('Đổi mật khẩu', 'Cập nhật mật khẩu bảo mật', Icons.lock,
                onTap: _showChangePasswordDialog),
            _MenuItem('Hoạt động gần đây', 'Lịch sử đăng nhập và hoạt động',
                Icons.history,
                onTap: _showActivityHistory),
          ]),
          const SizedBox(height: 16),
          _buildMenuSection('Cài đặt', [
            _MenuItem('Thông báo', _notificationsEnabled ? 'Đã bật' : 'Đã tắt',
                Icons.notifications,
                trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (v) =>
                        setState(() => _notificationsEnabled = v))),
            _MenuItem('Giao diện tối', _darkModeEnabled ? 'Đã bật' : 'Đã tắt',
                Icons.dark_mode,
                trailing: Switch(
                    value: _darkModeEnabled,
                    onChanged: (v) => setState(() => _darkModeEnabled = v))),
            _MenuItem('Ngôn ngữ', _selectedLanguage, Icons.language,
                onTap: _showLanguageDialog),
          ]),
          if (user.role == UserRole.admin) ...[
            const SizedBox(height: 16),
            _buildMenuSection('Quản trị', [
              _MenuItem('Quản lý tài khoản',
                  'Tạo, sửa, xóa tài khoản người dùng', Icons.manage_accounts,
                  onTap: () => context.push('/admin/accounts')),
              _MenuItem('Đăng ký chờ phê duyệt',
                  'Xem và phê duyệt đăng ký tài khoản', Icons.pending_actions,
                  onTap: () => context.push('/admin/pending-users')),
              _MenuItem('Cài đặt hệ thống', 'Cấu hình ứng dụng',
                  Icons.settings_applications,
                  onTap: () => _showComingSoonDialog('Cài đặt hệ thống')),
            ]),
          ],
          const SizedBox(height: 16),
          _buildMenuSection('Hỗ trợ', [
            _MenuItem('Hướng dẫn sử dụng', 'Cách sử dụng ứng dụng',
                Icons.help_outline,
                onTap: () => _showComingSoonDialog('Hướng dẫn sử dụng')),
            _MenuItem('Liên hệ hỗ trợ', 'Gửi phản hồi hoặc báo lỗi',
                Icons.support_agent,
                onTap: _showSupportDialog),
            _MenuItem('Về ứng dụng', 'Phiên bản 1.0.0', Icons.info,
                onTap: _showAboutDialog),
          ]),
          const SizedBox(height: 16),
          _buildMenuSection('Khác', [
            _MenuItem('Ẩn tài khoản', 'Vô hiệu hóa và đăng xuất',
                Icons.visibility_off,
                iconColor: AppColors.error,
                onTap: () => _showDeactivateAccountDialog(user)),
            _MenuItem('Xóa tài khoản', 'Xóa vĩnh viễn tài khoản và dữ liệu',
                Icons.delete_forever,
                iconColor: AppColors.error,
                onTap: () => _showDeleteAccountDialog(user)),
            _MenuItem('Đăng xuất', 'Thoát khỏi ứng dụng', Icons.logout,
                iconColor: AppColors.error, onTap: _showLogoutDialog),
          ]),
        ],
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                if (index > 0) const Divider(color: AppColors.grey200, height: 1),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (item.iconColor ?? AppColors.primary)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon,
                        color: item.iconColor ?? AppColors.primary, size: 20),
                  ),
                  title: Text(item.title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  subtitle: Text(item.subtitle,
                      style: const TextStyle(fontSize: 14, color: AppColors.grey600)),
                  trailing: item.trailing ??
                      (item.onTap != null
                          ? const Icon(Icons.arrow_forward_ios,
                              size: 16, color: AppColors.grey400)
                          : null),
                  onTap: item.onTap,
                ),
              ],
            );
          }),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showEditProfileDialog(UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditProfileDialog(user: user),
    );
  }

  void _showChangePasswordDialog() {
    _showDialog('Đổi mật khẩu', 'Tính năng đổi mật khẩu đang được phát triển.');
  }

  void _showActivityHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hoạt động gần đây'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.login, color: AppColors.success),
              title: Text('Đăng nhập'),
              subtitle: Text('Hôm nay, 08:30'),
            ),
            ListTile(
              leading: Icon(Icons.visibility, color: AppColors.primary),
              title: Text('Xem danh sách thiếu nhi'),
              subtitle: Text('Hôm qua, 14:20'),
            ),
            ListTile(
              leading: Icon(Icons.edit, color: AppColors.warning),
              title: Text('Cập nhật điểm danh'),
              subtitle: Text('2 ngày trước, 10:15'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'))
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Tiếng Việt', 'English']
              .map((lang) => RadioListTile<String>(
                    title: Text(lang),
                    value: lang,
                    groupValue: _selectedLanguage,
                    onChanged: (value) {
                      setState(() => _selectedLanguage = value!);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text('Hủy'))
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Liên hệ hỗ trợ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có thể liên hệ hỗ trợ qua:'),
            SizedBox(height: 16),
            Row(children: [
              Icon(Icons.email, color: AppColors.primary),
              SizedBox(width: 8),
              Text('support@thieunh.com')
            ]),
            SizedBox(height: 8),
            Row(children: [
              Icon(Icons.phone, color: AppColors.primary),
              SizedBox(width: 8),
              Text('0123 456 789')
            ]),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'))
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Về ứng dụng'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ứng dụng Quản lý Thiếu Nhi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Phiên bản: 1.0.0'),
            Text('© 2025 Giáo xứ Thiên Ân'),
            SizedBox(height: 16),
            Text(
                'Ứng dụng giúp quản lý hoạt động thiếu nhi, điểm danh, và theo dõi tiến độ học tập.'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'))
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất không?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature) {
    _showDialog(feature, 'Tính năng "$feature" đang được phát triển.');
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'))
        ],
      ),
    );
  }

  void _showDeactivateAccountDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ẩn tài khoản'),
        content: const Text(
            'Tài khoản của bạn sẽ bị vô hiệu hóa và bạn sẽ bị đăng xuất. ' 
            'Bạn có chắc muốn tiếp tục?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deactivateCurrentUser(user.id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  Future<void> _deactivateCurrentUser(String userId) async {
    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await AuthService().deactivateUser(userId);

    // Đóng dialog loading
    if (mounted) Navigator.pop(context);

    if (!mounted) return;

    if (success) {
      // Thông báo và đăng xuất
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Đã ẩn tài khoản'),
          content: const Text(
              'Tài khoản đã được vô hiệu hóa. Bạn sẽ đăng xuất ngay bây giờ.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      context.read<AuthBloc>().add(AuthLogoutRequested());
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thao tác thất bại'),
          content:
              const Text('Không thể vô hiệu hóa tài khoản. Vui lòng thử lại.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  void _showDeleteAccountDialog(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: AppColors.error, size: 28),
            const SizedBox(width: 8),
            const Text('Xóa tài khoản'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bạn có chắc muốn xóa vĩnh viễn tài khoản này?',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '⚠️ CẢNH BÁO: Hành động này không thể hoàn tác!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Khi xóa tài khoản, tất cả dữ liệu sẽ bị xóa vĩnh viễn:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '• Thông tin cá nhân\n'
                      '• Lịch sử điểm danh\n'
                      '• Dữ liệu học tập\n'
                      '• Tất cả hoạt động liên quan',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Yêu cầu nhập tên để xác nhận
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Nhập "XÓA" để xác nhận',
                  hintText: 'XÓA',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    _deleteConfirmationText = value;
                  });
                },
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
            onPressed: _deleteConfirmationText == 'XÓA' 
                ? () {
                    Navigator.pop(context);
                    _deleteCurrentUserAccount(user.id);
                  }
                : null,
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

  Future<void> _deleteCurrentUserAccount(String userId) async {
    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await AuthService().deleteCurrentUserAccount();

    // Đóng dialog loading
    if (mounted) Navigator.pop(context);

    if (!mounted) return;

    if (success) {
      // Thông báo và đăng xuất
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tài khoản đã bị xóa'),
          content: const Text(
              'Tài khoản và tất cả dữ liệu đã được xóa vĩnh viễn. '
              'Bạn sẽ được đăng xuất ngay bây giờ.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      context.read<AuthBloc>().add(AuthLogoutRequested());
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xóa tài khoản thất bại'),
          content: const Text(
              'Không thể xóa tài khoản. Vui lòng thử lại hoặc liên hệ hỗ trợ.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

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
}

class _MenuItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  _MenuItem(this.title, this.subtitle, this.icon,
      {this.iconColor, this.trailing, this.onTap});
}
