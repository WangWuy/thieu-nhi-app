// lib/features/classes/screens/classes_screen.dart - CLEAN SIMPLE VERSION
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/class_model.dart';
import 'package:thieu_nhi_app/core/models/department_model.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/class_service.dart';
import 'package:thieu_nhi_app/core/services/auth_service.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/classes/widgets/class_management_card.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ClassesScreen extends StatefulWidget {
  final DepartmentModel department;

  const ClassesScreen({super.key, required this.department});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  // ✅ CLEAN: Extracted state manager
  late final _ClassesScreenManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = _ClassesScreenManager(
      department: widget.department,
      context: context,
      onStateChanged: () => setState(() {}),
    );
    _manager.initialize();
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _manager.refreshData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _manager.isLoading
                ? _buildLoadingSliver()
                : _manager.classes.isEmpty
                    ? _buildEmptySliver()
                    : _buildClassesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 60, // Giảm từ 100 xuống 80
      pinned: true,
      backgroundColor: _manager.departmentColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _manager.departmentGradient,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8), // Giảm padding
              child: Center(
                // Center thay vì Column với MainAxisAlignment
                child: Text(
                  _manager.appBarTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      leadingWidth: 70, // Tăng width để tạo khoảng cách
      leading: Padding(
        padding: const EdgeInsets.only(left: 16), // Thêm padding trái
        child: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildLoadingSliver() {
    return const SliverFillRemaining(
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEmptySliver() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school_outlined, size: 80, color: AppColors.grey400),
            const SizedBox(height: 24),
            const Text(
              'Chưa có lớp học',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.grey600),
            ),
            const SizedBox(height: 12),
            Text(
              _manager.canManage
                  ? 'Tạo lớp học đầu tiên cho ngành ${_manager.departmentName}'
                  : 'Ngành ${_manager.departmentName} chưa có lớp học',
              style: const TextStyle(fontSize: 16, color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesList() {
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final classModel = _manager.classes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ClassManagementCard(
                classModel: classModel,
                department: _manager.departmentName,
                canManage: _manager.canManage,
                onActionSelected: (action, _) =>
                    _manager.handleClassAction(action, classModel),
              ),
            );
          },
          childCount: _manager.classes.length,
        ),
      ),
    );
  }
}

// ✅ EXTRACTED: Business logic manager
class _ClassesScreenManager {
  final DepartmentModel department;
  final BuildContext context;
  final VoidCallback onStateChanged;

  late final ClassService _classService;
  late final AuthService _authService;

  // State
  List<ClassModel> classes = [];
  List<UserModel> availableTeachers = [];
  bool isLoading = true;
  bool canManage = false;

  // Getters
  String get departmentName => department.name;
  int get departmentId => department.id;
  int get totalStudents =>
      classes.fold<int>(0, (sum, cls) => sum + cls.totalStudents);

  Color get departmentColor {
    switch (departmentName) {
      case 'CHIEN':
        return AppColors.chienColor;
      case 'AU':
        return AppColors.auColor;
      case 'THIEU':
        return AppColors.thieuColor;
      case 'NGHIA':
        return AppColors.nghiaColor;
      default:
        return AppColors.primary;
    }
  }

  List<Color> get departmentGradient {
    switch (departmentName) {
      case 'CHIEN':
        return [AppColors.chienColor, const Color(0xFFFC8181)];
      case 'AU':
        return [AppColors.auColor, const Color(0xFF63B3ED)];
      case 'THIEU':
        return [AppColors.thieuColor, const Color(0xFF68D391)];
      case 'NGHIA':
        return [AppColors.nghiaColor, const Color(0xFFB794F6)];
      default:
        return AppColors.primaryGradient;
    }
  }

  String get appBarTitle {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.role == UserRole.teacher
          ? 'Lớp của tôi'
          : 'Quản lý lớp - Ngành $departmentName';
    }
    return 'Ngành $departmentName';
  }

  _ClassesScreenManager({
    required this.department,
    required this.context,
    required this.onStateChanged,
  });

  void initialize() {
    _classService = ClassService();
    _authService = AuthService();
    _loadData();
  }

  void dispose() {
    // Cleanup if needed
  }

  Future<void> _loadData() async {
    isLoading = true;
    onStateChanged();

    try {
      await Future.wait([
        _loadClasses(),
        if (canManage) _loadTeachers(),
      ]);
    } catch (e) {
      _showErrorSnackBar('Lỗi tải dữ liệu: $e');
    } finally {
      isLoading = false;
      onStateChanged();
    }
  }

  Future<void> refreshData() async {
    await _loadData();
  }

  Future<void> _loadClasses() async {
    classes = await _classService.getClassesByDepartment(departmentId);
  }

  Future<void> _loadTeachers() async {
    final allTeachers = await _authService.getTeachers();
    availableTeachers = allTeachers
        .where((t) => t.department == departmentName && t.isActive)
        .toList();
  }

  // Actions
  void handleClassAction(String action, ClassModel classModel) {
    switch (action) {
      case 'view':
        context.push('/students/${classModel.id}');
        break;
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(child: Text(message))
        ]),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
