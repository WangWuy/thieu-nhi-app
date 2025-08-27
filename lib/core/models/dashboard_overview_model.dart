// lib/core/models/dashboard_overview_model.dart
import 'department_summary_model.dart';

class DashboardOverview {
  final int totalDepartments;
  final int totalClasses;
  final int totalTeachers;
  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final double attendanceRate;
  final List<DepartmentSummary> departmentStats;
  final Map<String, int> usersByRole;
  final DateTime lastUpdated;

  DashboardOverview({
    required this.totalDepartments,
    required this.totalClasses,
    required this.totalTeachers,
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.attendanceRate,
    required this.departmentStats,
    required this.usersByRole,
    required this.lastUpdated,
  });

  /// Parse from backend /api/dashboard/stats response
  factory DashboardOverview.fromJson(Map<String, dynamic> json) {
    try {
      // Parse summary data
      final summary = json['summary'] ?? {};

      // Parse recent attendance (thursday + sunday combined)
      final recentAttendance = json['recentAttendance'] ?? {};
      final thursdayData = recentAttendance['thursday'] ?? {};
      final sundayData = recentAttendance['sunday'] ?? {};

      final present =
          (thursdayData['present'] ?? 0) + (sundayData['present'] ?? 0);
      final absent =
          (thursdayData['absent'] ?? 0) + (sundayData['absent'] ?? 0);
      final total = present + absent;
      final rate = total > 0 ? (present / total) * 100 : 0.0;

      // Parse department stats
      final departmentStatsData = json['departmentStats'] as List? ?? [];
      final departmentStats = departmentStatsData
          .map((data) => DepartmentSummary.fromJson(data))
          .toList();

      // Parse users by role
      final usersByRoleData =
          json['usersByRole'] as Map<String, dynamic>? ?? {};
      final usersByRole = usersByRoleData.map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      );

      return DashboardOverview(
        totalDepartments: summary['totalDepartments'] ?? 0,
        totalClasses: summary['totalClasses'] ?? 0,
        totalTeachers: summary['totalTeachers'] ?? 0,
        totalStudents: summary['totalStudents'] ?? 0,
        presentToday: present,
        absentToday: absent,
        attendanceRate: rate,
        departmentStats: departmentStats,
        usersByRole: usersByRole,
        lastUpdated:
            DateTime.tryParse(json['lastUpdated'] ?? '') ?? DateTime.now(),
      );
    } catch (e) {
      print('Error parsing dashboard overview: $e');
      return DashboardOverview.empty();
    }
  }

  factory DashboardOverview.empty() {
    return DashboardOverview(
      totalDepartments: 0,
      totalClasses: 0,
      totalTeachers: 0,
      totalStudents: 0,
      presentToday: 0,
      absentToday: 0,
      attendanceRate: 0.0,
      departmentStats: [],
      usersByRole: {},
      lastUpdated: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDepartments': totalDepartments,
      'totalClasses': totalClasses,
      'totalTeachers': totalTeachers,
      'totalStudents': totalStudents,
      'presentToday': presentToday,
      'absentToday': absentToday,
      'attendanceRate': attendanceRate,
      'departmentStats': departmentStats.map((d) => d.toJson()).toList(),
      'usersByRole': usersByRole,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Helper getters
  int get totalAttendanceToday => presentToday + absentToday;
  String get attendanceRateFormatted => '${attendanceRate.toStringAsFixed(1)}%';
  bool get hasData => totalStudents > 0;

  // Get specific department stats
  DepartmentSummary? getDepartmentStats(String departmentId) {
    try {
      return departmentStats.firstWhere(
        (dept) => dept.id == departmentId || dept.name == departmentId,
      );
    } catch (e) {
      return null;
    }
  }
}
