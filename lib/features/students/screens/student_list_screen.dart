// lib/features/students/screens/student_list_screen.dart - CLEAN VERSION
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_event.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_state.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/students_bloc.dart';

class StudentListScreen extends StatefulWidget {
  final String classId;
  final String? className;
  final String? department;
  final String? returnTo;

  const StudentListScreen({
    super.key,
    required this.classId,
    this.className,
    this.department,
    this.returnTo,
  });
  
  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  static final Map<String, List<dynamic>> _studentsCache = {};

  bool isLoading = true;
  bool hasPermission = false;
  UserModel? currentUser;
  String? errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkPermissionAndInitialize();
    _searchController.addListener(_onSearchChanged);
  }

  void _setupAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void _checkPermissionAndInitialize() {
    final authState = context.read<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      setState(() {
        isLoading = false;
        hasPermission = false;
        errorMessage = 'Chưa đăng nhập';
      });
      return;
    }

    currentUser = authState.user;
    hasPermission = _checkClassAccess(currentUser!, widget.classId);

    if (hasPermission) {
      _fabAnimationController.forward();
      _initializeBloc();
    } else {
      setState(() {
        isLoading = false;
        errorMessage = _getPermissionErrorMessage(currentUser!);
      });
    }
  }

  bool _checkClassAccess(UserModel user, String classId) {
    switch (user.role) {
      case UserRole.admin:
        return true;
      case UserRole.department:
        return true;
      case UserRole.teacher:
        if (user.classId == null) {
          return false;
        }
        return user.classId == classId;
    }
  }

  String _getPermissionErrorMessage(UserModel user) {
    switch (user.role) {
      case UserRole.teacher:
        if (user.className == null) {
          return 'Bạn chưa được phân công lớp học nào.\nVui lòng liên hệ Ban Điều Hành.';
        }
        return 'Bạn chỉ có thể truy cập lớp "${user.className}".\nLớp này không thuộc quyền quản lý của bạn.';
      case UserRole.department:
        return 'Lớp này không thuộc ngành "${user.department}" của bạn.';
      default:
        return 'Bạn không có quyền truy cập lớp học này.';
    }
  }

  void _initializeBloc() {
    try {
      final bloc = context.read<StudentsBloc>();
      final currentState = bloc.state;

      // ✅ Kiểm tra state hiện tại trước
      if (currentState is StudentsLoaded &&
          currentState.currentClassId == widget.classId &&
          currentState.students.isNotEmpty) {
        // Đã có data cho class này, không cần reload
        setState(() {
          isLoading = false;
        });
        return;
      }

      // ✅ Kiểm tra cache local
      if (_studentsCache.containsKey(widget.classId)) {
        setState(() {
          isLoading = false;
        });
        // Sử dụng cache và refresh background (optional)
        bloc.add(LoadStudents(widget.classId));
        return;
      }

      // ✅ Chỉ gọi API khi thực sự cần
      bloc.add(LoadStudents(widget.classId));
    } catch (e) {
      setState(() {
        isLoading = false;
        hasPermission = false;
        errorMessage = 'Lỗi khởi tạo: $e';
      });
    }
  }

  void _onSearchChanged() {
    if (hasPermission) {
      context.read<StudentsBloc>().add(SearchStudents(_searchController.text));
    }
  }

  Future<void> _onRefresh() async {
    if (!hasPermission) return;

    context.read<StudentsBloc>().add(LoadStudents(widget.classId));

    try {
      await Future.any([
        context
            .read<StudentsBloc>()
            .stream
            .where((state) => state is StudentsLoaded || state is StudentsError)
            .first,
        Future.delayed(const Duration(seconds: 10)),
      ]);
    } catch (e) {
      // Handle silently
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: _buildBody(),
      floatingActionButton: hasPermission
          ? FloatingActionButton(
              heroTag: "add_student_fab",
              onPressed: () => _showAddStudentDialog(),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildBody() {
    return BlocConsumer<StudentsBloc, StudentsState>(
      listener: (context, state) {
        // ✅ Cache successful data
        if (state is StudentsLoaded && state.currentClassId == widget.classId) {
          _studentsCache[widget.classId] = state.students;
        }

        if (state is StudentsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }

        if (state is StudentOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          // ✅ Refresh data after operation
          context.read<StudentsBloc>().add(LoadStudents(widget.classId));
        }
      },
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(state),
              _buildSearchBar(),
              _buildStudentsList(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverAppBar(StudentsState state) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      title: Text(
        _getClassDisplayName(),
        style: const TextStyle(
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
          onPressed: _onRefresh,
          icon: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: CustomTextField(
          controller: _searchController,
          label: 'Tìm kiếm thiếu nhi...',
          icon: Icons.search,
          keyboardType: TextInputType.text,
        ),
      ),
    );
  }

  Widget _buildStudentsList(StudentsState state) {
    if (state is StudentsLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state is StudentsError) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Có lỗi xảy ra',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.grey600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context
                      .read<StudentsBloc>()
                      .add(LoadStudents(widget.classId));
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is StudentsLoaded) {
      final students = state.filteredStudents;

      if (students.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.grey400,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isNotEmpty
                      ? 'Không tìm thấy thiếu nhi'
                      : 'Chưa có thiếu nhi',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _searchController.text.isNotEmpty
                      ? 'Thử từ khóa khác'
                      : 'Thêm thiếu nhi vào lớp này',
                  style: TextStyle(color: AppColors.grey600),
                ),
                const SizedBox(height: 24),
                if (_searchController.text.isEmpty && _canManageStudents())
                  ElevatedButton.icon(
                    onPressed: () => _showAddStudentDialog(),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Thêm thiếu nhi'),
                  ),
              ],
            ),
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final student = students[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSimplifiedStudentCard(student),
              );
            },
            childCount: students.length,
          ),
        ),
      );
    }

    return const SliverFillRemaining(
      child: Center(child: Text('Không có dữ liệu')),
    );
  }

  Widget _buildSimplifiedStudentCard(student) {
    return GestureDetector(
      onTap: () => context.push('/student/${student.id}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: AppColors.primaryGradient,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${student.qrId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.remove_red_eye,
                color: AppColors.grey600,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStudentDialog() {
    final currentState = context.read<StudentsBloc>().state;

    if (currentState is StudentsLoaded && currentState.students.isNotEmpty) {
      final firstStudent = currentState.students.first;
      context.push(
          '/add-student/${widget.classId}?className=${Uri.encodeComponent(firstStudent.className)}&department=${Uri.encodeComponent(firstStudent.department)}');
    } else {
      context.push(
          '/add-student/${widget.classId}?className=${Uri.encodeComponent(_getClassDisplayName())}&department=Unknown');
    }
  }

  bool _canManageStudents() {
    if (currentUser == null) return false;

    switch (currentUser!.role) {
      case UserRole.admin:
      case UserRole.department:
        return true;
      case UserRole.teacher:
        return true;
    }
  }

  String _getClassDisplayName() {
    final currentState = context.read<StudentsBloc>().state;
    if (currentState is StudentsLoaded && currentState.students.isNotEmpty) {
      return currentState.students.first.className;
    }
    return 'Danh sách thiếu nhi';
  }
}
