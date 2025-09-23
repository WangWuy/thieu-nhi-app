// lib/features/classes/screens/all_classes_screen.dart - NEW FILE
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/class_model.dart';
import 'package:thieu_nhi_app/core/models/department_model.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/class_service.dart';
import 'package:thieu_nhi_app/core/services/department_service.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/classes/widgets/class_management_card.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AllClassesScreen extends StatefulWidget {
  final String initialFilter; // 'all' or department name

  const AllClassesScreen({super.key, required this.initialFilter});

  @override
  State<AllClassesScreen> createState() => _AllClassesScreenState();
}

class _AllClassesScreenState extends State<AllClassesScreen> {
  late final _AllClassesManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = _AllClassesManager(
      initialFilter: widget.initialFilter,
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
            _buildFilters(),
            _manager.isLoading
                ? _buildLoadingSliver()
                : _manager.filteredClasses.isEmpty
                    ? _buildEmptySliver()
                    : _buildClassesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 60,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),
          child: const SafeArea(
            child: Center(
              child: Text(
                'Quản lý lớp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: TextField(
                onChanged: _manager.updateSearchTerm,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm tên lớp...',
                  hintStyle: TextStyle(color: AppColors.grey500),
                  prefixIcon: Icon(Icons.search, color: AppColors.grey500),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Department filter dropdown
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.grey200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _manager.selectedDepartment,
                  hint: Text('Chọn ngành', style: TextStyle(color: AppColors.grey500)),
                  isExpanded: true,
                  items: _manager.departmentOptions.map((option) {
                    return DropdownMenuItem<String>(
                      value: option.value,
                      child: Text(
                        option.label,
                        style: TextStyle(
                          color: AppColors.grey800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _manager.updateDepartmentFilter,
                ),
              ),
            ),
            
            // Stats row
            if (_manager.filteredClasses.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip(
                    '${_manager.filteredClasses.length} lớp',
                    Icons.school,
                    AppColors.primary,
                  ),
                  _buildStatChip(
                    '${_manager.totalStudents} thiếu nhi',
                    Icons.groups,
                    AppColors.success,
                  ),
                  _buildStatChip(
                    '${_manager.departmentCount} ngành',
                    Icons.business,
                    AppColors.secondary,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
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
            Icon(Icons.school_outlined, size: 80, color: AppColors.grey400),
            const SizedBox(height: 24),
            Text(
              _manager.searchTerm.isNotEmpty || _manager.selectedDepartment != 'all'
                  ? 'Không tìm thấy lớp phù hợp'
                  : 'Chưa có lớp học',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _manager.searchTerm.isNotEmpty || _manager.selectedDepartment != 'all'
                  ? 'Thử thay đổi bộ lọc hoặc từ khóa tìm kiếm'
                  : 'Tạo lớp học đầu tiên',
              style: TextStyle(fontSize: 16, color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassesList() {
    final groupedClasses = _manager.getGroupedClasses();
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final departmentGroup = groupedClasses[index];
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Department header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                color: AppColors.grey50,
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _getDepartmentColor(departmentGroup.name),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Ngành ${departmentGroup.displayName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getDepartmentColor(departmentGroup.name).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${departmentGroup.classes.length} lớp',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getDepartmentColor(departmentGroup.name),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Classes list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: departmentGroup.classes.map((classModel) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ClassManagementCard(
                        classModel: classModel,
                        department: departmentGroup.displayName,
                        canManage: _manager.canManage,
                        onActionSelected: (action, _) =>
                            _manager.handleClassAction(action, classModel),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 8),
            ],
          );
        },
        childCount: groupedClasses.length,
      ),
    );
  }

  Color _getDepartmentColor(String department) {
    switch (department) {
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
}

// Business logic manager
class _AllClassesManager {
  final String initialFilter;
  final BuildContext context;
  final VoidCallback onStateChanged;

  late final ClassService _classService;
  late final DepartmentService _departmentService;

  // State
  List<ClassModel> allClasses = [];
  List<DepartmentModel> departments = [];
  String searchTerm = '';
  String selectedDepartment = 'all';
  bool isLoading = true;
  bool canManage = false;

  // Dropdown options
  List<DropdownOption> get departmentOptions {
    final options = <DropdownOption>[
      const DropdownOption('all', 'Tất cả ngành'),
    ];
    
    for (final dept in departments) {
      options.add(DropdownOption(dept.name, 'Ngành ${dept.displayName}'));
    }
    
    return options;
  }

  // Filtered classes
  List<ClassModel> get filteredClasses {
    return allClasses.where((classModel) {
      // Search filter
      final matchesSearch = searchTerm.isEmpty ||
          classModel.name.toLowerCase().contains(searchTerm.toLowerCase());
      
      // Department filter
      final department = departments.firstWhere(
        (d) => d.id.toString() == classModel.departmentId.toString(),
        orElse: () => departments.first,
      );
      final matchesDepartment = selectedDepartment == 'all' ||
          department.name == selectedDepartment;
      
      return matchesSearch && matchesDepartment;
    }).toList();
  }

  int get totalStudents => filteredClasses.fold<int>(
      0, (sum, cls) => sum + cls.totalStudents);

  int get departmentCount {
    final deptIds = filteredClasses
        .map((cls) => cls.departmentId.toString())
        .toSet();
    return deptIds.length;
  }

  _AllClassesManager({
    required this.initialFilter,
    required this.context,
    required this.onStateChanged,
  });

  void initialize() {
    _classService = ClassService();
    _departmentService = DepartmentService();
    
    // Set initial department filter
    // if (initialFilter != 'all') {
    //   selectedDepartment = initialFilter;
    // }
    
    // Check permissions
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      canManage = authState.user.role == UserRole.admin ||
          authState.user.role == UserRole.department;
    }
    
    _loadData();
  }

  void dispose() {
    // Cleanup if needed
  }

  Future<void> _loadData() async {
    isLoading = true;
    onStateChanged();

    try {
      final results = await Future.wait([
        _classService.getClasses(),
        _departmentService.getDepartments(),
      ]);
      
      allClasses = results[0] as List<ClassModel>;
      departments = results[1] as List<DepartmentModel>;
      
      // ✅ Set filter AFTER departments loaded
      if (initialFilter != 'all') {
        selectedDepartment = initialFilter;
      }

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

  void updateSearchTerm(String term) {
    searchTerm = term;
    onStateChanged();
  }

  void updateDepartmentFilter(String? value) {
    if (value != null) {
      selectedDepartment = value;
      onStateChanged();
    }
  }

  List<DepartmentGroup> getGroupedClasses() {
    final groups = <DepartmentGroup>[];
    
    for (final dept in departments) {
      final classesInDept = filteredClasses
          .where((cls) => cls.departmentId == dept.id)
          .toList();
      
      if (classesInDept.isNotEmpty) {
        groups.add(DepartmentGroup(
          name: dept.name,
          displayName: dept.displayName,
          classes: classesInDept,
        ));
      }
    }
    
    return groups;
  }

  void handleClassAction(String action, ClassModel classModel) {
    switch (action) {
      case 'view':
        context.pushNamed(
          'students',
          pathParameters: {'classId': classModel.id},
          queryParameters: {
            'className': classModel.name,
            'department': classModel.department,
            'returnTo': 'classes',
          },
        );
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

// Helper classes
class DropdownOption {
  final String value;
  final String label;
  
  const DropdownOption(this.value, this.label);
}

class DepartmentGroup {
  final String name;
  final String displayName;
  final List<ClassModel> classes;
  
  const DepartmentGroup({
    required this.name,
    required this.displayName,
    required this.classes,
  });
}