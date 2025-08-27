// lib/core/models/department_summary_model.dart
class DepartmentSummary {
  final String id;
  final String name;
  final String displayName;
  final int totalClasses;
  final int totalTeachers;
  final int totalStudents;

  DepartmentSummary({
    required this.id,
    required this.name,
    required this.displayName,
    required this.totalClasses,
    required this.totalTeachers,
    required this.totalStudents,
  });

  factory DepartmentSummary.fromJson(Map<String, dynamic> json) {
    return DepartmentSummary(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? '',
      totalClasses: json['totalClasses'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'totalClasses': totalClasses,
      'totalTeachers': totalTeachers,
      'totalStudents': totalStudents,
    };
  }
}
