import '../models/user_model.dart';
import '../models/attendance_models.dart';
import '../models/student_model.dart';
import '../models/class_model.dart';
import '../models/department_model.dart';

/// Improved Backend Adapter with better error handling and data validation
class BackendStudentAdapter {
  static StudentModel fromBackendJson(Map<String, dynamic> json) {
    try {
      final classData = json['class'] as Map<String, dynamic>?;
      final departmentData =
          classData?['department'] as Map<String, dynamic>?;
      final academicYear = json['academicYear'] as Map<String, dynamic>?;
      final attendanceRecords = (json['attendance'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(AttendanceRecord.fromJson)
          .toList();
      final calculatedStats =
          json['calculatedStats'] as Map<String, dynamic>?;
      final progressData =
          calculatedStats?['attendanceProgress'] as Map<String, dynamic>?;

      return StudentModel(
        id: json['id'].toString(),
        qrId: json['studentCode'],
        qrRawData: json['qrCode'],
        name: json['fullName'] ?? '',
        phone: json['phoneNumber'] ?? '',
        parentPhone: json['parentPhone1'] ?? '',
        address: json['address'] ?? '',
        birthDate: _parseDate(json['birthDate']) ??
            DateTime.now().subtract(const Duration(days: 3650)),
        classId: json['classId'].toString(),
        className: classData?['name'] ?? 'Unknown',
        department:
            departmentData?['displayName'] ?? departmentData?['name'] ?? 'Unknown',
        attendance: const {},
        grades: _parseGrades(json),
        note: json['note'],
        photoUrl: _getStudentPhoto(json),
        avatarUrl: _getStudentAvatar(json),
        avatarPublicId: json['avatarPublicId']?.toString(),
        isActive: json['isActive'],
        createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),

        // Backend specific fields
        saintName: json['saintName'],
        parentPhone2: json['parentPhone2'],
        thursdayAttendanceCount: _parseInt(json['thursdayAttendanceCount']),
        sundayAttendanceCount: _parseInt(json['sundayAttendanceCount']),
        attendanceAverage: _parseDouble(json['attendanceAverage']),
        study45Hk1: _parseDouble(json['study45Hk1']),
        examHk1: _parseDouble(json['examHk1']),
        study45Hk2: _parseDouble(json['study45Hk2']),
        examHk2: _parseDouble(json['examHk2']),
        studyAverage: _parseDouble(json['studyAverage']),
        finalAverage: _parseDouble(json['finalAverage']),
        academicYearId: json['academicYearId'] ?? academicYear?['id'],
        academicYearName: academicYear?['name'],
        academicYearTotalWeeks: academicYear?['totalWeeks'],
        academicYearStartDate: _parseDate(academicYear?['startDate']),
        academicYearEndDate: _parseDate(academicYear?['endDate']),
        academicYearIsActive: academicYear?['isActive'],
        academicYearIsCurrent: academicYear?['isCurrent'],
        thursdayScore: _parseDouble(json['thursdayScore']),
        sundayScore: _parseDouble(json['sundayScore']),
        thursdayProgress: progressData?['thursday'] != null
            ? AttendanceProgress.fromJson(
                Map<String, dynamic>.from(progressData!['thursday']))
            : null,
        sundayProgress: progressData?['sunday'] != null
            ? AttendanceProgress.fromJson(
                Map<String, dynamic>.from(progressData!['sunday']))
            : null,
        recentAttendance: attendanceRecords,
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
      qrId: json['studentCode'],
      qrRawData: json['qrCode'],
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
      photoUrl: null,
      avatarUrl: null,
      avatarPublicId: null,
      isActive: json['isActive'],
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

  static String? _getStudentPhoto(Map<String, dynamic> json) {
    final raw = json['photoUrl'] ?? json['photo'];
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static String? _getStudentAvatar(Map<String, dynamic> json) {
    final raw = json['avatarUrl'] ??
        json['avatar'] ??
        json['photoUrl'] ??
        json['photo'] ??
        json['profileImage'];
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }
}

// Extension for other adapters (keeping existing ones)
class BackendUserAdapter {
  static UserModel fromBackendJson(Map<String, dynamic> json) {
    final teacherClassInfo = _getTeacherClassInfo(json);

    return UserModel(
      id: json['id'].toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '${json['username']}@temp.com',
      role: _parseUserRole(json['role']),
      departmentId: json['departmentId'],
      department: _getDepartmentModel(json),
      classTeachers: _getClassTeachers(json),
      teacherClassId: teacherClassInfo?.classId,
      teacherClassName: teacherClassInfo?.className,
      teacherClassStudentCount: teacherClassInfo?.totalStudents,
      permissions: _getPermissions(json),
      saintName: json['saintName'],
      fullName: json['fullName'],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      avatarUrl: _getAvatarUrl(json),
      isActive: json['isActive'] ?? true,
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  static List<ClassTeacher> _getClassTeachers(Map<String, dynamic> json) {
    if (json['classTeachers'] != null && json['classTeachers'] is List) {
      return (json['classTeachers'] as List).map((ct) {
        final classData = ct['class'];
        return ClassTeacher(
          id: ct['id'].toString(),
          fullName: classData?['name'] ?? 'Unknown', // Use class name as fullName
          saintName: null,
          isPrimary: ct['isPrimary'] ?? false,
        );
      }).toList();
    }
    return [];
  }

  static DepartmentModel? _getDepartmentModel(Map<String, dynamic> json) {
    if (json['department'] != null && json['department'] is Map) {
      final dept = json['department'] as Map<String, dynamic>;
      return DepartmentModel(
        id: dept['id'],
        name: dept['name'] ?? '',
        displayName: dept['displayName'] ?? dept['name'] ?? '',
        description: dept['description'],
        classIds: [], // Empty for now
        totalClasses: 0,
        totalStudents: 0,
        totalTeachers: 0,
        isActive: dept['isActive'] ?? true,
        createdAt: DateTime.parse(dept['createdAt'] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(dept['updatedAt'] ?? DateTime.now().toIso8601String()),
      );
    }
    return null;
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

  static List<String> _getPermissions(Map<String, dynamic> json) {
    final permissions = json['permissions'];
    if (permissions is List) {
      return permissions
          .map((perm) => perm?.toString())
          .whereType<String>()
          .where((perm) => perm.isNotEmpty)
          .toList();
    }
    return const [];
  }

  // NEW: Get all classes for teacher (not just primary)
  static List<Map<String, dynamic>> getAllClasses(Map<String, dynamic> json) {
    final classes = <Map<String, dynamic>>[];
    
    if (json['classTeachers'] != null && json['classTeachers'] is List) {
      final classTeachers = json['classTeachers'] as List;
      
      for (final ct in classTeachers) {
        if (ct['class'] != null) {
          classes.add({
            'id': ct['class']['id'],
            'name': ct['class']['name'],
            'isPrimary': ct['isPrimary'] ?? false,
          });
        }
      }
    }
    
    return classes;
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
      'avatarUrl': user.avatarUrl,
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

  static _TeacherClassInfo? _getTeacherClassInfo(Map<String, dynamic> json) {
    final singleAssignment = _asMap(json['classTeacher']);
    if (singleAssignment != null) {
      final classData =
          _asMap(singleAssignment['classInfo']) ?? _asMap(singleAssignment['class']);
      if (classData != null) {
        return _TeacherClassInfo.fromJson(classData);
      }
    }

    if (json['classTeachers'] is List && (json['classTeachers'] as List).isNotEmpty) {
      final classTeachers = json['classTeachers'] as List;
      Map<String, dynamic>? selected;

      for (final item in classTeachers) {
        final mapItem = _asMap(item);
        if (mapItem == null) continue;

        if (mapItem['isPrimary'] == true) {
          selected = mapItem;
          break;
        }

        selected ??= mapItem;
      }

      final classData =
          _asMap(selected?['class']) ?? _asMap(selected?['classInfo']);
      if (classData != null) {
        return _TeacherClassInfo.fromJson(classData);
      }
    }

    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static String? _getAvatarUrl(Map<String, dynamic> json) {
    final raw = json['avatarUrl'] ??
        json['avatar'] ??
        json['avatarPath'] ??
        json['profileImage'];

    if (raw == null) return null;
    final value = raw.toString().trim();
    if (value.isEmpty) return null;
    return value;
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

class _TeacherClassInfo {
  final String? classId;
  final String? className;
  final int? totalStudents;

  _TeacherClassInfo({
    this.classId,
    this.className,
    this.totalStudents,
  });

  factory _TeacherClassInfo.fromJson(Map<String, dynamic> json) {
    final totalStudents =
        BackendUserAdapter._parseInt(json['totalStudents']) ??
            BackendUserAdapter._parseInt(
                BackendUserAdapter._asMap(json['_count'])?['students']) ??
            (json['students'] is List ? (json['students'] as List).length : null);

    return _TeacherClassInfo(
      classId: json['id']?.toString(),
      className: json['name'] ?? json['className'],
      totalStudents: totalStudents,
    );
  }
}
