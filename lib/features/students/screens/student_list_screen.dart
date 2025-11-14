import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_event.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_state.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/services/http_client.dart';
import '../../../core/models/student_model.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../bloc/students_bloc.dart';

class StudentListScreen extends StatefulWidget {
  final String classId;
  final String? className;
  final String? department;
  final String? returnTo;
  final bool isTeacherView; // NEW parameter

  const StudentListScreen({
    super.key,
    required this.classId,
    this.className,
    this.department,
    this.returnTo,
    this.isTeacherView = false, // NEW parameter
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
  
  // NEW: Teacher view mode
  String teacherViewMode = 'myClass'; // 'myClass' or 'all'

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

      // Check current state first
      if (currentState is StudentsLoaded &&
          currentState.currentClassId == widget.classId &&
          currentState.students.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Check local cache
      if (_studentsCache.containsKey(widget.classId)) {
        setState(() {
          isLoading = false;
        });
        bloc.add(LoadStudents(widget.classId));
        return;
      }

      // Load initial data based on teacher view mode
      _loadDataBasedOnViewMode();
    } catch (e) {
      setState(() {
        isLoading = false;
        hasPermission = false;
        errorMessage = 'Lỗi khởi tạo: $e';
      });
    }
  }

  // NEW: Load data based on teacher view mode
  void _loadDataBasedOnViewMode() {
    if (widget.isTeacherView && teacherViewMode == 'all') {
      // Load all students for search
      context.read<StudentsBloc>().add(const LoadAllStudentsEvent());
    } else {
      // Load students by class (default)
      context.read<StudentsBloc>().add(LoadStudents(widget.classId));
    }
  }

  // NEW: Switch teacher view mode
  void _switchTeacherViewMode(String mode) {
    if (teacherViewMode != mode) {
      setState(() {
        teacherViewMode = mode;
        isLoading = true;
      });
      _loadDataBasedOnViewMode();
    }
  }

  void _onSearchChanged() {
    if (hasPermission) {
      context.read<StudentsBloc>().add(SearchStudents(_searchController.text));
    }
  }

  Future<void> _onRefresh() async {
    if (!hasPermission) return;

    _loadDataBasedOnViewMode();

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
    );
  }

