// lib/main.dart - UPDATED FOR CUBIT ARCHITECTURE
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:thieu_nhi_app/core/services/auth_service.dart';
import 'package:thieu_nhi_app/core/services/student_service.dart';
import 'package:thieu_nhi_app/core/services/class_service.dart';
import 'package:thieu_nhi_app/core/services/attendance_service.dart';
import 'package:thieu_nhi_app/core/services/http_client.dart';
import 'package:thieu_nhi_app/features/admin/bloc/admin_bloc.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_event.dart';
import 'package:thieu_nhi_app/features/classes/bloc/classes_bloc.dart';
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

class ThieuNhiApp extends StatefulWidget {
  const ThieuNhiApp({super.key});

  @override
  State<ThieuNhiApp> createState() => _ThieuNhiAppState();
}

class _ThieuNhiAppState extends State<ThieuNhiApp> {
  final authService = AuthService();
  final studentService = StudentService();
  final classService = ClassService();
  final attendanceService = AttendanceService();
  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) async {
      final status =
          await AppTrackingTransparency.requestTrackingAuthorization();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC - Keep as global
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            authService: authService,
          )..add(const AuthCheckRequested()),
        ),

        // Classes BLoC - Keep as global for navigation
        BlocProvider<ClassesBloc>(
          create: (context) => ClassesBloc(
            classService: classService,
          ),
        ),

        // Admin BLoC - Keep as global
        BlocProvider<AdminBloc>(
          create: (context) => AdminBloc(
            authService: authService,
          ),
        ),

        // Students BLoC - Keep as global for cross-screen usage
        BlocProvider<StudentsBloc>(
          create: (context) => StudentsBloc(
            studentService: studentService,
            classService: classService,
            attendanceService: attendanceService,
          ),
        ),

        // Attendance BLoC - Keep as global for QR scanner
        BlocProvider<AttendanceBloc>(
          create: (context) => AttendanceBloc(
            attendanceService: AttendanceService(),
          ),
        ),

        // NOTE: DashboardCubit is now created locally in DashboardScreen
        // This reduces global state and improves performance
      ],
      child: MaterialApp.router(
        title: 'Thiếu Nhi Giáo xử Thiên Ân',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
