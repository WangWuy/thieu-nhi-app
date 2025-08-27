import 'package:equatable/equatable.dart';

class ClassModel extends Equatable {
  final String id;
  final String name;
  final String department;
  final int departmentId;
  final String teacherId;
  final String teacherName;
  final List<String> studentIds;
  final int totalStudents;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClassModel({
    required this.id,
    required this.name,
    required this.department,
    required this.departmentId,
    required this.teacherId,
    required this.teacherName,
    required this.studentIds,
    required this.totalStudents,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  String get displayName => '$name ($department)';
  String get teacherDisplay => teacherName.isEmpty ? 'Chưa phân công' : teacherName;
  bool get hasTeacher => teacherId.isNotEmpty;
  bool get hasStudents => totalStudents > 0;

  ClassModel copyWith({
    String? id,
    String? name,
    String? department,
    int? departmentId,
    String? teacherId,
    String? teacherName,
    List<String>? studentIds,
    int? totalStudents,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassModel(
      id: id ?? this.id,
      name: name ?? this.name,
      department: department ?? this.department,
      departmentId: departmentId ?? this.departmentId,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      studentIds: studentIds ?? this.studentIds,
      totalStudents: totalStudents ?? this.totalStudents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, name, department, departmentId, teacherId, teacherName,
    studentIds, totalStudents, createdAt, updatedAt
  ];
}