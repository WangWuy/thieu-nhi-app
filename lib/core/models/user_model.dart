import 'package:equatable/equatable.dart';
import 'package:thieu_nhi_app/core/models/class_model.dart';
import 'package:thieu_nhi_app/core/models/department_model.dart';
import 'package:thieu_nhi_app/core/services/backend_adapters.dart';

class UserModel extends Equatable {
  final String id;
  final String username;
  final String? email;
  final UserRole role;
  final int? departmentId;
  final DepartmentModel? department;
  final List<ClassTeacher> classTeachers;
  final String? teacherClassId;
  final String? teacherClassName;
  final int? teacherClassStudentCount;
  final List<String> permissions;

  // Personal info từ backend
  final String? saintName;
  final String? fullName;
  final DateTime? birthDate;
  final String? phoneNumber;
  final String? address;

  // Status fields
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    this.email,
    required this.role,
    this.departmentId,
    this.department,
    this.classTeachers = const [],
    this.teacherClassId,
    this.teacherClassName,
    this.teacherClassStudentCount,
    this.permissions = const [],
    this.saintName,
    this.fullName,
    this.birthDate,
    this.phoneNumber,
    this.address,
    this.isActive = true,
    this.lastLogin,
    required this.createdAt,
    this.updatedAt,
  });

  // Helper getters
  String get displayName {
    if (saintName != null && fullName != null) return '$saintName $fullName';
    if (fullName != null) return fullName!;
    return username;
  }

  bool get canManageAll => role == UserRole.admin;
  bool get canManageDepartment =>
      role == UserRole.admin || role == UserRole.department;

  // NEW: Lấy primary class của teacher
  ClassTeacher? get primaryClass {
    try {
      return classTeachers.firstWhere((ct) => ct.isPrimary);
    } catch (e) {
      return classTeachers.isNotEmpty ? classTeachers.first : null;
    }
  }

  // NEW: Lấy className cho backward compatibility
  String? get className {
    if (teacherClassName != null && teacherClassName!.isNotEmpty) {
      return teacherClassName;
    }
    final primary = primaryClass;
    return primary?.displayName;
  }

  // NEW: Lấy classId cho backward compatibility
  String? get classId {
    if (teacherClassId != null && teacherClassId!.isNotEmpty) {
      return teacherClassId;
    }
    return null;
  }

  int? get classStudentCount => teacherClassStudentCount;

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    UserRole? role,
    int? departmentId,
    DepartmentModel? department,
    List<ClassTeacher>? classTeachers,
    String? teacherClassId,
    String? teacherClassName,
    int? teacherClassStudentCount,
    List<String>? permissions,
    String? saintName,
    String? fullName,
    DateTime? birthDate,
    String? phoneNumber,
    String? address,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      department: department ?? this.department,
      classTeachers: classTeachers ?? this.classTeachers,
      teacherClassId: teacherClassId ?? this.teacherClassId,
      teacherClassName: teacherClassName ?? this.teacherClassName,
      teacherClassStudentCount:
          teacherClassStudentCount ?? this.teacherClassStudentCount,
      permissions: permissions ?? this.permissions,
      saintName: saintName ?? this.saintName,
      fullName: fullName ?? this.fullName,
      birthDate: birthDate ?? this.birthDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        role,
        departmentId,
        department,
        classTeachers,
        teacherClassId,
        teacherClassName,
        teacherClassStudentCount,
        permissions,
        saintName,
        fullName,
        birthDate,
        phoneNumber,
        address,
        isActive,
        lastLogin,
        createdAt,
        updatedAt
      ];
}

enum UserRole { admin, department, teacher }

extension UserRoleExt on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Ban Điều Hành';
      case UserRole.department:
        return 'Phân Đoàn Trưởng';
      case UserRole.teacher:
        return 'Giáo Lý Viên';
    }
  }
}
