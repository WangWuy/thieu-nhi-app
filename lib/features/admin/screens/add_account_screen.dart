import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thieu_nhi_app/core/models/class_model.dart';
import 'package:thieu_nhi_app/core/models/department_model.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/class_service.dart';
import 'package:thieu_nhi_app/core/services/department_service.dart';
import 'package:thieu_nhi_app/core/services/http_client.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_bloc.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_event.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_state.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';

class AddAccountScreen extends StatefulWidget {
  final UserModel? accountData;

  const AddAccountScreen({super.key, this.accountData});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _controllers = <String, TextEditingController>{};
  late final DepartmentService _departmentService;
  late final ClassService _classService;
  final ImagePicker _imagePicker = ImagePicker();

  UserRole _selectedRole = UserRole.teacher;
  String _selectedDepartment = 'CHIEN';
  String? _selectedClass;
  DateTime _selectedBirthDate =
      DateTime.now().subtract(const Duration(days: 7300));
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  File? _avatarFile;
  String? _currentAvatarUrl;

  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _classes = [];
  bool _loadingClasses = false;

  static const Map<int, String> _departmentIdToKey = {
    1: 'CHIEN',
    2: 'AU',
    3: 'THIEU',
    4: 'NGHIA',
  };

  static const Map<String, String> _departmentKeyToDisplay = {
    'CHIEN': 'Chiên',
    'AU': 'Âu',
    'THIEU': 'Thiếu',
    'NGHIA': 'Nghĩa',
  };

  @override
  void initState() {
    super.initState();
    _departmentService = DepartmentService();
    _classService = ClassService();
    _initControllers();
    _initializeForm();
    _loadDepartments();
  }

  void _initControllers() {
    for (final field in [
      'saintName',
      'fullName',
      'username',
      'email',
      'password',
      'confirmPassword',
      'phoneNumber',
      'address'
    ]) {
      _controllers[field] = TextEditingController();
    }
  }

  void _initializeForm() {
    if (widget.accountData != null) {
      final account = widget.accountData!;
      _controllers['saintName']!.text = account.saintName ?? '';
      _controllers['fullName']!.text = account.fullName ?? '';
      _controllers['username']!.text = account.username;
      _controllers['email']!.text = account.email ?? '';
      _controllers['phoneNumber']!.text = account.phoneNumber ?? '';
      _controllers['address']!.text = account.address ?? '';
      _selectedRole = account.role;
      _selectedDepartment =
          _resolveDepartmentKeyFromAccount(account) ?? _selectedDepartment;
      _selectedClass = account.teacherClassId ?? account.classId;
      _selectedBirthDate = account.birthDate ??
          DateTime.now().subtract(const Duration(days: 7300));
      _currentAvatarUrl = account.avatarUrl;

      // Load classes for selected department
      if (_selectedDepartment.isNotEmpty) {
        _loadClasses(_selectedDepartment, preselectClassId: _selectedClass);
      }
    } else {
      _controllers['email']!.text = '@gmail.com';
      _currentAvatarUrl = null;
      _loadClasses(_selectedDepartment);
    }
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await _departmentService.getDepartments();
      setState(() {
        _departments = departments
            .map((dept) => {
                  'id': dept.id,
                  'name': dept.name,
                  'displayName': dept.displayName,
                })
            .toList();

        if (_departments.isNotEmpty &&
            !_departments.any((dept) => dept['name'] == _selectedDepartment)) {
          _selectedDepartment = _departments.first['name'] as String;
        }
      });
    } catch (e) {
      print('Load departments error: $e');
      // Fallback to default departments
      setState(() {
        _departments = [
          {'id': 1, 'name': 'CHIEN', 'displayName': 'Chiên'},
          {'id': 2, 'name': 'AU', 'displayName': 'Âu'},
          {'id': 3, 'name': 'THIEU', 'displayName': 'Thiếu'},
          {'id': 4, 'name': 'NGHIA', 'displayName': 'Nghĩa'},
        ];
        if (!_departments
            .any((dept) => dept['name'] == _selectedDepartment)) {
          _selectedDepartment = _departments.first['name'] as String;
        }
      });
    }

