import '../models/user_model.dart';
import '../models/student_model.dart';
import '../models/class_model.dart';
import '../models/department_model.dart';

/// Improved Backend Adapter with better error handling and data validation
class BackendStudentAdapter {
  static StudentModel fromBackendJson(Map<String, dynamic> json) {
    try {
      return StudentModel(
        id: json['id'].toString(),
        qrId: json['studentCode'],
        name: json['fullName'] ?? '',
        phone: json['phoneNumber'] ?? '',
        parentPhone: json['parentPhone1'] ?? '',
        address: json['address'] ?? '',
        birthDate: _parseDate(json['birthDate']) ??
            DateTime.now().subtract(const Duration(days: 3650)),
        classId: json['classId'].toString(),
        className: json['class']?['name'] ?? 'Unknown',
        department: json['class']?['department']?['displayName'] ?? 'Unknown',
        attendance: const {},
        grades: _parseGrades(json),
        createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),

        // Backend specific fields
        saintName: json['saintName'],
        parentPhone2: json['parentPhone2'],
        thursdayAttendanceCount: _parseInt(json['thursdayAttendanceCount']),
        sundayAttendanceCount: _parseInt(json['sundayAttendanceCount']),
        attendanceAverage: _parseDouble(json['attendanceAverage']),
        studyAverage: _parseDouble(json['studyAverage']),
        finalAverage: _parseDouble(json['finalAverage']),
      );
    } catch (e) {
      print('Error parsing student: $e');
      return _createFallbackStudent(json);
    }
  }

  // ✅ Helper methods đơn giản
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return null;
    }
  }

  static int? _parseInt(dynamic value) => int.tryParse(value?.toString() ?? '');
  static double? _parseDouble(dynamic value) =>
      double.tryParse(value?.toString() ?? '');

  static List<double> _parseGrades(Map<String, dynamic> json) {
    final grades = <double>[];
    final fields = ['study45Hk1', 'examHk1', 'study45Hk2', 'examHk2'];

    for (final field in fields) {
      final grade = _parseDouble(json[field]);
      if (grade != null && grade > 0) grades.add(grade);
    }

    return grades.isEmpty ? [0.0] : grades;
  }

  static StudentModel _createFallbackStudent(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? 'unknown',
      name: json['fullName'] ?? 'Unknown Student',
      phone: '',
      parentPhone: '',
      address: '',
      birthDate: DateTime.now().subtract(const Duration(days: 3650)),
      classId: '0',
      className: 'Unknown',
      department: 'Unknown',
      attendance: const {},
      grades: const [0.0],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // ✅ Convert methods
  static Map<String, dynamic> toBackendCreateJson(StudentModel student) {
    return {
      'studentCode':
          student.qrId ?? 'TN${DateTime.now().millisecondsSinceEpoch}',
      'fullName': student.name,
      'classId': int.tryParse(student.classId) ?? 0,
      'address': student.address,
      'birthDate': student.birthDate.toIso8601String(),
      if (student.saintName?.isNotEmpty ?? false)
        'saintName': student.saintName,
      if (student.phone.isNotEmpty) 'phoneNumber': student.phone,
      if (student.parentPhone.isNotEmpty) 'parentPhone1': student.parentPhone,
    };
  }

  static Map<String, dynamic> toBackendUpdateJson(StudentModel student) {
    final data = <String, dynamic>{};

    if (student.name.isNotEmpty) data['fullName'] = student.name;
    if (student.saintName?.isNotEmpty ?? false) {
      data['saintName'] = student.saintName;
    }
    if (student.phone.isNotEmpty) data['phoneNumber'] = student.phone;
    if (student.address.isNotEmpty) data['address'] = student.address;

    data['birthDate'] = student.birthDate.toIso8601String();
    final classId = int.tryParse(student.classId);
    if (classId != null && classId > 0) data['classId'] = classId;

    return data;
  }
}

// Extension for other adapters (keeping existing ones)
class BackendUserAdapter {
  // ... existing code remains the same
  static UserModel fromBackendJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '${json['username']}@temp.com',
      role: _parseUserRole(json['role']),
      department: _getDepartmentName(json),
      className: _getClassName(json),
      classId: _getClassId(json),
      saintName: json['saintName'],
      fullName: json['fullName'],
      birthDate:
          json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      isActive: json['isActive'] ?? true,
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static UserRole _parseUserRole(dynamic role) {
    if (role == null) return UserRole.teacher;

    switch (role.toString().toLowerCase()) {
      case 'ban_dieu_hanh':
      case 'admin':
        return UserRole.admin;
      case 'phan_doan_truong':
      case 'department':
        return UserRole.department;
      case 'giao_ly_vien':
      case 'teacher':
        return UserRole.teacher;
      default:
        return UserRole.teacher;
    }
  }

  static String _getDepartmentName(Map<String, dynamic> json) {
    if (json['department'] != null) {
      if (json['department'] is Map) {
        return json['department']['displayName'] ??
            json['department']['name'] ??
            'Unknown';
      } else {
        return json['department'].toString();
      }
    }
    return 'Unknown';
  }

  static String? _getClassName(Map<String, dynamic> json) {
    if (json['classTeachers'] != null && json['classTeachers'] is List) {
      final classTeachers = json['classTeachers'] as List;
      if (classTeachers.isNotEmpty) {
        final firstClass = classTeachers[0];
        if (firstClass['class'] != null) {
          return firstClass['class']['name'];
        }
      }
    }
    return null;
  }

