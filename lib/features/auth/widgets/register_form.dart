// lib/features/auth/widgets/register_form.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'modern_text_field.dart';
import 'register_button.dart';

class RegisterForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final TextEditingController fullNameController;
  final TextEditingController saintNameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController birthDateController;
  final void Function({
    required UserRole role,
    DateTime? birthDate,
  }) onRegister;

  const RegisterForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.fullNameController,
    required this.saintNameController,
    required this.phoneController,
    required this.addressController,
    required this.birthDateController,
    required this.onRegister,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.teacher;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    widget.birthDateController.addListener(_updateBirthDateDisplay);
  }

  @override
  void dispose() {
    widget.birthDateController.removeListener(_updateBirthDateDisplay);
    super.dispose();
  }

  void _updateBirthDateDisplay() {
    setState(() {});
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFDC143C),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.birthDateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _handleRegister() {
    if (widget.formKey.currentState!.validate()) {
      widget.onRegister(
        role: _selectedRole,
        birthDate: _selectedDate,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFDC143C).withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 25,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: const Color(0xFFDC143C).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: widget.formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text(
                'Đăng ký tài khoản',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC143C),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng điền đầy đủ thông tin để tạo tài khoản',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Thông tin cơ bản
              _buildSectionTitle('Thông tin cơ bản'),
              const SizedBox(height: 16),

              ModernTextField(
                controller: widget.usernameController,
                label: 'Tên đăng nhập *',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên đăng nhập';
                  }
                  if (value.length < 3) {
                    return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                  }
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                    return 'Tên đăng nhập chỉ được chứa chữ cái, số và dấu gạch dưới';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              ModernTextField(
                controller: widget.emailController,
                label: 'Email *',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              ModernTextField(
                controller: widget.passwordController,
                label: 'Mật khẩu *',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF8B4513),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  if (value.length < 8) {
                    return 'Mật khẩu phải có ít nhất 8 ký tự';
                  }
                  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)')
                      .hasMatch(value)) {
                    return 'Mật khẩu phải chứa ít nhất 1 chữ hoa, 1 chữ thường và 1 số';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              ModernTextField(
                controller: widget.confirmPasswordController,
                label: 'Xác nhận mật khẩu *',
                icon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: const Color(0xFF8B4513),
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng xác nhận mật khẩu';
                  }
                  if (value != widget.passwordController.text) {
                    return 'Mật khẩu xác nhận không khớp';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Thông tin cá nhân
              _buildSectionTitle('Thông tin cá nhân'),
              const SizedBox(height: 16),

              ModernTextField(
                controller: widget.fullNameController,
                label: 'Họ và tên *',
                icon: Icons.badge_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  if (value.length < 2) {
                    return 'Họ và tên phải có ít nhất 2 ký tự';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              ModernTextField(
                controller: widget.saintNameController,
                label: 'Tên thánh',
                icon: Icons.church,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 2) {
                    return 'Tên thánh phải có ít nhất 2 ký tự';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: ModernTextField(
                    controller: widget.birthDateController,
                    label: 'Ngày sinh',
                    icon: Icons.calendar_today_outlined,
                    validator: (value) {
                      // Ngày sinh là tùy chọn; chỉ validate nếu người dùng đã chọn
                      if ((value != null && value.isNotEmpty) || _selectedDate != null) {
                        if (_selectedDate == null) {
                          return 'Vui lòng chọn ngày sinh hợp lệ';
                        }
                        final now = DateTime.now();
                        int age = now.year - _selectedDate!.year;
                        if (now.month < _selectedDate!.month ||
                            (now.month == _selectedDate!.month && now.day < _selectedDate!.day)) {
                          age--;
                        }
                        if (age < 16) {
                          return 'Bạn phải ít nhất 16 tuổi để đăng ký';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              ModernTextField(
                controller: widget.phoneController,
                label: 'Số điện thoại *',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (!RegExp(r'^[0-9]{10,11}$')
                      .hasMatch(value.replaceAll(' ', ''))) {
                    return 'Số điện thoại phải có 10-11 chữ số';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              ModernTextField(
                controller: widget.addressController,
                label: 'Địa chỉ *',
                icon: Icons.location_on_outlined,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  if (value.length < 10) {
                    return 'Địa chỉ phải có ít nhất 10 ký tự';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Vai trò
              _buildSectionTitle('Vai trò trong giáo xứ'),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFFAF7F0),
                  border: Border.all(
                    color: const Color(0xFFDC143C).withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: DropdownButtonFormField<UserRole>(
                  initialValue: _selectedRole,
                  decoration: InputDecoration(
                    labelText: 'Vai trò *',
                    labelStyle: TextStyle(
                      color: const Color(0xFF8B4513).withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.all(10),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFDC143C),
                            Color(0xFFB22222),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.work_outline,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFDC143C),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFE53E3E),
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF2D3748),
                    fontWeight: FontWeight.w500,
                  ),
                  dropdownColor: Colors.white,
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(
                        role.displayName,
                        style: const TextStyle(
                          color: Color(0xFF8B4513),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Điều khoản
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFDC143C).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Điều khoản và chính sách:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFDC143C),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Tài khoản được tạo để quản lý hoạt động giáo dục trong giáo xứ\n'
                      '• Thông tin cá nhân được bảo mật và chỉ sử dụng cho mục đích giáo dục\n'
                      '• Bạn có thể liên hệ Ban Điều Hành để được hỗ trợ\n'
                      '• Việc đăng ký cần được Ban Điều Hành phê duyệt trước khi sử dụng',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              RegisterButton(onPressed: _handleRegister),

              CupertinoButton(
                onPressed: () {
                  context.go('/login');
                },
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                child: CupertinoButton(
                    child: const Text(
                      'Quay lại Đăng nhập',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      context.go('/login');
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFFDC143C),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4513),
          ),
        ),
      ],
    );
  }
}