  Widget _buildBody() {
    return BlocConsumer<StudentsBloc, StudentsState>(
      listener: (context, state) {
        // Cache successful data
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
          _loadDataBasedOnViewMode();
        }

        // Update loading state
        if (state is StudentsLoaded) {
          setState(() {
            isLoading = false;
          });
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
              if (widget.isTeacherView) _buildTeacherFilters(),
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
        _getAppBarTitle(),
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

  // NEW: Teacher filters widget
  Widget _buildTeacherFilters() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bộ lọc xem',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.grey800,
              ),
            ),
            const SizedBox(height: 12),
            
            // Filter buttons
            Row(
              children: [
                Expanded(
                  child: _buildFilterButton(
                    'Lớp của tôi',
                    Icons.school,
                    teacherViewMode == 'myClass',
                    () => _switchTeacherViewMode('myClass'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFilterButton(
                    'Tất cả thiếu nhi',
                    Icons.groups,
                    teacherViewMode == 'all',
                    () => _switchTeacherViewMode('all'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String text, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.grey600,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
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

  // Hàm so sánh tiếng Việt đơn giản, đúng thứ tự bảng chữ cái Việt Nam
  int compareVietnamese(String a, String b) {
    // Đưa về chữ thường và thay thế các ký tự đặc biệt về ký tự cơ bản
    String normalize(String s) {
      return s
          .toLowerCase()
          .replaceAll(RegExp(r'[àáạảãăằắặẳẵâầấậẩẫ]'), 'a')
          .replaceAll(RegExp(r'[èéẹẻẽêềếệểễ]'), 'e')
          .replaceAll(RegExp(r'[ìíịỉĩ]'), 'i')
          .replaceAll(RegExp(r'[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
          .replaceAll(RegExp(r'[ùúụủũưừứựửữ]'), 'u')
          .replaceAll(RegExp(r'[ỳýỵỷỹ]'), 'y')
          .replaceAll(RegExp(r'[đ]'), 'd');
    }

    // Bảng chữ cái tiếng Việt chuẩn
    const vietnameseOrder = 'aăâbcdđeêghiklmnoôơpqrstuưvxy';

    int charOrder(String c) {
      c = normalize(c);
      if (c.isEmpty) return -1;
      return vietnameseOrder.indexOf(c[0]);
    }

    int minLen = a.length < b.length ? a.length : b.length;
    for (int i = 0; i < minLen; i++) {
      int orderA = charOrder(a[i]);
      int orderB = charOrder(b[i]);
      if (orderA != orderB) return orderA - orderB;
      // Nếu ký tự không thuộc bảng chữ cái, so sánh unicode
      if (orderA == -1 && orderB == -1) {
        int cmp = a[i].compareTo(b[i]);
        if (cmp != 0) return cmp;
      }
    }
    return a.length - b.length;
  }

  Widget _buildStudentsList(StudentsState state) {
    if (state is StudentsLoading || isLoading) {
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
                style: const TextStyle(color: AppColors.grey600),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _onRefresh,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is StudentsLoaded) {
      final students = List<StudentModel>.from(state.filteredStudents)
        ..sort((a, b) {
          // Sắp xếp theo tên (tức là từ cuối cùng trong tên đầy đủ)
          String getLastName(String fullName) {
            final parts = fullName.trim().split(RegExp(r'\s+'));
            return parts.isNotEmpty ? parts.last : '';
          }

          final lastNameA = getLastName(a.name);
          final lastNameB = getLastName(b.name);

          final cmp = compareVietnamese(lastNameA, lastNameB);
          if (cmp != 0) return cmp;

          // Nếu trùng tên, so sánh cả tên đầy đủ
          return compareVietnamese(a.name, b.name);
        });

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
                      : _getEmptyStateTitle(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  _searchController.text.isNotEmpty
                      ? 'Thử từ khóa khác'
                      : _getEmptyStateSubtitle(),
                  style: const TextStyle(color: AppColors.grey600),
                ),
                const SizedBox(height: 24),
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
            _buildStudentAvatar(student),
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
                  Row(
                    children: [
                      Text(
                        '${student.qrId}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.grey600,
                        ),
                      ),
                      // Show class name if viewing all students
                      if (widget.isTeacherView && teacherViewMode == 'all') ...[
                        const Text(' • ', style: TextStyle(color: AppColors.grey600)),
                        Text(
                          student.className,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
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
              child: const Icon(
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

  Widget _buildStudentAvatar(StudentModel student) {
    final imageUrl = _resolveAvatarUrl(student.avatarUrl ?? student.photoUrl);

    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 28,
                ),
              )
            : const Icon(
                Icons.person,
                color: Colors.white,
                size: 28,
              ),
      ),
    );
  }

  String? _resolveAvatarUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    final base = HttpClient().apiBaseUrl;
    if (path.startsWith('/')) return '$base$path';
    return '$base/$path';
  }

  String _getClassDisplayName() {
    final currentState = context.read<StudentsBloc>().state;
    if (currentState is StudentsLoaded && currentState.students.isNotEmpty) {
      return currentState.students.first.className;
    }
    return widget.className ?? 'Danh sách thiếu nhi';
  }

  String _getAppBarTitle() {
    if (widget.isTeacherView && teacherViewMode == 'all') {
      return 'Tất cả thiếu nhi';
    }
    return _getClassDisplayName();
  }

  String _getEmptyStateTitle() {
    if (widget.isTeacherView && teacherViewMode == 'all') {
      return 'Chưa có thiếu nhi nào';
    }
    return 'Chưa có thiếu nhi';
  }

  String _getEmptyStateSubtitle() {
    if (widget.isTeacherView && teacherViewMode == 'all') {
      return 'Hệ thống chưa có thiếu nhi nào';
    }
    return 'Thêm thiếu nhi vào lớp này';
  }
}
