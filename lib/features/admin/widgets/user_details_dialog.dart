// lib/features/admin/widgets/user_details_dialog.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class UserDetailsDialog extends StatelessWidget {
  final UserModel user;

  const UserDetailsDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      _getUserInitials(user),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '@${user.username}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.role.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
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
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
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
                color: AppColors.primary.withOpacity(0.1),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
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
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                      ],
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${item.label}:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: item.textColor ?? Colors.grey[800],
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