// lib/features/students/widgets/student_attendance_card.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/models/student_attendance_history.dart';
import 'package:thieu_nhi_app/core/services/student_service.dart';
import 'package:thieu_nhi_app/features/students/screens/attendance_history_screen.dart';
import 'attendance_card_header.dart';
import 'attendance_card_content.dart';

class StudentAttendanceCard extends StatefulWidget {
  final StudentModel student;
  final StudentService? studentService;

  const StudentAttendanceCard({
    super.key,
    required this.student,
    this.studentService,
  });

  @override
  State<StudentAttendanceCard> createState() => _StudentAttendanceCardState();
}

class _StudentAttendanceCardState extends State<StudentAttendanceCard> {
  late final StudentService _studentService;

  StudentAttendanceHistory? _attendanceHistory;
  StudentAttendanceStats? _attendanceStats;
  bool _isLoadingHistory = false;
  bool _isLoadingStats = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _studentService = widget.studentService ?? StudentService();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    await Future.wait([
      _loadRecentHistory(),
      _loadAttendanceStats(),
    ]);
  }

  Future<void> _loadRecentHistory() async {
    setState(() {
      _isLoadingHistory = true;
      _error = null;
    });

    try {
      final response = await _studentService.getStudentAttendanceHistory(
        widget.student.id,
        page: 1,
        limit: 10,
      );

      setState(() {
        if (response.isSuccess) {
          _attendanceHistory = response.data;
        } else {
          _error = response.error;
        }
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _loadAttendanceStats() async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final stats =
          await _studentService.getStudentAttendanceStats(widget.student.id);
      setState(() {
        _attendanceStats = stats;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStats = false;
      });
      print('Error loading attendance stats: $e');
    }
  }

  void _onRefresh() {
    _loadAttendanceData();
  }

  void _onViewAllPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AttendanceHistoryScreen(
          student: widget.student,
          initialHistory: _attendanceHistory,
          studentService: _studentService,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AttendanceCardHeader(
            attendanceHistory: _attendanceHistory,
            isLoading: _isLoadingHistory,
            onRefresh: _onRefresh,
          ),
          const SizedBox(height: 16),
          AttendanceCardContent(
            student: widget.student,
            attendanceHistory: _attendanceHistory,
            attendanceStats: _attendanceStats,
            isLoadingHistory: _isLoadingHistory,
            isLoadingStats: _isLoadingStats,
            error: _error,
            onRetry: _loadAttendanceData,
            onViewAll: _onViewAllPressed,
          ),
        ],
      ),
    );
  }
}