  static String? _getClassId(Map<String, dynamic> json) {
    if (json['classTeachers'] != null && json['classTeachers'] is List) {
      final classTeachers = json['classTeachers'] as List;
      if (classTeachers.isNotEmpty) {
        final firstClass = classTeachers[0];
        if (firstClass['class'] != null) {
          return firstClass['class']['id'].toString();
        }
      }
    }
    return null;
  }

  static Map<String, dynamic> toBackendJson(UserModel user) {
    return {
      'username': user.username,
      'email': user.email,
      'role': _userRoleToBackend(user.role),
      'saintName': user.saintName,
      'fullName': user.fullName,
      'birthDate': user.birthDate?.toIso8601String(),
      'phoneNumber': user.phoneNumber,
      'address': user.address,
      'isActive': user.isActive,
    };
  }

  static String _userRoleToBackend(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'ban_dieu_hanh';
      case UserRole.department:
        return 'phan_doan_truong';
      case UserRole.teacher:
        return 'giao_ly_vien';
    }
  }
}

class BackendClassAdapter {
  static ClassModel fromBackendJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      department: _getDepartmentName(json),
      departmentId: json['departmentId'] ?? 0,
      classTeachers: _getClassTeachers(json),
      studentIds: _getStudentIds(json),
      totalStudents: _getTotalStudents(json),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static List<ClassTeacher> _getClassTeachers(Map<String, dynamic> json) {
    if (json['classTeachers'] != null && json['classTeachers'] is List) {
      return (json['classTeachers'] as List).map((teacher) {
        final user = teacher['user'] ?? {};
        return ClassTeacher(
          id: user['id'].toString(),
          fullName: user['fullName'] ?? '',
          saintName: user['saintName'],
          isPrimary: teacher['isPrimary'] ?? false,
        );
      }).toList();
    }
    return [];
  }

  static String _getDepartmentName(Map<String, dynamic> json) {
    if (json['department'] != null && json['department'] is Map) {
      return json['department']['displayName'] ??
          json['department']['name'] ??
          '';
    }
    return '';
  }

  static String _getTeacherId(Map<String, dynamic> json) {
    if (json['classTeachers'] != null && json['classTeachers'] is List) {
      final teachers = json['classTeachers'] as List;
      if (teachers.isNotEmpty) {
        return teachers[0]['userId'].toString();
      }
    }
    return '';
  }

  static String _getTeacherName(Map<String, dynamic> json) {
    if (json['classTeachers'] != null && json['classTeachers'] is List) {
      final teachers = json['classTeachers'] as List;
      if (teachers.isNotEmpty && teachers[0]['user'] != null) {
        return teachers[0]['user']['fullName'] ?? '';
      }
    }
    return '';
  }

  static List<String> _getStudentIds(Map<String, dynamic> json) {
    if (json['students'] != null && json['students'] is List) {
      return (json['students'] as List)
          .map((student) => student['id'].toString())
          .toList();
    }
    return [];
  }

  static int _getTotalStudents(Map<String, dynamic> json) {
    if (json['_count'] != null && json['_count']['students'] != null) {
      return json['_count']['students'];
    }
    if (json['students'] != null && json['students'] is List) {
      return (json['students'] as List).length;
    }
    return 0;
  }

  static Map<String, dynamic> toBackendJson(ClassModel classModel) {
    return {
      'name': classModel.name,
      'departmentId': classModel.departmentId,
    };
  }
}

class BackendDepartmentAdapter {
  static DepartmentModel fromBackendJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? json['name'] ?? '',
      description: json['description'],
      classIds: _getClassIds(json),
      totalClasses: _getTotalClasses(json),
      totalStudents: _getTotalStudents(json),
      totalTeachers: _getTotalTeachers(json),
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ??
          json['createdAt'] ??
          DateTime.now().toIso8601String()),
    );
  }

  static List<String> _getClassIds(Map<String, dynamic> json) {
    if (json['classes'] != null && json['classes'] is List) {
      return (json['classes'] as List)
          .map((cls) => cls['id'].toString())
          .toList();
    }
    return [];
  }

  static int _getTotalClasses(Map<String, dynamic> json) {
    if (json['_count'] != null && json['_count']['classes'] != null) {
      return json['_count']['classes'];
    }
    if (json['totalClasses'] != null) {
      return json['totalClasses'];
    }
    if (json['classes'] != null && json['classes'] is List) {
      return (json['classes'] as List).length;
    }
    return 0;
  }

  static int _getTotalStudents(Map<String, dynamic> json) {
    if (json['_count'] != null && json['_count']['students'] != null) {
      return (json['_count']['students'] as num).toInt();
    }
    if (json['totalStudents'] != null) {
      return (json['totalStudents'] as num).toInt();
    }
    // Count students from classes if available
    if (json['classes'] != null && json['classes'] is List) {
      int total = 0;
      for (var classData in json['classes']) {
        if (classData['students'] != null && classData['students'] is List) {
          total += (classData['students'] as List).length;
        } else if (classData['_count'] != null &&
            classData['_count']['students'] != null) {
          total += (classData['_count']['students'] as num).toInt();
        }
      }
      return total;
    }
    return 0;
  }

  static int _getTotalTeachers(Map<String, dynamic> json) {
    if (json['_count'] != null && json['_count']['users'] != null) {
      return json['_count']['users'];
    }
    if (json['totalTeachers'] != null) {
      return json['totalTeachers'];
    }
    return 0;
  }
}
