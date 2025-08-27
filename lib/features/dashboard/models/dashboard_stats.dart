import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final int totalClasses;
  final int totalTeachers;
  final double overallAttendanceRate;
  final Map<String, int> departmentStats;
  final Map<String, double> weeklyTrends;
  final DateTime lastUpdated;

  const DashboardStats({
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.totalClasses,
    required this.totalTeachers,
    required this.overallAttendanceRate,
    required this.departmentStats,
    required this.weeklyTrends,
    required this.lastUpdated,
  });

  factory DashboardStats.fromMap(Map<String, dynamic> map) {
    return DashboardStats(
      totalStudents: map['totalStudents'] ?? 0,
      presentToday: map['presentToday'] ?? 0,
      absentToday: map['absentToday'] ?? 0,
      totalClasses: map['totalClasses'] ?? 0,
      totalTeachers: map['totalTeachers'] ?? 0,
      overallAttendanceRate: (map['overallAttendanceRate'] ?? 0.0).toDouble(),
      departmentStats: Map<String, int>.from(map['departmentStats'] ?? {}),
      weeklyTrends: Map<String, double>.from(map['weeklyTrends'] ?? {}),
      lastUpdated: DateTime.tryParse(map['lastUpdated'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalStudents': totalStudents,
      'presentToday': presentToday,
      'absentToday': absentToday,
      'totalClasses': totalClasses,
      'totalTeachers': totalTeachers,
      'overallAttendanceRate': overallAttendanceRate,
      'departmentStats': departmentStats,
      'weeklyTrends': weeklyTrends,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  DashboardStats copyWith({
    int? totalStudents,
    int? presentToday,
    int? absentToday,
    int? totalClasses,
    int? totalTeachers,
    double? overallAttendanceRate,
    Map<String, int>? departmentStats,
    Map<String, double>? weeklyTrends,
    DateTime? lastUpdated,
  }) {
    return DashboardStats(
      totalStudents: totalStudents ?? this.totalStudents,
      presentToday: presentToday ?? this.presentToday,
      absentToday: absentToday ?? this.absentToday,
      totalClasses: totalClasses ?? this.totalClasses,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      overallAttendanceRate: overallAttendanceRate ?? this.overallAttendanceRate,
      departmentStats: departmentStats ?? this.departmentStats,
      weeklyTrends: weeklyTrends ?? this.weeklyTrends,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        totalStudents,
        presentToday,
        absentToday,
        totalClasses,
        totalTeachers,
        overallAttendanceRate,
        departmentStats,
        weeklyTrends,
        lastUpdated,
      ];
}