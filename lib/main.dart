// lib/main.dart - UPDATED FOR API SERVICES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thieu_nhi_app/core/services/auth_service.dart';
import 'package:thieu_nhi_app/core/services/dashboard_service.dart';
import 'package:thieu_nhi_app/core/services/student_service.dart';
import 'package:thieu_nhi_app/core/services/class_service.dart';
import 'package:thieu_nhi_app/core/services/attendance_service.dart';
import 'package:thieu_nhi_app/core/services/http_client.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_bloc.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_bloc.dart';
import 'package:thieu_nhi_app/features/attendance/screens/qr_scanner_screen.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_event.dart';
import 'package:thieu_nhi_app/features/classes/bloc/classes_bloc.dart';
import 'package:thieu_nhi_app/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:thieu_nhi_app/features/students/bloc/students_bloc.dart';
import 'package:thieu_nhi_app/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Set system UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Initialize HTTP Client
  await HttpClient().init();

  // Initialize services
  await AuthService().init();

  runApp(const ThieuNhiApp());
}

class ThieuNhiApp extends StatelessWidget {
  const ThieuNhiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final studentService = StudentService();
    final classService = ClassService();
    final attendanceService = AttendanceService();
    final dashboardService = DashboardService();

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authService: authService,
          )..add(AuthCheckRequested()),
        ),
        BlocProvider<DashboardBloc>(
          create: (context) =>
              DashboardBloc(dashboardService: dashboardService),
        ),
        BlocProvider<ClassesBloc>(
          create: (context) => ClassesBloc(
            classService: classService, // Your existing ClassService
          ),
        ),
        BlocProvider<AdminBloc>(
          create: (context) => AdminBloc(
            authService: authService,
          ),
        ),
        // ✅ ADD BACK StudentsBloc - Global scope
        BlocProvider<StudentsBloc>(
          create: (context) => StudentsBloc(
            studentService: studentService,
            classService: classService,
            attendanceService: attendanceService,
          ),
        ),
        BlocProvider<AttendanceBloc>(
          create: (context) => AttendanceBloc(
            attendanceService: AttendanceService(),
          ),
          child: QRScannerScreen(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Thiếu Nhi Giáo xứ Thiên Ân',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
