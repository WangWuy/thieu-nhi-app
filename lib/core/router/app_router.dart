// lib/core/router/app_router.dart - UPDATED WITH ENHANCED CLASSES ROUTE
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/core/widgets/protected_route_wrapper.dart';
import 'package:thieu_nhi_app/features/admin/screens/account_management_screen.dart';
import 'package:thieu_nhi_app/features/admin/screens/add_account_screen.dart';
import 'package:thieu_nhi_app/features/admin/screens/pending_users_screen.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/features/classes/screens/all_classes_screen.dart'; // NEW IMPORT
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
import '../../features/auth/screens/register_screen.dart';
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
          state.uri.toString() != '/login' &&
          state.uri.toString() != '/register') {
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

      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          return const RegisterScreen();
        },
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

          // 🆕 NEW: All Classes Route for Admin & Department
          GoRoute(
            path: '/classes/:filter',
            name: 'all-classes',
            builder: (context, state) {
              final filter = state.pathParameters['filter']!; // 'all' or department name
              
              return ProtectedRouteWrapper(
                allowedRoles: const [UserRole.admin, UserRole.department],
                child: AllClassesScreen(initialFilter: filter),
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
              final isTeacherView = state.extra != null && 
                  (state.extra as Map<String, dynamic>)['isTeacherView'] == true;

              return StudentListScreen(
                classId: classId,
                className: className,
                department: department,
                returnTo: returnTo,
                isTeacherView: isTeacherView, // NEW parameter
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
            builder: (context, state) => const ProtectedRouteWrapper(
              allowedRoles: [UserRole.admin],
              child: AccountManagementScreen(),
            ),
          ),

          GoRoute(
            path: '/admin/accounts/add',
            name: 'add-account',
            builder: (context, state) => const ProtectedRouteWrapper(
              allowedRoles: [UserRole.admin],
              child: AddAccountScreen(),
            ),
          ),

          GoRoute(
            path: '/admin/accounts/edit/:userId',
            name: 'edit-account',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              final accountData = state.extra as UserModel?;

              return ProtectedRouteWrapper(
                allowedRoles: const [UserRole.admin],
                child: AddAccountScreen(accountData: accountData),
              );
            },
          ),

          GoRoute(
            path: '/admin/pending-users',
            name: 'pending-users',
            builder: (context, state) => const ProtectedRouteWrapper(
              allowedRoles: [UserRole.admin],
              child: PendingUsersScreen(),
            ),
          ),

          // ==================== STATS ROUTES ====================
          GoRoute(
            path: '/department/:department/stats',
            name: 'department-stats',
            builder: (context, state) {
              final department = state.pathParameters['department']!;
              return ProtectedRouteWrapper(
                allowedRoles: const [UserRole.admin, UserRole.department],
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
                allowedRoles: const [UserRole.teacher],
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