import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/auth_service.dart';
import 'package:thieu_nhi_app/core/services/http_client.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_event.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/profile/widgets/change_password_dialog.dart';
import 'package:thieu_nhi_app/features/profile/widgets/edit_profile_dialog.dart';
import 'package:thieu_nhi_app/features/profile/widgets/profile_header.dart';
import 'package:thieu_nhi_app/features/profile/widgets/profile_info_section.dart';
import 'package:thieu_nhi_app/features/profile/widgets/profile_menu_sections.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';
import 'package:thieu_nhi_app/theme/theme_cubit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'Tiếng Việt';
  String _deleteConfirmationText = '';
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingAvatar = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }

        final user = state.user;
        final avatarUrl = _resolveAvatarUrl(user.avatarUrl);

        return BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            final isDarkMode = themeMode == ThemeMode.dark;
            return Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    ProfileHeader(
                      user: user,
                      avatarUrl: avatarUrl,
                      isUploading: _isUploadingAvatar,
                      onAvatarTap:
                          _isUploadingAvatar ? null : _showAvatarOptions,
                    ),
                    const SizedBox(height: 20),
                    ProfileInfoSection(
                      user: user,
                      onEditProfile: () => _showEditProfileDialog(user),
                    ),
                    const SizedBox(height: 20),
                    ProfileMenuSections(
                      user: user,
                      isDarkMode: isDarkMode,
                      notificationsEnabled: _notificationsEnabled,
                      selectedLanguage: _selectedLanguage,
                      onNotificationsChanged: (value) =>
                          setState(() => _notificationsEnabled = value),
                      onDarkModeChanged: (value) =>
                          context.read<ThemeCubit>().toggleDarkMode(value),
                      onChangePassword: _showChangePasswordDialog,
                      onActivityHistory: _showActivityHistory,
                      onLanguageTap: _showLanguageDialog,
                      onAdminAccounts: () => context.push('/admin/accounts'),
                      onAdminPendingUsers: () => context.push('/admin/pending-users'),
                      onSystemSettings: () =>
                          _showComingSoonDialog('Cài đặt hệ thống'),
                      onGuide: () => _showComingSoonDialog('Hướng dẫn sử dụng'),
                      onSupport: _showSupportDialog,
                      onAbout: _showAboutDialog,
                      onDeactivate: () => _showDeactivateAccountDialog(user),
                      onDelete: _showDeleteAccountDialog,
                      onLogout: _showLogoutDialog,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).dividerColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: AppColors.primary),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      await _uploadAvatar(File(pickedFile.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể chọn ảnh: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _uploadAvatar(File file) async {
    if (!mounted) return;

    setState(() {
      _isUploadingAvatar = true;
    });

    final completer = Completer<UserModel>();
    context.read<AuthBloc>().add(
          AuthAvatarUploadRequested(
            avatarFile: file,
            completer: completer,
          ),
        );

    try {
      await completer.future;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật ảnh đại diện thành công'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi cập nhật ảnh: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  String? _resolveAvatarUrl(String? avatarUrl) {
    if (avatarUrl == null || avatarUrl.isEmpty) return null;
    if (avatarUrl.startsWith('http')) return avatarUrl;

    final base = HttpClient().apiBaseUrl;
    if (avatarUrl.startsWith('/')) {
      return '$base$avatarUrl';
    }
    return '$base/$avatarUrl';
  }

  void _showEditProfileDialog(UserModel user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditProfileDialog(user: user),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ChangePasswordDialog(),
    );
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
              Text('hqhuy340@gmail.com')
            ]),
            SizedBox(height: 8),
            Row(children: [
              Icon(Icons.phone, color: AppColors.primary),
              SizedBox(width: 8),
              Text('0399 071 340')
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
            Text('Phiên bản: 1.1.2'),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await AuthService().deactivateUser(userId);

    if (mounted) Navigator.pop(context);

    if (!mounted) return;

    if (success) {
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

  void _showDeleteAccountDialog() {
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
                      'Khi xóa tài khoản, tất cả dữ liệu sẽ bị xóa vĩnh viễn:',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
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
              const SizedBox(height: 16),
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
                    _deleteCurrentUserAccount();
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

  Future<void> _deleteCurrentUserAccount() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await AuthService().deleteCurrentUserAccount();

    if (mounted) Navigator.pop(context);

    if (!mounted) return;

    if (success) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tài khoản đã bị xóa'),
          content:
              const Text('Tài khoản và tất cả dữ liệu đã được xóa vĩnh viễn. '
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
}
