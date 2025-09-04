// lib/core/models/dashboard_model.dart
import 'department_summary_model.dart';

class DashboardData {
  final int totalDepartments;
  final int totalClasses;
  final int totalTeachers;
  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final double attendanceRate;
  final List<DepartmentSummary> departments;
  final Map<String, int> usersByRole;
  final DateTime lastUpdated;

  DashboardData({
    required this.totalDepartments,
    required this.totalClasses,
    required this.totalTeachers,
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.attendanceRate,
    required this.departments,
    required this.usersByRole,
    required this.lastUpdated,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    try {
      final summary = json['summary'] ?? {};
      final recentAttendance = json['recentAttendance'] ?? {};
      final thursdayData = recentAttendance['thursday'] ?? {};
      final sundayData = recentAttendance['sunday'] ?? {};

      final present = (thursdayData['present'] ?? 0) + (sundayData['present'] ?? 0);
      final absent = (thursdayData['absent'] ?? 0) + (sundayData['absent'] ?? 0);
      final total = present + absent;
      final rate = total > 0 ? (present / total) * 100 : 0.0;

      final departmentStatsData = json['departmentStats'] as List? ?? [];
      final departments = departmentStatsData
          .map((data) => DepartmentSummary.fromJson(data))
          .toList();

      final usersByRoleData = json['usersByRole'] as Map<String, dynamic>? ?? {};
      final usersByRole = usersByRoleData.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      );

      return DashboardData(
        totalDepartments: summary['totalDepartments'] ?? 0,
        totalClasses: summary['totalClasses'] ?? 0,
        totalTeachers: summary['totalTeachers'] ?? 0,
        totalStudents: summary['totalStudents'] ?? 0,
        presentToday: present,
        absentToday: absent,
        attendanceRate: rate,
        departments: departments,
        usersByRole: usersByRole,
        lastUpdated: DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      print('Error parsing dashboard data: $e');
      return DashboardData.empty();
    }
  }

  factory DashboardData.empty() {
    return DashboardData(
      totalDepartments: 0,
      totalClasses: 0,
      totalTeachers: 0,
      totalStudents: 0,
      presentToday: 0,
      absentToday: 0,
      attendanceRate: 0.0,
      departments: [],
      usersByRole: {},
      lastUpdated: DateTime.now(),
    );
  }

  // Helper getters
  int get totalAttendanceToday => presentToday + absentToday;
  String get attendanceRateFormatted => '${attendanceRate.toStringAsFixed(1)}%';
  bool get hasData => totalStudents > 0;

  DepartmentSummary? getDepartmentStats(String departmentId) {
    try {
      return departments.firstWhere(
        (dept) => dept.id == departmentId || dept.name == departmentId,
      );
    } catch (e) {
      return null;
    }
  }
}