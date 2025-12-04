// lib/features/admin/widgets/user_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/http_client.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class UserDetailsDialog extends StatelessWidget {
  final UserModel user;

  const UserDetailsDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = _resolveAvatarUrl(user.avatarUrl);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final shadowColor =
        Colors.black.withOpacity(isDark ? 0.35 : 0.12);
    final borderColor = theme.dividerColor;

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: theme.dividerColor,
                    backgroundImage:
                        avatarUrl != null ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl == null
                        ? Text(
                            _getUserInitials(user),
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${user.username}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(
                                theme.brightness == Brightness.dark ? 0.25 : 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.role.displayName,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DetailSection(
                      title: 'Thông tin cá nhân',
                      icon: Icons.person,
                      items: [
                        DetailItem('Tên Thánh', user.saintName ?? 'Chưa cập nhật'),
                        DetailItem('Họ và tên', user.fullName ?? 'Chưa cập nhật'),
                        DetailItem('Username', user.username),
                        DetailItem('Email', user.email ?? 'Chưa cập nhật'),
                        DetailItem(
                          'Ngày sinh',
                          user.birthDate != null
                              ? _formatDate(user.birthDate!)
                              : 'Chưa cập nhật',
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    DetailSection(
                      title: 'Thông tin liên hệ',
                      icon: Icons.contact_phone,
                      items: [
                        DetailItem('Số điện thoại', user.phoneNumber ?? 'Chưa cập nhật'),
                        DetailItem('Địa chỉ', user.address ?? 'Chưa cập nhật'),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    DetailSection(
                      title: 'Phân công công việc',
                      icon: Icons.work,
                      items: [
                        DetailItem('Vai trò', user.role.displayName),
                        DetailItem('Ngành', user.department?.displayName ?? 'Chưa phân công'),
                        if (user.className != null && user.className!.isNotEmpty)
                          DetailItem('Lớp phụ trách', user.className!),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    DetailSection(
                      title: 'Trạng thái tài khoản',
                      icon: Icons.info,
                      items: [
                        DetailItem(
                          'Tình trạng',
                          user.isActive ? 'Đang hoạt động' : 'Đã vô hiệu hóa',
                          textColor: user.isActive ? AppColors.success : AppColors.error,
                          icon: user.isActive ? Icons.check_circle : Icons.block,
                        ),
                        DetailItem('Ngày tạo', _formatDateTime(user.createdAt)),
                        DetailItem('Cập nhật cuối', _formatDateTime(user.updatedAt ?? user.createdAt)),
                        if (user.lastLogin != null)
                          DetailItem(
                            'Đăng nhập cuối',
                            _formatDateTime(user.lastLogin!),
                            icon: Icons.login,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<DetailItem> items;

  const DetailSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(
                    Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: 16,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                      ],
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${item.label}:',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: item.textColor ??
                                    Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.9),
                              ),
                        ),
                      ),
                    ],
                  ),
                  if (index < items.length - 1) ...[
                    const SizedBox(height: 12),
                    Divider(height: 1, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class DetailItem {
  final String label;
  final String value;
  final Color? textColor;
  final IconData? icon;

  const DetailItem(
    this.label, 
    this.value, {
    this.textColor,
    this.icon,
  });
}