    if (_selectedDepartment.isNotEmpty) {
      _loadClasses(_selectedDepartment, preselectClassId: _selectedClass);
    }
  }

  Future<void> _loadClasses(String departmentKey,
      {String? preselectClassId}) async {
    setState(() {
      _loadingClasses = true;
    });

    try {
      final allClasses = await _classService.getClasses();
      final selectedDeptId = _getDepartmentIdByKey(departmentKey);
      final filteredClasses = allClasses.where((cls) {
        if (selectedDeptId != null) {
          return cls.departmentId == selectedDeptId;
        }
        return cls.department.toUpperCase() == departmentKey.toUpperCase();
      }).toList();

      setState(() {
        _classes = filteredClasses
            .map((cls) => {
                  'id': cls.id,
                  'name': cls.name,
                })
            .toList();
        _loadingClasses = false;

        final candidateClassId = preselectClassId ?? _selectedClass;
        if (candidateClassId != null &&
            _classes.any((cls) => cls['id'].toString() == candidateClassId)) {
          _selectedClass = candidateClassId;
        } else if (_selectedRole != UserRole.teacher) {
          _selectedClass = null;
        }
      });
    } catch (e) {
      print('Load classes error: $e');
      setState(() {
        _classes = [];
        _loadingClasses = false;
        if (_selectedRole != UserRole.teacher) {
          _selectedClass = null;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải danh sách lớp: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.accountData != null;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEditing ? 'Chỉnh sửa tài khoản' : 'Thêm tài khoản mới'),
            Text(
              isEditing
                  ? 'Cập nhật thông tin ${widget.accountData?.displayName ?? ""}'
                  : 'Tạo tài khoản mới cho hệ thống',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
      body: BlocListener<AdminBloc, AdminState>(
        listener: _handleBlocState,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPersonalInfoSection(),
                const SizedBox(height: 24),
                _buildLoginSection(isEditing),
                const SizedBox(height: 24),
                _buildRoleSection(),
                const SizedBox(height: 24),
                _buildPreviewCard(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          final isLoading = state is AdminLoading;
          return FloatingActionButton.extended(
            onPressed: isLoading ? null : _saveAccount,
            backgroundColor: isLoading ? AppColors.grey400 : AppColors.primary,
            icon: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white)),
                  )
                : const Icon(Icons.save, color: Colors.white),
            label: Text(
              isLoading
                  ? 'Đang lưu...'
                  : (isEditing ? 'Cập nhật' : 'Tạo tài khoản'),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }

  void _handleBlocState(BuildContext context, AdminState state) {
    if (state is UserOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(state.message), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    }
    if (state is AdminError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(state.message), backgroundColor: AppColors.error),
      );
    }
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      'Thông tin cá nhân',
      Icons.person,
      [
        _buildAvatarPicker(),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _controllers['saintName']!,
          label: 'Tên Thánh',
          icon: Icons.auto_awesome,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Vui lòng nhập tên thánh' : null,
        ),
        CustomTextField(
          controller: _controllers['fullName']!,
          label: 'Họ và tên',
          icon: Icons.person,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Vui lòng nhập họ và tên' : null,
        ),
        _buildDatePicker(),
        CustomTextField(
          controller: _controllers['phoneNumber']!,
          label: 'Số điện thoại',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Vui lòng nhập số điện thoại';
            if (value!.length < 10) return 'Số điện thoại không hợp lệ';
            return null;
          },
        ),
        CustomTextField(
          controller: _controllers['address']!,
          label: 'Địa chỉ',
          icon: Icons.location_on,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Vui lòng nhập địa chỉ' : null,
        ),
      ],
    );
  }

  Widget _buildAvatarPicker() {
    ImageProvider? imageProvider;
    if (_avatarFile != null) {
      imageProvider = FileImage(_avatarFile!);
    } else if (_currentAvatarUrl != null &&
        _resolveAvatarUrl(_currentAvatarUrl!) != null) {
      imageProvider = NetworkImage(_resolveAvatarUrl(_currentAvatarUrl!)!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ảnh đại diện',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? const Icon(Icons.person, color: AppColors.primary, size: 32)
                  : null,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: _showAvatarOptions,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Chọn ảnh'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginSection(bool isEditing) {
    return _buildSection(
      'Thông tin đăng nhập',
      Icons.lock,
      [
        CustomTextField(
          controller: _controllers['username']!,
          label: 'Tên đăng nhập',
          icon: Icons.account_circle,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Vui lòng nhập tên đăng nhập';
            if (value!.length < 3) {
              return 'Tên đăng nhập phải có ít nhất 3 ký tự';
            }
            return null;
          },
        ),
        CustomTextField(
          controller: _controllers['email']!,
          label: 'Email',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Vui lòng nhập email';
            if (!value!.contains('@')) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        if (!isEditing) ...[
          CustomTextField(
            controller: _controllers['password']!,
            label: 'Mật khẩu',
            icon: Icons.lock,
            obscureText: !_showPassword,
            suffixIcon: IconButton(
              icon:
                  Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Vui lòng nhập mật khẩu';
              if (value!.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
              return null;
            },
          ),
          CustomTextField(
            controller: _controllers['confirmPassword']!,
            label: 'Xác nhận mật khẩu',
            icon: Icons.lock_outline,
            obscureText: !_showConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(_showConfirmPassword
                  ? Icons.visibility
                  : Icons.visibility_off),
              onPressed: () =>
                  setState(() => _showConfirmPassword = !_showConfirmPassword),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) return 'Vui lòng xác nhận mật khẩu';
              if (value != _controllers['password']!.text) {
                return 'Mật khẩu xác nhận không khớp';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildRoleSection() {
    return _buildSection(
      'Phân quyền',
      Icons.admin_panel_settings,
      [
        _buildRoleSelector(),
        _buildDepartmentSelector(),
        if (_selectedRole == UserRole.teacher) _buildClassSelector(),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...children.map((child) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: child,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: _selectBirthDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.grey300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.cake, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ngày sinh',
                      style: TextStyle(fontSize: 12, color: AppColors.grey600)),
                  Text(
                    '${_selectedBirthDate.day}/${_selectedBirthDate.month}/${_selectedBirthDate.year}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const Icon(Icons.calendar_today, color: AppColors.grey400),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vai trò', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ...UserRole.values.map((role) => _buildRoleOption(role)),
      ],
    );
  }

  Widget _buildRoleOption(UserRole role) {
    final isSelected = _selectedRole == role;
    final roleData = _getRoleData(role);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
          if (role != UserRole.teacher) _selectedClass = null;
        });
        if (role == UserRole.teacher && _selectedDepartment.isNotEmpty) {
          _loadClasses(_selectedDepartment, preselectClassId: _selectedClass);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? roleData['color'].withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? roleData['color'] : AppColors.grey300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(roleData['icon'], color: roleData['color']),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(roleData['description'],
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.grey600)),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: roleData['color']),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getRoleData(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return {
          'color': AppColors.error,
          'icon': Icons.admin_panel_settings,
          'description': 'Quản lý toàn bộ hệ thống'
        };
      case UserRole.department:
        return {
          'color': AppColors.primary,
          'icon': Icons.groups,
          'description': 'Quản lý một ngành (nhiều lớp)'
        };
      case UserRole.teacher:
        return {
          'color': AppColors.success,
          'icon': Icons.school,
          'description': 'Quản lý một lớp học cụ thể'
        };
    }
  }

  Widget _buildDepartmentSelector() {
    return _buildDropdown(
      'Ngành',
      _selectedDepartment,
      _departments
          .map((dept) => DropdownMenuItem(
                value: dept['name'] as String,
                child: Text(dept['displayName'] as String),
              ))
          .toList(),
      (value) {
        if (value == null) return;
        setState(() {
          _selectedDepartment = value;
          _selectedClass = null;
        });
        _loadClasses(value);
      },
    );
  }

  Widget _buildClassSelector() {
    if (_loadingClasses) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lớp học', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Đang tải danh sách lớp...'),
              ],
            ),
          ),
        ],
      );
    }

    if (_classes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lớp học', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Không có lớp nào trong ngành này',
              style: TextStyle(color: AppColors.grey600),
            ),
          ),
        ],
      );
    }

    return _buildDropdown(
      'Lớp học',
      _selectedClass,
      _classes
          .map((cls) => DropdownMenuItem(
                value: cls['id'].toString(),
                child: Text(cls['name'] as String),
              ))
          .toList(),
      (value) => setState(() => _selectedClass = value),
      hint: 'Chọn lớp học',
    );
  }

  Widget _buildDropdown<T>(String label, T? value,
      List<DropdownMenuItem<T>> items, void Function(T?) onChanged,
      {String? hint}) {
    T? effectiveValue = value;
    if (effectiveValue != null &&
        items.every((item) => item.value != effectiveValue)) {
      effectiveValue = null;
      if (label == 'Lớp học') {
        // keep internal state consistent
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedClass = null;
            });
          }
        });
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: effectiveValue,
              isExpanded: true,
              hint: hint != null ? Text(hint) : null,
              onChanged: onChanged,
              items: items,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.preview, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Xem trước',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRoleData(_selectedRole)['color'],
                  child: Icon(_getRoleData(_selectedRole)['icon'],
                      color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_getDisplayName(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(_selectedRole.displayName,
                          style: TextStyle(
                              color: _getRoleData(_selectedRole)['color'])),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...[
              [
                'Username',
                _controllers['username']!.text.ifEmpty('username'),
                Icons.account_circle
              ],
              [
                'Email',
                _controllers['email']!.text.ifEmpty('email@thieunh.com'),
                Icons.email
              ],
              [
                'SĐT',
                _controllers['phoneNumber']!.text.ifEmpty('0123456789'),
                Icons.phone
              ],
              ['Ngành', _getDepartmentDisplayName(), Icons.business],
              if (_selectedClass != null)
                ['Lớp', _getSelectedClassName(), Icons.school],
            ].map((item) => _buildPreviewRow(
                item[0] as String, item[1] as String, item[2] as IconData)),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.grey600),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(color: AppColors.grey600)),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
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
                color: AppColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: AppColors.primary),
              title: const Text('Chụp ảnh mới'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Chọn từ thư viện'),
              onTap: () {
                Navigator.of(context).pop();
                _pickAvatar(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAvatar(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (picked == null) return;

      setState(() {
        _avatarFile = File(picked.path);
        _currentAvatarUrl = null;
      });
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

  String? _resolveAvatarUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    final base = HttpClient().apiBaseUrl;
    if (path.startsWith('/')) return '$base$path';
    return '$base/$path';
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedBirthDate = picked);
  }

  void _saveAccount() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == UserRole.teacher && _selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng chọn lớp học cho giáo lý viên'),
            backgroundColor: AppColors.error),
      );
      return;
    }

    final isEditing = widget.accountData != null;

    // FIX: Create UserModel with correct parameters
    final user = UserModel(
      id: isEditing ? widget.accountData!.id : '',
      username: _controllers['username']!.text.trim(),
      email: _controllers['email']!.text.trim().nullIfEmpty,
      role: _selectedRole,

      // FIX: Use departmentId instead of department string
      departmentId: _getSelectedDepartmentId(),

      // FIX: Use department object instead of string
      department: _getSelectedDepartmentModel(),

      // FIX: Create ClassTeacher list for teacher role
      classTeachers: _createClassTeachersList(),

      saintName: _controllers['saintName']!.text.trim().nullIfEmpty,
      fullName: _controllers['fullName']!.text.trim().nullIfEmpty,
      birthDate: _selectedBirthDate,
      phoneNumber: _controllers['phoneNumber']!.text.trim().nullIfEmpty,
      address: _controllers['address']!.text.trim().nullIfEmpty,
      teacherClassId:
          _selectedRole == UserRole.teacher ? _selectedClass : null,
      teacherClassName: _selectedRole == UserRole.teacher
          ? _getSelectedClassName()
          : null,
      permissions: widget.accountData?.permissions ?? const [],
      isActive: isEditing ? widget.accountData!.isActive : true,
      createdAt: isEditing ? widget.accountData!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
      avatarUrl: _currentAvatarUrl,
    );

    if (isEditing) {
      context
          .read<AdminBloc>()
          .add(UpdateUser(user, avatarFile: _avatarFile));
    } else {
      context.read<AdminBloc>().add(CreateUser(
            user: user,
            password: _controllers['password']!.text,
            avatarFile: _avatarFile,
          ));
    }
  }

  int? _getSelectedDepartmentId() {
    return _getDepartmentIdByKey(_selectedDepartment);
  }

  int? _getDepartmentIdByKey(String? key) {
    if (key == null) return null;

    final match = _findDepartmentByKey(key);

    if (match != null) {
      final value = match['id'];
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
    }

    final fallback = _departmentIdToKey.entries.firstWhere(
      (entry) => entry.value == key.toUpperCase(),
      orElse: () => const MapEntry(0, ''),
    );

    return fallback.key == 0 ? null : fallback.key;
  }

  String? _resolveDepartmentKeyFromAccount(UserModel account) {
    if (account.department?.name != null &&
        account.department!.name.isNotEmpty) {
      return account.department!.name.toUpperCase();
    }

    if (account.department?.displayName != null) {
      final display = account.department!.displayName;
      final match = _departmentKeyToDisplay.entries.firstWhere(
        (entry) => entry.value.toLowerCase() == display.toLowerCase(),
        orElse: () => const MapEntry('', ''),
      );
      if (match.key.isNotEmpty) return match.key;
    }

    if (account.departmentId != null) {
      return _departmentIdToKey[account.departmentId!];
    }

    return null;
  }

  String _getDepartmentDisplayName() {
    final match = _findDepartmentByKey(_selectedDepartment);

    if (match != null && match.isNotEmpty) {
      return match['displayName'] as String;
    }

    return _departmentKeyToDisplay[_selectedDepartment] ??
        _selectedDepartment;
  }

  List<ClassTeacher> _createClassTeachersList() {
    // Return empty list for now
    // The backend adapter will properly populate this from API response
    return [];
  }

  DepartmentModel? _getSelectedDepartmentModel() {
    // Optional: return null because backend sẽ trả về dữ liệu đầy đủ sau khi lưu
    return null;
  }

  String _getDisplayName() {
    final saintName = _controllers['saintName']!.text.trim();
    final fullName = _controllers['fullName']!.text.trim();
    if (saintName.isNotEmpty && fullName.isNotEmpty) {
      return '$saintName $fullName';
    }
    if (fullName.isNotEmpty) {
      return fullName;
    }
    if (saintName.isNotEmpty) {
      return saintName;
    }
    return _controllers['username']!.text.ifEmpty('Tên người dùng');
  }

  String? _getSelectedClassName() {
    if (_selectedClass == null) return null;
    Map<String, dynamic>? selectedClass;
    try {
      final result = _classes.firstWhere(
        (cls) => cls['id'].toString() == _selectedClass,
        orElse: () => <String, dynamic>{},
      );
      selectedClass =
          result.isEmpty ? null : Map<String, dynamic>.from(result as Map);
    } catch (_) {
      selectedClass = null;
    }
    if (selectedClass == null || selectedClass.isEmpty) {
      return widget.accountData?.teacherClassName;
    }
    return selectedClass['name'] as String?;
  }

  Map<String, dynamic>? _findDepartmentByKey(String? key) {
    if (key == null) return null;
    for (final dept in _departments) {
      final name = (dept['name'] as String?)?.toUpperCase();
      if (name == key.toUpperCase()) {
        return Map<String, dynamic>.from(dept as Map);
      }
    }
    return null;
  }
}

extension StringExt on String {
  String ifEmpty(String defaultValue) => isEmpty ? defaultValue : this;
  String? get nullIfEmpty => isEmpty ? null : this;
}
