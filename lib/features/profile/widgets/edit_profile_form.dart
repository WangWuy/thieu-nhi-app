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
        _buildSectionTitle('Thông tin cơ bản'),
        const SizedBox(height: 16),
        _buildTextField(
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
        _buildSectionTitle('Thông tin liên hệ'),
        const SizedBox(height: 16),
        _buildTextField(
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
        _buildReadOnlyInfo(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.grey800,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.grey400,
              fontSize: 14,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.grey300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error, width: 2),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBirthDateField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ngày sinh',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectBirthDate(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.grey300),
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
                  child: Icon(
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
                          ? AppColors.grey800
                          : AppColors.grey400,
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppColors.grey400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
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
              const Text(
                'Thông tin không thể thay đổi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildReadOnlyRow('Email', user.email, Icons.email),
          _buildReadOnlyRow(
              'Tên đăng nhập', user.username, Icons.account_circle),
          _buildReadOnlyRow('Chức vụ', user.role.displayName, Icons.work),
          _buildReadOnlyRow(
              'Ngành', 'Ngành ${user.department}', Icons.business),
          if (user.className != null)
            _buildReadOnlyRow('Lớp', user.className!, Icons.school,
                isLast: true),
        ],
      ),
    );
  }

  Widget _buildReadOnlyRow(String label, String value, IconData icon,
      {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppColors.grey500,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.grey800,
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
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.grey800,
            ),
            dialogBackgroundColor: Colors.white,
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
