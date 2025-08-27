import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final UserRole role;
  final String department;
  final String? className;
  final String? classId;
  
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
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.department,
    this.className,
    this.classId,
    this.saintName,
    this.fullName,
    this.birthDate,
    this.phoneNumber,
    this.address,
    this.isActive = true,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  String get displayName {
    if (saintName != null && fullName != null) return '$saintName $fullName';
    if (fullName != null) return fullName!;
    return username;
  }
  
  bool get canManageAll => role == UserRole.admin;
  bool get canManageDepartment => role == UserRole.admin || role == UserRole.department;

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    UserRole? role,
    String? department,
    String? className,
    String? classId,
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
      department: department ?? this.department,
      className: className ?? this.className,
      classId: classId ?? this.classId,
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
    id, username, email, role, department, className, classId,
    saintName, fullName, birthDate, phoneNumber, address,
    isActive, lastLogin, createdAt, updatedAt
  ];
}

enum UserRole { admin, department, teacher }

extension UserRoleExt on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin: return 'Ban Điều Hành';
      case UserRole.department: return 'Phân Đoàn Trưởng';
      case UserRole.teacher: return 'Giáo Lý Viên';
    }
  }
}