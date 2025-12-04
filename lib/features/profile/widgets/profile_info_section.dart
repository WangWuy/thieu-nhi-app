import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';

class ProfileInfoSection extends StatelessWidget {
  final UserModel user;
  final VoidCallback onEditProfile;

  const ProfileInfoSection({
    super.key,
    required this.user,
    required this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[
      _buildPersonalInfoCard(context, user),
    ];

    final assignmentCard = _buildAssignmentCard(context, user);
    if (assignmentCard != null) {
      widgets..add(const SizedBox(height: 16))..add(assignmentCard);
    }

    final permissionsCard = _buildPermissionsCard(context, user);
    if (permissionsCard != null) {
      widgets..add(const SizedBox(height: 16))..add(permissionsCard);
    }

    return Column(children: widgets);
  }

  Widget _buildPersonalInfoCard(BuildContext context, UserModel user) {
    final infoItems = <_ProfileInfoItem>[
      _ProfileInfoItem(
          'Tên Thánh', _formatNullableText(user.saintName), Icons.auto_awesome),
      _ProfileInfoItem(
        'Họ và tên',
        _formatNullableText(user.fullName ?? user.username),
        Icons.person,
      ),
      _ProfileInfoItem(
          'Email', _formatNullableText(user.email), Icons.email),
      _ProfileInfoItem('Số điện thoại', _formatNullableText(user.phoneNumber),
          Icons.phone),
      _ProfileInfoItem(
          'Địa chỉ', _formatNullableText(user.address), Icons.location_on),
      _ProfileInfoItem('Ngành', _formatDepartment(user), Icons.business),
      if (_formatClassSummary(user) != null)
        _ProfileInfoItem(
            'Lớp phụ trách', _formatClassSummary(user)!, Icons.school),
      _ProfileInfoItem(
        'Ngày sinh',
        user.birthDate != null
            ? _formatDate(user.birthDate!)
            : 'Chưa cập nhật',
        Icons.cake,
      ),
    ];

    return _buildCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thông tin cá nhân',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: onEditProfile,
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('Chỉnh sửa'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...infoItems.map(
            (item) => _buildInfoRow(
              context,
              item.label,
              item.value,
              item.icon,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _mutedTextColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _mutedTextColor(context),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildAssignmentCard(BuildContext context, UserModel user) {
    final rows = <Widget>[];

    final department = user.department;
    if (department != null) {
      rows.add(_buildInfoRow(
        context,
        'Ngành phụ trách',
        '${department.displayName} (${department.name})',
        Icons.apartment,
      ));
    } else if (user.departmentId != null) {
      rows.add(_buildInfoRow(
        context,
        'Ngành phụ trách',
        'ID #${user.departmentId}',
        Icons.apartment,
      ));
    }

    if (user.className != null) {
      final count = user.classStudentCount;
      final subtitle =
          count != null ? '${user.className} • $count thiếu nhi' : user.className!;
      rows.add(_buildInfoRow(
        context,
        'Lớp phụ trách',
        subtitle,
        Icons.class_,
      ));
    }

    if (user.classId != null) {
      rows.add(_buildInfoRow(
        context,
        'Mã lớp',
        '#${user.classId}',
        Icons.confirmation_number,
      ));
    }

    if (rows.isEmpty) return null;

    return _buildCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Phân công giảng dạy',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...rows,
        ],
      ),
    );
  }

  Widget? _buildPermissionsCard(BuildContext context, UserModel user) {
    if (user.permissions.isEmpty) return null;

    return _buildCard(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quyền truy cập',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: user.permissions
                .map(
                  (permission) => Chip(
                    label: Text(
                      _formatPermission(permission),
                      style: Theme.of(context).chipTheme.labelStyle,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Widget child) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor(context)),
        boxShadow: _surfaceShadow(context),
      ),
      child: child,
    );
  }

  String _formatNullableText(String? value) {
    if (value == null) return 'Chưa cập nhật';
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Chưa cập nhật' : trimmed;
  }

  String _formatDepartment(UserModel user) {
    final department = user.department;
    if (department != null) {
      final display = department.displayName.isNotEmpty
          ? department.displayName
          : department.name;
      final code = department.name.isNotEmpty ? ' (${department.name})' : '';
      final result = '$display$code'.trim();
      return result.isEmpty ? 'Chưa cập nhật' : result;
    }
    if (user.departmentId != null) {
      return 'ID #${user.departmentId}';
    }
    return 'Chưa cập nhật';
  }

  String? _formatClassSummary(UserModel user) {
    final className = user.className;
    if (className == null || className.isEmpty) return null;
    final count = user.classStudentCount;
    final suffix = count != null ? ' • $count thiếu nhi' : '';
    return '$className$suffix';
  }

  String _formatPermission(String permission) {
    switch (permission) {
      case 'read:class':
        return 'Xem lớp học';
      case 'write:class':
        return 'Cập nhật lớp học';
      case 'manage:students':
        return 'Quản lý thiếu nhi';
      case 'manage:attendance':
        return 'Quản lý điểm danh';
      default:
        return permission.replaceAll(':', ' → ').replaceAll('_', ' ');
    }
  }

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

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
}

class _ProfileInfoItem {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileInfoItem(this.label, this.value, this.icon);
}
