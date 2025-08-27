import 'package:equatable/equatable.dart';

class DepartmentModel extends Equatable {
  final int id;
  final String name; // CHIEN, AU, THIEU, NGHIA
  final String displayName; // Chiên, Âu, Thiếu, Nghĩa
  final String? description;
  final List<String> classIds;
  final int totalClasses;
  final int totalStudents;
  final int totalTeachers;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DepartmentModel({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    required this.classIds,
    required this.totalClasses,
    required this.totalStudents,
    required this.totalTeachers,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  bool get hasClasses => totalClasses > 0;
  bool get hasStudents => totalStudents > 0;
  String get summaryText => '$totalClasses lớp • $totalStudents thiếu nhi';

  DepartmentModel copyWith({
    int? id,
    String? name,
    String? displayName,
    String? description,
    List<String>? classIds,
    int? totalClasses,
    int? totalStudents,
    int? totalTeachers,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DepartmentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      classIds: classIds ?? this.classIds,
      totalClasses: totalClasses ?? this.totalClasses,
      totalStudents: totalStudents ?? this.totalStudents,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, name, displayName, description, classIds, totalClasses,
    totalStudents, totalTeachers, isActive, createdAt, updatedAt
  ];
}