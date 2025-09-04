import 'package:equatable/equatable.dart';

class ClassModel extends Equatable {
  final String id;
  final String name;
  final String department;
  final int departmentId;
  final List<ClassTeacher> classTeachers;
  final List<String> studentIds;
  final int totalStudents;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClassModel({
    required this.id,
    required this.name,
    required this.department,
    required this.departmentId,
    required this.classTeachers,
    required this.studentIds,
    required this.totalStudents,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  String get displayName => '$name ($department)';
  bool get hasTeacher => classTeachers.isNotEmpty;
  bool get hasStudents => totalStudents > 0;

  String get teacherId => primaryTeacher?.id ?? '';
  String get teacherName => primaryTeacher?.displayName ?? 'Chưa phân công';

  ClassTeacher? get primaryTeacher {
    try {
      return classTeachers.firstWhere((t) => t.isPrimary);
    } catch (e) {
      return classTeachers.isNotEmpty ? classTeachers.first : null;
    }
  }

  List<String> get allTeacherNames {
    return classTeachers.map((t) => t.displayName).toList();
  }

  // FIXED: Hiển thị tên GLV đầy đủ thay vì (+1)
  String get teachersDisplay {
    if (classTeachers.isEmpty) return 'Chưa phân công';
    
    // Nếu chỉ có 1 GLV
    if (classTeachers.length == 1) {
      return classTeachers.first.displayName;
    }
    
    // Nếu có nhiều GLV, hiển thị tất cả tên, cách nhau bởi ", "
    return classTeachers.map((t) => t.displayName).join(', ');
    
    // Hoặc nếu muốn hiển thị trên nhiều dòng, dùng "\n":
    // return classTeachers.map((t) => t.displayName).join('\n');
  }

  // Alternative: Nếu muốn giới hạn độ dài và vẫn hiển thị đầy đủ
  String get teachersDisplayCompact {
    if (classTeachers.isEmpty) return 'Chưa phân công';
    
    if (classTeachers.length == 1) {
      return classTeachers.first.displayName;
    }
    
    // Hiển thị tối đa 2 tên đầu, còn lại hiển thị số lượng
    if (classTeachers.length <= 2) {
      return classTeachers.map((t) => t.displayName).join(', ');
    } else {
      final first = classTeachers[0].displayName;
      final second = classTeachers[1].displayName;
      final remaining = classTeachers.length - 2;
      return '$first, $second (+$remaining)';
    }
  }

  ClassModel copyWith({
    String? id,
    String? name,
    String? department,
    int? departmentId,
    List<ClassTeacher>? classTeachers,
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
      classTeachers: classTeachers ?? this.classTeachers,
      studentIds: studentIds ?? this.studentIds,
      totalStudents: totalStudents ?? this.totalStudents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        department,
        departmentId,
        classTeachers,
        studentIds,
        totalStudents,
        createdAt,
        updatedAt
      ];
}

class ClassTeacher extends Equatable {
  final String id;
  final String fullName;
  final String? saintName;
  final bool isPrimary;

  const ClassTeacher({
    required this.id,
    required this.fullName,
    this.saintName,
    required this.isPrimary,
  });

  String get displayName {
    if (saintName != null && saintName!.isNotEmpty) {
      return '$saintName $fullName';
    }
    return fullName;
  }

  @override
  List<Object?> get props => [id, fullName, saintName, isPrimary];
}