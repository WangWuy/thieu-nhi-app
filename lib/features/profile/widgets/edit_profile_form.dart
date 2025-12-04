// lib/features/profile/widgets/edit_profile_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class EditProfileForm extends StatelessWidget {
  final TextEditingController holyNameController;
  final TextEditingController fullNameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final DateTime? selectedBirthDate;
  final Function(DateTime?) onBirthDateChanged;
  final UserModel user;

  const EditProfileForm({
    super.key,
    required this.holyNameController,
    required this.fullNameController,
    required this.phoneController,
    required this.addressController,
    required this.selectedBirthDate,
    required this.onBirthDateChanged,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Thông tin cơ bản'),
        const SizedBox(height: 16),
        _buildTextField(
          context: context,
          controller: holyNameController,
          label: 'Tên Thánh',
          icon: Icons.auto_awesome,
          hint: 'Ví dụ: Maria, Phêrô, Giuse...',
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 2) {
              return 'Tên Thánh phải có ít nhất 2 ký tự';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context: context,
          controller: fullNameController,
          label: 'Họ và tên đầy đủ',
          icon: Icons.person,
          hint: 'Ví dụ: Nguyễn Văn An',
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (value.length < 2) {
                return 'Họ tên phải có ít nhất 2 ký tự';
              }
              if (!RegExp(r'^[a-zA-ZÀ-ỹ\s]+$').hasMatch(value)) {
                return 'Họ tên chỉ được chứa chữ cái và khoảng trắng';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildBirthDateField(context),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Thông tin liên hệ'),
        const SizedBox(height: 16),
        _buildTextField(
          context: context,
          controller: phoneController,
          label: 'Số điện thoại',
          icon: Icons.phone,
          hint: 'Ví dụ: 0123456789',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!RegExp(r'^0\d{9,10}$').hasMatch(value)) {
                return 'Số điện thoại không hợp lệ (10-11 số, bắt đầu bằng 0)';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          context: context,
          controller: addressController,
          label: 'Địa chỉ nhà',
          icon: Icons.location_on,
          hint: 'Ví dụ: 123 Nguyễn Văn Linh, Q.7, TP.HCM',
          maxLines: 2,
          validator: (value) {
            if (value != null && value.isNotEmpty && value.length < 10) {
              return 'Địa chỉ quá ngắn, vui lòng nhập đầy đủ hơn';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _buildReadOnlyInfo(context),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final baseDecoration =
        const InputDecoration().applyDefaults(theme.inputDecorationTheme);
    final muted = theme.colorScheme.onSurface.withOpacity(0.7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: muted,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          decoration: baseDecoration.copyWith(
            hintText: hint,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                icon,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            prefixIconConstraints:
                const BoxConstraints(minHeight: 0, minWidth: 0),
            filled: baseDecoration.filled ?? true,
            fillColor: baseDecoration.fillColor ??
                theme.inputDecorationTheme.fillColor,
            contentPadding: baseDecoration.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthDateField(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.dividerColor;
    final muted = theme.colorScheme.onSurface.withOpacity(0.7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ngày sinh',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: muted,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectBirthDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.cake,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                Expanded(
                  child: Text(
                    selectedBirthDate != null
                        ? _formatDate(selectedBirthDate!)
                        : 'Chọn ngày sinh',
                    style: TextStyle(
                      fontSize: 16,
                      color: selectedBirthDate != null
                          ? theme.colorScheme.onSurface
                          : muted,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: muted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyInfo(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Thông tin không thể thay đổi',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReadOnlyRow(context, 'Email', user.email ?? '', Icons.email),
          _buildReadOnlyRow(
              context, 'Tên đăng nhập', user.username, Icons.account_circle),
          _buildReadOnlyRow(context, 'Chức vụ', user.role.displayName, Icons.work),
          _buildReadOnlyRow(
              context, 'Ngành', 'Ngành ${user.department}', Icons.business),
          if (user.className != null)
            _buildReadOnlyRow(context, 'Lớp', user.className!, Icons.school,
                isLast: true),
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(
      BuildContext context, String label, String value, IconData icon,
      {bool isLast = false}) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.7);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: muted,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 7300)), // ~20 tuổi
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('vi', 'VN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.grey800,
            ), dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedBirthDate) {
      onBirthDateChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
