// lib/core/router/app_router.dart - UPDATED WITH MANUAL ATTENDANCE ROUTE
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thieu_nhi_app/core/models/department_model.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/widgets/protected_route_wrapper.dart';
import 'package:thieu_nhi_app/features/admin/screens/account_management_screen.dart';
import 'package:thieu_nhi_app/features/admin/screens/add_account_screen.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/classes/screens/classes_screen.dart';
import 'package:thieu_nhi_app/features/main/screens/main_layout_screen.dart';
import 'package:thieu_nhi_app/features/students/screens/add_student_screen.dart';
import 'package:thieu_nhi_app/features/students/screens/edit_student_screen.dart';
import 'package:thieu_nhi_app/features/students/screens/student_detail_screen.dart';
import 'package:thieu_nhi_app/features/students/screens/student_list_screen.dart';
import 'package:thieu_nhi_app/features/attendance/screens/qr_scanner_screen.dart';
import 'package:thieu_nhi_app/features/attendance/screens/manual_attendance_screen.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_bloc.dart';
import 'package:thieu_nhi_app/core/services/attendance_service.dart';

import '../../features/auth/screens/login_screen.dart';
import '../widgets/auth_wrapper.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final authBloc = context.read<AuthBloc>();
      final authState = authBloc.state;

      if (state.uri.toString() == '/login' && authState is AuthAuthenticated) {
        return '/dashboard';
      }

      if (authState is AuthUnauthenticated &&
          state.uri.toString() != '/login') {
        return '/login';
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Protected routes
      ShellRoute(
        builder: (context, state, child) => AuthWrapper(child: child),
        routes: [
          // ==================== MAIN LAYOUT ====================
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const MainLayoutScreen(),
          ),

          // ==================== ATTENDANCE ROUTES ====================
          GoRoute(
            path: '/qr-scanner',
            name: 'qr-scanner-standalone',
            builder: (context, state) => BlocProvider(
              create: (context) => AttendanceBloc(
                attendanceService: AttendanceService(),
              ),
              child: const QRScannerScreen(),
            ),
          ),

          // ✅ NEW: Manual attendance standalone route
          GoRoute(
            path: '/manual-attendance',
            name: 'manual-attendance-standalone',
            builder: (context, state) => BlocProvider(
              create: (context) => AttendanceBloc(
                attendanceService: AttendanceService(),
              ),
              child: const ManualAttendanceScreen(),
            ),
          ),

          // ==================== DEPARTMENT CLASSES ====================
          GoRoute(
            path: '/classes/:departmentId',
            name: 'classes',
            builder: (context, state) {
              final departmentId = state.pathParameters['departmentId']!;
              final department = state.extra as DepartmentModel?;

              if (department == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Lỗi')),
                  body: const Center(
                      child: Text('Không tìm thấy thông tin ngành')),
                );
              }

              return ProtectedRouteWrapper(
                allowedRoles: [UserRole.admin, UserRole.department],
                requiredDepartment: department.name,
                child: ClassesScreen(department: department),
              );
            },
          ),

          // ==================== STUDENT ROUTES ====================
          GoRoute(
            path: '/students/:classId',
            name: 'students',
            builder: (context, state) {
              final classId = state.pathParameters['classId']!;
              final className = state.uri.queryParameters['className'] ?? '';
              final department = state.uri.queryParameters['department'] ?? '';
              final returnTo = state.uri.queryParameters['returnTo'];
              
              return StudentListScreen(
                classId: classId,
                className: className,
                department: department,
                returnTo: returnTo,
              );
            },
          ),

          GoRoute(
            path: '/student/:studentId',
            name: 'student-detail',
            builder: (context, state) {
              final studentId = state.pathParameters['studentId']!;
              return StudentDetailScreen(studentId: studentId);
            },
          ),

          GoRoute(
            path: '/student/:studentId/edit',
            name: 'edit-student',
            builder: (context, state) {
              final studentId = state.pathParameters['studentId']!;
              final studentData = state.extra as StudentModel?;

              if (studentData == null) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Lỗi')),
                  body: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('Không tìm thấy dữ liệu thiếu nhi'),
                      ],
                    ),
                  ),
                );
              }

              return EditStudentScreen(student: studentData);
            },
          ),

          GoRoute(
            path: '/add-student/:classId',
            name: 'add-student',
            builder: (context, state) {
              final classId = state.pathParameters['classId']!;
              final className = state.uri.queryParameters['className'] ?? '';
              final department = state.uri.queryParameters['department'] ?? '';

              return AddStudentScreen(
                classId: classId,
                className: className,
                department: department,
              );
            },
          ),

          // ==================== ADMIN ROUTES ====================
          GoRoute(
            path: '/admin/accounts',
            name: 'account-management',
            builder: (context, state) => ProtectedRouteWrapper(
              allowedRoles: [UserRole.admin],
              child: const AccountManagementScreen(),
            ),
          ),

          GoRoute(
            path: '/admin/accounts/add',
            name: 'add-account',
            builder: (context, state) => ProtectedRouteWrapper(
              allowedRoles: [UserRole.admin],
              child: const AddAccountScreen(),
            ),
          ),

          GoRoute(
            path: '/admin/accounts/edit/:userId',
            name: 'edit-account',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              final accountData = state.extra as UserModel?;

              return ProtectedRouteWrapper(
                allowedRoles: [UserRole.admin],
                child: AddAccountScreen(accountData: accountData),
              );
            },
          ),

          // ==================== STATS ROUTES ====================
          GoRoute(
            path: '/department/:department/stats',
            name: 'department-stats',
            builder: (context, state) {
              final department = state.pathParameters['department']!;
              return ProtectedRouteWrapper(
                allowedRoles: [UserRole.admin, UserRole.department],
                requiredDepartment: department,
                child: DepartmentStatsScreen(department: department),
              );
            },
          ),

          GoRoute(
            path: '/teacher/class/:className',
            name: 'teacher-class',
            builder: (context, state) {
              final className = state.pathParameters['className']!;
              return ProtectedRouteWrapper(
                allowedRoles: [UserRole.teacher],
                requiredClass: className,
                child: TeacherClassScreen(className: className),
              );
            },
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Color(0xFFDC3545),
              ),
              const SizedBox(height: 16),
              const Text(
                'Không tìm thấy trang',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC3545),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Đường dẫn "${state.uri}" không tồn tại',
                style: const TextStyle(
                  color: Color(0xFF6C757D),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC3545),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Placeholder screens (giữ nguyên)
class DepartmentStatsScreen extends StatelessWidget {
  final String department;
  const DepartmentStatsScreen({super.key, required this.department});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Thống kê ngành $department')),
      body: Center(
        child: Text('Thống kê ngành $department đang được phát triển'),
      ),
    );
  }
}

class TeacherClassScreen extends StatelessWidget {
  final String className;
  const TeacherClassScreen({super.key, required this.className});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Lớp $className')),
      body: Center(
        child: Text('Giao diện lớp $className đang được phát triển'),
      ),
    );
  }
}