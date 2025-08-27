// lib/core/services/permission_service.dart
import '../models/user_model.dart';

class PermissionService {
  static const PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  const PermissionService._internal();

  // USER MANAGEMENT PERMISSIONS
  bool canCreateUser(UserModel currentUser) {
    return currentUser.role == UserRole.admin;
  }

  bool canDeleteUser(UserModel currentUser, UserModel targetUser) {
    return currentUser.role == UserRole.admin &&
        currentUser.id != targetUser.id; // Không thể xóa chính mình
  }

  bool canEditUser(UserModel currentUser, UserModel targetUser) {
    // Admin có thể edit tất cả
    if (currentUser.role == UserRole.admin) return true;

    // User có thể edit profile của mình (trừ role và department)
    return currentUser.id == targetUser.id;
  }

  bool canChangeUserRole(UserModel currentUser) {
    return currentUser.role == UserRole.admin;
  }

  // DEPARTMENT PERMISSIONS
  bool canViewAllDepartments(UserModel currentUser) {
    return currentUser.role == UserRole.admin;
  }

  bool canViewDepartment(UserModel currentUser, String departmentName) {
    if (currentUser.role == UserRole.admin) return true;
    return currentUser.department == departmentName;
  }

  bool canManageDepartment(UserModel currentUser, String departmentName) {
    if (currentUser.role == UserRole.admin) return true;
    return currentUser.role == UserRole.department &&
        currentUser.department == departmentName;
  }

  // CLASS PERMISSIONS
  bool canViewClass(
      UserModel currentUser, String className, String department) {
    switch (currentUser.role) {
      case UserRole.admin:
        return true;
      case UserRole.department:
        return currentUser.department == department;
      case UserRole.teacher:
        return currentUser.className == className;
    }
  }

  bool canManageClass(UserModel currentUser, String department) {
    if (currentUser.role == UserRole.admin) return true;
    return currentUser.role == UserRole.department &&
        currentUser.department == department;
  }

  bool canCreateClass(UserModel currentUser, String department) {
    return canManageClass(currentUser, department);
  }

  bool canDeleteClass(UserModel currentUser, String department) {
    return canManageClass(currentUser, department);
  }

  // STUDENT PERMISSIONS
  bool canViewStudent(
      UserModel currentUser, String studentClass, String studentDepartment) {
    switch (currentUser.role) {
      case UserRole.admin:
        return true;
      case UserRole.department:
        return currentUser.department == studentDepartment;
      case UserRole.teacher:
        return currentUser.className == studentClass;
    }
  }

  bool canManageStudent(
      UserModel currentUser, String studentClass, String studentDepartment) {
    switch (currentUser.role) {
      case UserRole.admin:
        return true;
      case UserRole.department:
        return currentUser.department == studentDepartment;
      case UserRole.teacher:
        return currentUser.className == studentClass;
    }
  }

  bool canCreateStudent(UserModel currentUser, String targetDepartment) {
    if (currentUser.role == UserRole.admin) return true;
    return currentUser.role == UserRole.department &&
        currentUser.department == targetDepartment;
  }

  bool canDeleteStudent(UserModel currentUser, String studentDepartment) {
    if (currentUser.role == UserRole.admin) return true;
    return currentUser.role == UserRole.department &&
        currentUser.department == studentDepartment;
  }

  // ATTENDANCE & GRADES PERMISSIONS
  bool canUpdateAttendance(UserModel currentUser, String studentClass) {
    switch (currentUser.role) {
      case UserRole.admin:
        return true;
      case UserRole.department:
        return true; // Department có thể update attendance của ngành mình
      case UserRole.teacher:
        return currentUser.className == studentClass;
    }
  }

  bool canUpdateGrades(UserModel currentUser, String studentClass) {
    switch (currentUser.role) {
      case UserRole.admin:
        return true;
      case UserRole.department:
        return true;
      case UserRole.teacher:
        return currentUser.className == studentClass;
    }
  }

  // STATISTICS PERMISSIONS
  bool canViewAllStats(UserModel currentUser) {
    return currentUser.role == UserRole.admin;
  }

  bool canViewDepartmentStats(UserModel currentUser, String department) {
    if (currentUser.role == UserRole.admin) return true;
    return currentUser.department == department;
  }

  bool canViewClassStats(
      UserModel currentUser, String className, String department) {
    return canViewClass(currentUser, className, department);
  }

  // EXPORT PERMISSIONS
  bool canExportAllData(UserModel currentUser) {
    return currentUser.role == UserRole.admin;
  }

  bool canExportDepartmentData(UserModel currentUser, String department) {
    return canViewDepartment(currentUser, department);
  }

  bool canExportClassData(
      UserModel currentUser, String className, String department) {
    return canViewClass(currentUser, className, department);
  }

  // UI NAVIGATION PERMISSIONS
  List<String> getAvailableRoutes(UserModel currentUser) {
    final routes = <String>['/dashboard'];

    switch (currentUser.role) {
      case UserRole.admin:
        routes.addAll([
          '/admin/accounts',
          '/admin/accounts/add',
          '/admin/stats',
        ]);
        // Admin có thể access tất cả departments
        for (final dept in ['Chiên', 'Âu', 'Thiếu', 'Nghĩa']) {
          routes.add('/classes/$dept');
        }
        break;

      case UserRole.department:
        routes.add('/classes/${currentUser.department}');
        routes.add('/department/stats');
        break;

      case UserRole.teacher:
        if (currentUser.className != null) {
          routes.add('/students/${currentUser.className}');
        }
        break;
    }

    return routes;
  }

  // Helper methods
  bool hasAdminAccess(UserModel currentUser) {
    return currentUser.role == UserRole.admin;
  }

  bool hasDepartmentAccess(UserModel currentUser, String department) {
    return hasAdminAccess(currentUser) || currentUser.department == department;
  }

  bool hasClassAccess(UserModel currentUser, String className) {
    return hasAdminAccess(currentUser) || currentUser.className == className;
  }
}
