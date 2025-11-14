// manual_attendance_screen.dart - COMPLETE UPDATED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thieu_nhi_app/core/services/class_service.dart';
import 'package:thieu_nhi_app/core/services/student_service.dart';
import 'package:thieu_nhi_app/core/services/attendance_service.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_bloc.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_event.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_state.dart';
import 'package:thieu_nhi_app/features/attendance/screens/widgets/manual_attendance_search_bar.dart';
import 'package:thieu_nhi_app/features/attendance/screens/widgets/manual_attendance_class_filter.dart';
import 'package:thieu_nhi_app/features/attendance/screens/widgets/manual_attendance_results.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ManualAttendanceScreen extends StatefulWidget {
  const ManualAttendanceScreen({super.key});

  @override
  State<ManualAttendanceScreen> createState() => _ManualAttendanceScreenState();
}

class _ManualAttendanceScreenState extends State<ManualAttendanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  final StudentService _studentService = StudentService();
  final AttendanceService _attendanceService = AttendanceService();
  final ClassService _classService = ClassService();
  static const int _pageSize = 10;
  late final ScrollController _resultsScrollController;

  List<StudentModel> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _currentPage = 1;
  TodayAttendanceStatus? _todayStatus;
  String? _selectedClassFilter;
  String? _currentClassId;
  String? _currentSearchQuery;
  List<String> _availableClasses = [];
  Map<String, int> _classNameToIdMap = {};
  bool _initialDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _resultsScrollController = ScrollController()..addListener(_handleScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _resultsScrollController
      ..removeListener(_handleScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_resultsScrollController.position.pixels >=
            _resultsScrollController.position.maxScrollExtent - 200 &&
        !_isSearching) {
      _loadMoreStudents();
    }
  }

  // UPDATED: Load user's classes first, then auto-select
  void _loadInitialData() async {
    if (_initialDataLoaded) {
      return;
    }
    
    setState(() => _isSearching = true);

    try {
      // Step 1: Get user's classes based on role
      final classes = await _getUserClasses();
      
      if (classes.isEmpty) {
        if (mounted) {
          setState(() {
            _isSearching = false;
            _initialDataLoaded = true;
          });
        }
        return;
      }

      // Step 2: Auto-select first class
      final firstClassName = classes.keys.first;
      final firstClassId = classes[firstClassName];
      
      // Step 3: Load students for first class only
      final result = await _studentService.getStudents(
        page: 1,
        limit: _pageSize,
        classFilter: firstClassId.toString(),
      );
      
      if (mounted && result.isSuccess) {
        final students = result.students ?? [];
        final sortedClasses = classes.keys.toList()..sort();

        setState(() {
          _searchResults = students;
          _availableClasses = sortedClasses;
          _classNameToIdMap = classes;
          _selectedClassFilter = firstClassName; // Auto-select first class
          _currentClassId = firstClassId?.toString();
          _currentSearchQuery = null;
          _currentPage = result.currentPage ?? 1;
          final totalPages = result.totalPages ?? 1;
          _hasMore = _currentPage < totalPages && students.isNotEmpty;
          _isSearching = false;
          _initialDataLoaded = true;
        });

        _loadAttendanceStatusForResults();
      } else {
        print('Failed to load students: ${result.error}');
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    } catch (e) {
      print('Load initial data error: $e');
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  // NEW: Get classes (always full list)
  Future<Map<String, int>> _getUserClasses() async {
    try {
      final classes = await _classService.getClasses();
      final classMap = <String, int>{};

      for (final classModel in classes) {
        final classId = int.tryParse(classModel.id) ?? 0;
        if (classId > 0) {
          classMap[classModel.name] = classId;
        }
      }

      return classMap;
    } catch (e) {
      print('❌ Get user classes error: $e');
      return {};
    }
  }

  String _getAttendanceType() {
    final now = DateTime.now();
    return now.weekday == 7 ? 'sunday' : 'thursday';
  }

  // UPDATED: Search within current class or reload current class
  void onSearchChanged(String query) {
    final trimmed = query.trim();
    if (trimmed.isNotEmpty && trimmed.length < 2) return;

    _currentSearchQuery = trimmed.isEmpty ? null : trimmed;
    _resetPagination();
    _fetchStudents(page: 1);
  }

  void _loadAttendanceStatusForResults() async {
    if (_searchResults.isEmpty) return;

    final studentCodes = _searchResults.map((s) => s.qrId ?? s.id).toList();

    final status = await _attendanceService.getTodayAttendanceStatus(
      studentCodes: studentCodes,
      date: DateTime.now(),
      type: _getAttendanceType(),
    );

    if (mounted && status != null) {
      setState(() {
        _todayStatus = status;
      });
    }
  }

  Map<String, int> get classStudentCounts {
    final counts = <String, int>{};
    for (final student in _searchResults) {
      final className = student.className;
      counts[className] = (counts[className] ?? 0) + 1;
    }
    return counts;
  }

  List<StudentModel> get filteredResults => _searchResults;

  List<String> get filteredStudentCodes {
    return filteredResults.map((s) => s.qrId ?? s.id).toList();
  }

  // UPDATED: Class filter with server-side filtering
  void onClassFilterChanged(String? newFilter) async {
    if (_selectedClassFilter == newFilter) return;

    final classId = newFilter != null ? _classNameToIdMap[newFilter] : null;

    setState(() {
      _selectedClassFilter = newFilter;
      _currentClassId = classId?.toString();
    });

    _resetPagination();
    _fetchStudents(page: 1);
  }

  void onMarkAttendance(StudentModel student) {
    final studentCode = student.qrId ?? student.id;

    context.read<AttendanceBloc>().add(
      ManualAttendance(
        studentCode: studentCode,
        studentName: student.name,
      ),
    );
  }

  void onUndoAttendance(StudentModel student) {
    final studentCode = student.qrId ?? student.id;
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xác nhận hủy điểm danh'),
        content: Text('Bạn có chắc muốn hủy điểm danh cho ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AttendanceBloc>().add(
                UndoAttendance(
                  studentCode: studentCode,
                  studentName: student.name,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }

  // UPDATED: Keep current class when clearing search
  void onClearSearch() {
    _searchController.clear();
    _currentSearchQuery = null;
    _resetPagination();
    _fetchStudents(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceSuccess) {
          final message = state.isUndo 
              ? 'Đã hủy điểm danh ${state.studentName}'
              : 'Đã điểm danh ${state.studentName}';
          _showSuccess(message);
          _loadAttendanceStatusForResults();
        } else if (state is AttendanceError) {
          _showError('Lỗi: ${state.error}');
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              'Điểm danh thủ công',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: const IconThemeData(color: AppColors.grey800),
          ),
          body: Column(
            children: [
              // Search bar
              ManualAttendanceSearchBar(
                controller: _searchController,
                onChanged: onSearchChanged,
                onClear: onClearSearch,
                isSearching: _isSearching,
              ),

              // Class filter - Show when classes are available
              if (_availableClasses.isNotEmpty)
                ManualAttendanceClassFilter(
                  availableClasses: _availableClasses,
                  selectedClass: _selectedClassFilter,
                  onClassChanged: onClassFilterChanged,
                  classStudentCounts: classStudentCounts,
                ),

              // Results
              Expanded(
                child: _buildResultsWidget(state),
              ),
            ],
          ),
        );
      },
    );
  }

  // UPDATED: Better loading states
  Widget _buildResultsWidget(AttendanceState state) {
    // Loading initial data
    if (!_initialDataLoaded && _isSearching) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải dữ liệu...'),
          ],
        ),
      );
    }

    // Failed to load initial data
    if (!_initialDataLoaded && !_isSearching) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không thể tải dữ liệu',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _initialDataLoaded = false);
                _loadInitialData();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    // No results after loading
    if (_searchResults.isEmpty && _initialDataLoaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchController.text.trim().isNotEmpty 
                  ? 'Không tìm thấy thiếu nhi nào'
                  : _selectedClassFilter != null
                      ? 'Lớp $_selectedClassFilter chưa có thiếu nhi'
                      : 'Chưa có dữ liệu thiếu nhi',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show results
    return ManualAttendanceResults(
      searchController: _searchController,
      filteredResults: filteredResults,
      selectedClassFilter: _selectedClassFilter,
      todayStatus: _todayStatus,
      attendanceState: state,
      onMarkAttendance: onMarkAttendance,
      onUndoAttendance: onUndoAttendance,
      onClearClassFilter: () => onClassFilterChanged(null),
      scrollController: _resultsScrollController,
      isLoadingMore: _isLoadingMore,
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _resetPagination() {
    _currentPage = 1;
    _hasMore = true;
    _isLoadingMore = false;
  }

  Future<void> _fetchStudents({
    required int page,
    bool append = false,
  }) async {
    if (!append) {
      setState(() => _isSearching = true);
    }

    try {
      final result = await _studentService.getStudents(
        page: page,
        limit: _pageSize,
        search: _currentSearchQuery,
        classFilter: _currentClassId,
      );

      if (!mounted) return;

      if (result.isSuccess) {
        final students = result.students ?? [];
        setState(() {
          if (append) {
            _searchResults = [..._searchResults, ...students];
          } else {
            _searchResults = students;
          }
          _currentPage = result.currentPage ?? page;
          final totalPages = result.totalPages ?? _currentPage;
          _hasMore = (_currentPage < totalPages) && students.isNotEmpty;
          _isSearching = false;
          _isLoadingMore = false;
        });
        _loadAttendanceStatusForResults();
      } else {
        setState(() {
          _isSearching = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Fetch students error: $e');
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMoreStudents() async {
    if (!_initialDataLoaded || !_hasMore || _isLoadingMore) return;
    setState(() => _isLoadingMore = true);
    await _fetchStudents(page: _currentPage + 1, append: true);
  }
}
