// lib/features/students/screens/edit_student_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/widgets/custom_button.dart';
import 'package:thieu_nhi_app/core/widgets/custom_text_field.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_bloc.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_event.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_state.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class EditStudentScreen extends StatefulWidget {
  final StudentModel student;

  const EditStudentScreen({
    super.key,
    required this.student,
  });

  @override
  State<EditStudentScreen> createState() => _EditStudentScreenState();
}

class _EditStudentScreenState extends State<EditStudentScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Controllers - Pre-fill với dữ liệu thiếu nhi hiện tại
  late final TextEditingController _holyNameController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _parentPhone1Controller;
  late final TextEditingController _parentPhone2Controller;
  late final TextEditingController _addressController;
  late final TextEditingController _noteController;
  DateTime? _selectedBirthDate;
  bool _isLoading = false;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
  }

  void _initializeControllers() {
    // Parse tên đầy đủ thành tên thánh và họ tên
    final fullName = widget.student.name;
    final nameParts = fullName.split(' ');
    final holyName = nameParts.isNotEmpty ? nameParts.first : '';
    final remainingName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

    _holyNameController = TextEditingController(text: holyName);
    _fullNameController = TextEditingController(text: remainingName);
    _phoneController = TextEditingController(text: widget.student.phone);
    _parentPhone1Controller =
        TextEditingController(text: widget.student.parentPhone);
    _parentPhone2Controller =
        TextEditingController(); // Có thể thêm field mới này vào model
    _addressController = TextEditingController(text: widget.student.address);
    _noteController = TextEditingController(text: widget.student.note);

    _selectedBirthDate = widget.student.birthDate;
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
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BlocListener<StudentsBloc, StudentsState>(
        listener: (context, state) {
          if (state is StudentOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            // Quay về trang trước sau khi update thành công
            context.pop();
          } else if (state is StudentsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
            setState(() {
              _isLoading = false;
            });
          }
        },
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              title: const Text(
                'Chỉnh sửa thiếu nhi',
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
              actions: [
                IconButton(
                  onPressed: _showDeleteConfirmation,
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
              ],
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
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      color: AppColors.grey50,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildStudentInfoCard(),
            const SizedBox(height: 24),
            _buildPersonalInfoSection(),
            const SizedBox(height: 24),
            _buildContactInfoSection(),
            const SizedBox(height: 24),
            _buildNoteSection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
            const SizedBox(height: 32),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
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
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.primaryGradient,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.student.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${widget.student.id}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                    ),
                    Text(
                      '${widget.student.className} - ${widget.student.department}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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

  Widget _buildNoteSection() {
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
          _buildSectionHeader('Ghi chú', Icons.note_alt),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _noteController,
            label: 'Ghi chú',
            icon: Icons.note,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
            validator: null, // Optional field
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      onPressed: _isLoading ? null : _submitForm,
      text: 'Cập nhật thông tin',
      isLoading: _isLoading,
      icon: Icons.save,
      gradient: LinearGradient(
        colors: _getDepartmentGradient(widget.student.department),
      ),
    );
  }

  // Event handlers
  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ??
          DateTime.now().subtract(const Duration(days: 3650)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _getDepartmentColor(widget.student.department),
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
      // Tạo updated student model
      final updatedStudent = widget.student.copyWith(
        name:
            '${_holyNameController.text.trim()} ${_fullNameController.text.trim()}',
        phone: _phoneController.text.trim(),
        parentPhone: _parentPhone1Controller.text.trim(),
        address: _addressController.text.trim(),
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim() 
            : null,
        birthDate: _selectedBirthDate!,
        updatedAt: DateTime.now(),
      );

      // Dispatch update event
      context.read<StudentsBloc>().add(UpdateStudent(updatedStudent));
    } catch (e) {
      _showErrorSnackBar('Lỗi cập nhật thiếu nhi: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Xác nhận xóa',
          style: TextStyle(
            color: AppColors.error,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Bạn có chắc muốn xóa thiếu nhi "${widget.student.name}"?\n\nHành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteStudent();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _deleteStudent() {
    context.read<StudentsBloc>().add(DeleteStudent(widget.student.id));
    context.pop(); // Quay về trang trước
  }

  // Helper methods
  bool _isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[^\d]'), ''));
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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
