import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ProfileMenuSections extends StatelessWidget {
  final UserModel user;
  final bool isDarkMode;
  final bool notificationsEnabled;
  final String selectedLanguage;
  final ValueChanged<bool> onNotificationsChanged;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onChangePassword;
  final VoidCallback onActivityHistory;
  final VoidCallback onLanguageTap;
  final VoidCallback onAdminAccounts;
  final VoidCallback onAdminPendingUsers;
  final VoidCallback onSystemSettings;
  final VoidCallback onGuide;
  final VoidCallback onSupport;
  final VoidCallback onAbout;
  final VoidCallback onDeactivate;
  final VoidCallback onDelete;
  final VoidCallback onLogout;

  const ProfileMenuSections({
    super.key,
    required this.user,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.selectedLanguage,
    required this.onNotificationsChanged,
    required this.onDarkModeChanged,
    required this.onChangePassword,
    required this.onActivityHistory,
    required this.onLanguageTap,
    required this.onAdminAccounts,
    required this.onAdminPendingUsers,
    required this.onSystemSettings,
    required this.onGuide,
    required this.onSupport,
    required this.onAbout,
    required this.onDeactivate,
    required this.onDelete,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildMenuSection('Tài khoản', [
            _MenuItem('Đổi mật khẩu', 'Cập nhật mật khẩu bảo mật', Icons.lock,
                onTap: onChangePassword),
            _MenuItem('Hoạt động gần đây', 'Lịch sử đăng nhập và hoạt động',
                Icons.history,
                onTap: onActivityHistory),
          ], context),
          const SizedBox(height: 16),
          _buildMenuSection('Cài đặt', [
            _MenuItem(
              'Thông báo',
              notificationsEnabled ? 'Đã bật' : 'Đã tắt',
              Icons.notifications,
              trailing: Switch(
                value: notificationsEnabled,
                onChanged: onNotificationsChanged,
              ),
            ),
            _MenuItem(
              'Giao diện tối',
              isDarkMode ? 'Đã bật' : 'Đã tắt',
              Icons.dark_mode,
              trailing: Switch(
                value: isDarkMode,
                onChanged: onDarkModeChanged,
              ),
            ),
            _MenuItem(
                'Ngôn ngữ', selectedLanguage, Icons.language,
                onTap: onLanguageTap),
          ], context),
          if (user.role == UserRole.admin) ...[
            const SizedBox(height: 16),
            _buildMenuSection('Quản trị', [
              _MenuItem('Quản lý tài khoản',
                  'Tạo, sửa, xóa tài khoản người dùng', Icons.manage_accounts,
                  onTap: onAdminAccounts),
              _MenuItem('Đăng ký chờ phê duyệt',
                  'Xem và phê duyệt đăng ký tài khoản', Icons.pending_actions,
                  onTap: onAdminPendingUsers),
              _MenuItem('Cài đặt hệ thống', 'Cấu hình ứng dụng',
                  Icons.settings_applications,
                  onTap: onSystemSettings),
            ], context),
          ],
          const SizedBox(height: 16),
          _buildMenuSection('Hỗ trợ', [
            _MenuItem('Hướng dẫn sử dụng', 'Cách sử dụng ứng dụng',
                Icons.help_outline,
                onTap: onGuide),
            _MenuItem('Liên hệ hỗ trợ', 'Gửi phản hồi hoặc báo lỗi',
                Icons.support_agent,
                onTap: onSupport),
            _MenuItem('Về ứng dụng', 'Phiên bản 1.1.2', Icons.info,
                onTap: onAbout),
          ], context),
          const SizedBox(height: 16),
          _buildMenuSection('Khác', [
            _MenuItem('Ẩn tài khoản', 'Vô hiệu hóa và đăng xuất',
                Icons.visibility_off,
                iconColor: AppColors.error,
                onTap: onDeactivate),
            _MenuItem('Xóa tài khoản', 'Xóa vĩnh viễn tài khoản và dữ liệu',
                Icons.delete_forever,
                iconColor: AppColors.error,
                onTap: onDelete),
            _MenuItem('Đăng xuất', 'Thoát khỏi ứng dụng', Icons.logout,
                iconColor: AppColors.error, onTap: onLogout),
          ], context),
        ],
      ),
    );
  }

  Widget _buildMenuSection(
      String title, List<_MenuItem> items, BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = _borderColor(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: _surfaceShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final iconColor = item.iconColor ?? theme.colorScheme.primary;
            return Column(
              children: [
                if (index > 0)
                  Divider(color: borderColor, height: 1),
                ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _iconContainerColor(context, iconColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item.icon, color: iconColor, size: 20),
                  ),
                  title: Text(
                    item.title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    item.subtitle,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: _mutedTextColor(context)),
                  ),
                  trailing: item.trailing ??
                      (item.onTap != null
                          ? Icon(Icons.arrow_forward_ios,
                              size: 16, color: _mutedTextColor(context))
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

  Color _mutedTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

  Color _borderColor(BuildContext context) {
    final theme = Theme.of(context);
    return theme.dividerColor
        .withOpacity(theme.brightness == Brightness.dark ? 0.6 : 1);
  }

  List<BoxShadow> _surfaceShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color:
            isDark ? Colors.black.withOpacity(0.35) : Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      )
    ];
  }

  Color _iconContainerColor(BuildContext context, Color base) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return base.withOpacity(isDark ? 0.18 : 0.1);
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
