// lib/features/attendance/screens/manual_attendance_screen.dart - REFACTORED
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thieu_nhi_app/core/services/student_service.dart';
import 'package:thieu_nhi_app/core/services/attendance_service.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_bloc.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_event.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_state.dart';
import 'package:thieu_nhi_app/features/attendance/screens/widgets/manual_attendance_search_bar.dart';
import 'package:thieu_nhi_app/features/attendance/screens/widgets/manual_attendance_class_filter.dart';
import 'package:thieu_nhi_app/features/attendance/screens/widgets/manual_attendance_summary.dart';
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

  List<StudentModel> _searchResults = [];
  bool _isSearching = false;
  TodayAttendanceStatus? _todayStatus;
  String? _selectedClassFilter;
  List<String> _availableClasses = [];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getAttendanceType() {
    final now = DateTime.now();
    return now.weekday == 7 ? 'sunday' : 'thursday';
  }

  void onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _availableClasses = [];
        _selectedClassFilter = null;
        _todayStatus = null;
      });
      return;
    }

    if (query.trim().length < 2) return;

    setState(() => _isSearching = true);

    try {
      final results = await _studentService.searchStudents(query.trim());
      
      if (mounted) {
        final classes = results
            .map((s) => s.className)
            .where((name) => name.isNotEmpty)
            .toSet()
            .toList();
        classes.sort();

        setState(() {
          _searchResults = results;
          _availableClasses = classes;
          _isSearching = false;
        });

        _loadAttendanceStatusForResults();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _loadAttendanceStatusForResults() async {
    if (_searchResults.isEmpty) return;

    final studentCodes = _searchResults
        .map((s) => s.qrId ?? s.id)
        .toList();

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

  List<StudentModel> get filteredResults {
    if (_selectedClassFilter == null) return _searchResults;
    return _searchResults
        .where((student) => student.className == _selectedClassFilter)
        .toList();
  }

  void onClassFilterChanged(String? newFilter) {
    setState(() {
      _selectedClassFilter = newFilter;
    });
  }

  void onMarkAttendance(StudentModel student, bool isPresent) {
    final studentCode = student.qrId ?? student.id;
    
    context.read<AttendanceBloc>().add(
      ManualAttendance(
        studentCode: studentCode,
        studentName: student.name,
        isPresent: isPresent,
      ),
    );
  }

  void onClearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _availableClasses = [];
      _selectedClassFilter = null;
      _todayStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceSuccess) {
          _showSuccess('✅ ${state.studentName} đã được ${state.isPresent ? "điểm danh có mặt" : "điểm danh vắng mặt"}');
          _loadAttendanceStatusForResults();
        } else if (state is AttendanceError) {
          _showError('❌ ${state.error}');
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

              // Class filter
              if (_availableClasses.isNotEmpty)
                ManualAttendanceClassFilter(
                  availableClasses: _availableClasses,
                  selectedClass: _selectedClassFilter,
                  onClassChanged: onClassFilterChanged,
                ),

              // Today's summary
              if (_todayStatus != null)
                ManualAttendanceSummary(todayStatus: _todayStatus!),

              // Search results
              Expanded(
                child: ManualAttendanceResults(
                  searchController: _searchController,
                  filteredResults: filteredResults,
                  selectedClassFilter: _selectedClassFilter,
                  todayStatus: _todayStatus,
                  attendanceState: state,
                  onMarkAttendance: onMarkAttendance,
                  onClearClassFilter: () => onClassFilterChanged(null),
                ),
              ),
            ],
          ),
        );
      },
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
}