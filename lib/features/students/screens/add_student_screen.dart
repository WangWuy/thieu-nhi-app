// lib/features/students/screens/add_student_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/widgets/custom_button.dart';
import 'package:thieu_nhi_app/core/widgets/custom_text_field.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AddStudentScreen extends StatefulWidget {
  final String classId;
  final String className;
  final String department;

  const AddStudentScreen({
    super.key,
    required this.classId,
    required this.className,
    required this.department,
  });

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _holyNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _parentPhone1Controller = TextEditingController();
  final _parentPhone2Controller = TextEditingController();
  final _addressController = TextEditingController();

  DateTime? _selectedBirthDate;
  bool _isLoading = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _holyNameController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _parentPhone1Controller.dispose();
    _parentPhone2Controller.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          // AppBar matching student list screen design
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            title: const Text(
              'Thêm thiếu nhi mới',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
            ),
          ),

          // Scrollable form content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Remove the unused _buildSliverAppBar method since we're not using CustomScrollView anymore

  Widget _buildForm() {
    return Container(
      color: AppColors.grey50,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildPersonalInfoSection(),
            const SizedBox(height: 24),
            _buildContactInfoSection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 32), // Extra bottom padding
            // Add extra padding for keyboard space
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Thông tin cá nhân', Icons.person),
          const SizedBox(height: 20),

          // Tên Thánh
          CustomTextField(
            controller: _holyNameController,
            label: 'Tên Thánh *',
            icon: Icons.church,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập tên thánh';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Họ và tên
          CustomTextField(
            controller: _fullNameController,
            label: 'Họ và tên *',
            icon: Icons.badge,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập họ và tên';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Ngày sinh
          _buildBirthDateField(),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Thông tin liên hệ', Icons.contact_phone),
          const SizedBox(height: 20),

          // SĐT thiếu nhi
          CustomTextField(
            controller: _phoneController,
            label: 'Số điện thoại thiếu nhi',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isNotEmpty == true && !_isValidPhoneNumber(value!)) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // SĐT phụ huynh 1
          CustomTextField(
            controller: _parentPhone1Controller,
            label: 'SĐT Phụ huynh 1 *',
            icon: Icons.contact_phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập SĐT phụ huynh';
              }
              if (!_isValidPhoneNumber(value!)) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // SĐT phụ huynh 2
          CustomTextField(
            controller: _parentPhone2Controller,
            label: 'SĐT Phụ huynh 2',
            icon: Icons.contact_phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isNotEmpty == true && !_isValidPhoneNumber(value!)) {
                return 'Số điện thoại không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Địa chỉ
          CustomTextField(
            controller: _addressController,
            label: 'Địa chỉ nhà *',
            icon: Icons.location_on,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Vui lòng nhập địa chỉ';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBirthDateField() {
    return GestureDetector(
      onTap: _selectBirthDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(12),
          color: AppColors.grey50,
        ),
        child: Row(
          children: [
            const Icon(Icons.cake, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ngày sinh *',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedBirthDate != null
                        ? _formatDate(_selectedBirthDate!)
                        : 'Chọn ngày sinh',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _selectedBirthDate != null
                          ? AppColors.grey800
                          : AppColors.grey500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_today,
              color: AppColors.grey400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.grey800,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      onPressed: _isLoading ? null : _submitForm,
      text: 'Thêm thiếu nhi',
      isLoading: _isLoading,
      icon: Icons.person_add,
      gradient: LinearGradient(
        colors: _getDepartmentGradient(widget.department),
      ),
    );
  }

  // Event handlers
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.now().subtract(const Duration(days: 3650)), // 10 years ago
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _getDepartmentColor(widget.department),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      _showErrorSnackBar('Vui lòng chọn ngày sinh');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create student model
      final student = StudentModel(
        id: 'student_${DateTime.now().millisecondsSinceEpoch}',
        qrId: 'student_${DateTime.now().millisecondsSinceEpoch}', // Use same ID for QR
        name:
            '${_holyNameController.text.trim()} ${_fullNameController.text.trim()}',
        phone: _phoneController.text.trim(),
        parentPhone: _parentPhone1Controller.text.trim(),
        address: _addressController.text.trim(),
        birthDate: _selectedBirthDate!,
        classId: widget.classId,
        className: widget.className,
        department: widget.department,
        attendance: const {}, // Empty attendance initially
        grades: const [], // Empty grades initially
        photoUrl: null,
        avatarUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: Save to database
      // await DatabaseService().addStudent(student);

      // Show success and go back
      _showSuccessSnackBar('Đã thêm thiếu nhi "${student.name}"');

      // Delay to show snackbar then pop
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        context.pop();
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi thêm thiếu nhi: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper methods
  bool _isValidPhoneNumber(String phone) {
    // Basic Vietnamese phone number validation
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d]'), ''));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    switch (department) {
      case 'Chiên':
        return AppColors.chienColor;
      case 'Âu':
        return AppColors.auColor;
      case 'Thiếu':
        return AppColors.thieuColor;
      case 'Nghĩa':
        return AppColors.nghiaColor;
      default:
        return AppColors.primary;
    }
  }

  List<Color> _getDepartmentGradient(String department) {
    switch (department) {
      case 'Chiên':
        return [AppColors.chienColor, const Color(0xFFFC8181)];
      case 'Âu':
        return [AppColors.auColor, const Color(0xFF63B3ED)];
      case 'Thiếu':
        return [AppColors.thieuColor, const Color(0xFF68D391)];
      case 'Nghĩa':
        return [AppColors.nghiaColor, const Color(0xFFB794F6)];
      default:
        return AppColors.primaryGradient;
    }
  }
}
