import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_bloc.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_state.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_event.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';
import '../../../core/models/student_model.dart';
import '../widgets/student_profile_card.dart';
import '../widgets/student_score_overview_card.dart';
import '../widgets/student_detailed_scores_card.dart';
import '../widgets/student_attendance_card.dart';

class StudentDetailScreen extends StatefulWidget {
  final String studentId;

  const StudentDetailScreen({super.key, required this.studentId});

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  StudentModel? student;
  bool _isInitialLoad = true;
  DateTime? _lastRefreshed;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<bool> _handleBackNavigation() async {
    final bloc = context.read<StudentsBloc>();
    String? classId;

    final currentState = bloc.state;
    if (currentState is StudentsLoaded && currentState.currentClassId != null) {
      classId = currentState.currentClassId;
    } else if (currentState is StudentDetailLoaded) {
      classId = currentState.student.classId;
    } else if (student != null) {
      classId = student!.classId;
    }

    bloc.add(BackToStudentsList(classId: classId));
    return true;
  }

  Future<void> _onBackPressed() async {
    await _handleBackNavigation();
    if (mounted) {
      context.pop();
    }
  }

  void _loadStudentData({bool forceRefresh = false}) {
    // Always load from API to ensure fresh data
    if (forceRefresh || _isInitialLoad) {
      context.read<StudentsBloc>().add(LoadStudentDetail(widget.studentId));
      _isInitialLoad = false;
    }
  }

  Future<void> _onRefresh() async {
    _lastRefreshed = DateTime.now();
    context.read<StudentsBloc>().add(LoadStudentDetail(widget.studentId));
    
    // Add small delay to show refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackNavigation,
      child: Scaffold(
        body: BlocListener<StudentsBloc, StudentsState>(
          listener: (context, state) {
            if (state is StudentsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                  action: SnackBarAction(
                    label: 'Thử lại',
                    textColor: Colors.white,
                    onPressed: () => _loadStudentData(forceRefresh: true),
                  ),
                ),
              );
            }

            // Handle successful operations
            if (state is StudentOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.success,
                ),
              );
              // Refresh data after successful operation
              _loadStudentData(forceRefresh: true);
            }
          },
        child: BlocBuilder<StudentsBloc, StudentsState>(
          builder: (context, state) {
            if (state is StudentsLoading && _isInitialLoad) {
              return _buildLoadingScreen();
            }

            if (state is StudentDetailLoaded) {
              student = state.student;
              return _buildDetailContent();
            }

            if (state is StudentsError) {
              return _buildErrorScreen(state.message);
            }

            // Fallback: try to find student in loaded state with better error handling
            if (state is StudentsLoaded) {
              final foundStudent = state.students
                  .where((s) => s.id == widget.studentId)
                  .firstOrNull;

              if (foundStudent != null) {
                student = foundStudent;
                return _buildDetailContent();
              }
            }

            // If we have a cached student, show it while loading
            if (student != null && state is StudentsLoading) {
              return _buildDetailContent(isRefreshing: true);
            }

            return _buildNotFoundScreen();
          },
        ),
      ),
      floatingActionButton: student != null
          ? FloatingActionButton.extended(
              onPressed: _editStudent,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                'Chỉnh sửa',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          : null,
    ));
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đang tải...'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed,
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải thông tin thiếu nhi...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lỗi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed,
        ),
        actions: [
          IconButton(
            onPressed: () => _loadStudentData(forceRefresh: true),
            icon: const Icon(Icons.refresh),
            tooltip: 'Thử lại',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Có lỗi xảy ra', 
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      message, 
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.grey600),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _loadStudentData(forceRefresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotFoundScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Không tìm thấy'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_search, size: 64, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy thiếu nhi', 
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ID: ${widget.studentId}', 
                    style: const TextStyle(color: AppColors.grey600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _loadStudentData(forceRefresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent({bool isRefreshing = false}) {
    if (student == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildSliverAppBar(isRefreshing: isRefreshing),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Show refresh indicator if refreshing
                if (isRefreshing) _buildRefreshIndicator(),
                
                StudentProfileCard(student: student!),
                const SizedBox(height: 16),
                
                // Only show score cards if we have academic year data
                if (_hasValidAcademicData()) ...[
                  StudentScoreOverviewCard(student: student!),
                  const SizedBox(height: 16),
                  StudentDetailedScoresCard(student: student!),
                  const SizedBox(height: 16),
                ] else ...[
                  _buildMissingAcademicDataCard(),
                  const SizedBox(height: 16),
                ],
                
                StudentAttendanceCard(student: student!),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Đang cập nhật dữ liệu...',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingAcademicDataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 48,
            color: AppColors.warning,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có thông tin năm học',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.grey800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'thiếu nhi chưa được gán vào năm học nào. Liên hệ quản trị viên để cập nhật.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _loadStudentData(forceRefresh: true),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Làm mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar({bool isRefreshing = false}) {
    return SliverAppBar(
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            student?.name ?? 'Chi tiết thiếu nhi',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_lastRefreshed != null) ...[
            Text(
              'Cập nhật: ${_formatTime(_lastRefreshed!)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: _onBackPressed,
      ),
      actions: [
        if (isRefreshing)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          )
        else
          IconButton(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Làm mới',
          ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _editStudent();
                break;
              case 'refresh':
                _onRefresh();
                break;
              case 'delete':
                _deleteStudent();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'refresh',
              child: Row(
                children: [
                  Icon(Icons.refresh, color: AppColors.secondary),
                  SizedBox(width: 8),
                  Text('Làm mới'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa thiếu nhi', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _hasValidAcademicData() {
    return student?.academicYearId != null || 
           student?.academicYearTotalWeeks != null ||
           (student?.attendanceAverage != null || student?.studyAverage != null);
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _editStudent() {
    if (student != null) {
      context.pushNamed(
        'edit-student',
        pathParameters: {'studentId': student!.id},
        extra: student,
      ).then((_) {
        // Refresh data when returning from edit screen
        _loadStudentData(forceRefresh: true);
      });
    }
  }

  void _deleteStudent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa thiếu nhi ${student?.name}?\n\nHành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (student != null) {
                context.read<StudentsBloc>().add(DeleteStudent(student!.id));
                // Navigate back after deletion
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) context.pop();
                });
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}

// Extension for firstOrNull
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull {
    if (isEmpty) return null;
    return first;
  }
}
