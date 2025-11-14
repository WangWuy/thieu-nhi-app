import 'package:equatable/equatable.dart';

/// Đại diện cho response trả về từ API đăng nhập.
class AuthResponseModel extends Equatable {
  final bool success;
  final String? message;
  final String token;
  final String? expiresIn;
  final AuthUserModel user;

  const AuthResponseModel({
    required this.success,
    required this.message,
    required this.token,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      success: json['success'] ?? false,
      message: json['message'],
      token: json['token'] ?? '',
      expiresIn: json['expiresIn']?.toString(),
      user: AuthUserModel.fromJson(json['user'] ?? const {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'token': token,
        'expiresIn': expiresIn,
        'user': user.toJson(),
      };

  @override
  List<Object?> get props => [success, message, token, expiresIn, user];
}

/// Thông tin người dùng trả về từ auth API.
class AuthUserModel extends Equatable {
  final int id;
  final String username;
  final String? fullName;
  final String role;
  final AuthDepartmentModel? department;
  final AuthClassTeacherModel? classTeacher;
  final List<String> permissions;
  final String? avatarUrl;

  const AuthUserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.department,
    required this.classTeacher,
    required this.permissions,
    this.avatarUrl,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'],
      role: json['role'] ?? 'giao_ly_vien',
      department: json['department'] != null
          ? AuthDepartmentModel.fromJson(
              Map<String, dynamic>.from(json['department'] as Map))
          : null,
      classTeacher: json['classTeacher'] != null
          ? AuthClassTeacherModel.fromJson(
              Map<String, dynamic>.from(json['classTeacher'] as Map))
          : null,
      permissions: (json['permissions'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      avatarUrl: json['avatarUrl'] ?? json['avatar'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'role': role,
        'department': department?.toJson(),
        'classTeacher': classTeacher?.toJson(),
        'permissions': permissions,
        'avatarUrl': avatarUrl,
      };

  /// Chuẩn hoá dữ liệu để tái sử dụng [BackendUserAdapter].
  Map<String, dynamic> toBackendUserJson() {
    final nowIso = DateTime.now().toIso8601String();
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'role': role,
      'departmentId': department?.id,
      'department': department?.toJson(),
      'classTeachers': [
        if (classTeacher != null)
          {
            'id': classTeacher!.id,
            'isPrimary': classTeacher!.isPrimary,
            'class': classTeacher!.classInfo?.toJson(),
          }
      ],
      'permissions': permissions,
      'avatarUrl': avatarUrl,
      'isActive': true,
      'createdAt': nowIso,
      'updatedAt': nowIso,
    };
  }

  @override
  List<Object?> get props =>
      [id, username, fullName, role, department, classTeacher, permissions, avatarUrl];
}

class AuthDepartmentModel extends Equatable {
  final int id;
  final String name;
  final String displayName;
  final String? description;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AuthDepartmentModel({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AuthDepartmentModel.fromJson(Map<String, dynamic> json) {
    return AuthDepartmentModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? '',
      description: json['description'],
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'displayName': displayName,
        'description': description,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props =>
      [id, name, displayName, description, isActive, createdAt, updatedAt];
}

class AuthClassTeacherModel extends Equatable {
  final int id;
  final bool isPrimary;
  final AuthClassInfoModel? classInfo;

  const AuthClassTeacherModel({
    required this.id,
    required this.isPrimary,
    required this.classInfo,
  });

  factory AuthClassTeacherModel.fromJson(Map<String, dynamic> json) {
    return AuthClassTeacherModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      isPrimary: json['isPrimary'] ?? false,
      classInfo: json['classInfo'] != null
          ? AuthClassInfoModel.fromJson(
              Map<String, dynamic>.from(json['classInfo'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isPrimary': isPrimary,
        'classInfo': classInfo?.toJson(),
      };

  @override
  List<Object?> get props => [id, isPrimary, classInfo];
}

class AuthClassInfoModel extends Equatable {
  final int id;
  final String name;
  final int totalStudents;
  final AuthDepartmentModel? department;

  const AuthClassInfoModel({
    required this.id,
    required this.name,
    required this.totalStudents,
    required this.department,
  });

  factory AuthClassInfoModel.fromJson(Map<String, dynamic> json) {
    return AuthClassInfoModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      name: json['name'] ?? '',
      totalStudents: json['totalStudents'] ?? 0,
      department: json['department'] != null
          ? AuthDepartmentModel.fromJson(
              Map<String, dynamic>.from(json['department'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'totalStudents': totalStudents,
        'department': department?.toJson(),
      };

  @override
  List<Object?> get props => [id, name, totalStudents, department];
}
