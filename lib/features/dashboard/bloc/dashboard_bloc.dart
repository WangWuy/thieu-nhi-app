// lib/features/dashboard/bloc/dashboard_bloc.dart - OPTIMIZED VERSION
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../core/services/dashboard_service.dart';
import '../../../core/models/department_model.dart';
import '../../../core/models/user_model.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardService _dashboardService;
  Timer? _refreshTimer;

  DashboardBloc({
    required DashboardService dashboardService,
  })  : _dashboardService = dashboardService,
        super(const DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<UpdateDashboardStats>(_onUpdateDashboardStats);

    // Setup periodic refresh
    _setupPeriodicRefresh();
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  // ✅ SUPER SIMPLE: Chỉ 1 API call!
  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    try {
      // 🎯 CHỈ 1 API CALL - lấy hết mọi thứ!
      final overview = await _dashboardService.getDashboardOverview();

      // ✅ Convert departmentStats từ dashboard API thành DepartmentModel
      final departments = overview.departmentStats.map((deptStat) {
        return DepartmentModel(
          id: int.tryParse(deptStat.id) ?? 0,
          name: deptStat.name,
          displayName: deptStat.displayName,
          description: null,
          classIds: [], // Không cần chi tiết
          totalClasses: deptStat.totalClasses,
          totalStudents: deptStat.totalStudents,
          totalTeachers: deptStat.totalTeachers,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      // ✅ Teacher count từ dashboard API
      final teacherCount = overview.usersByRole['giao_ly_vien'] ?? 0;
      
      // Tạo fake teacher list cho compatibility (nếu cần)
      final teachers = List.generate(teacherCount, (index) => 
        UserModel(
          id: 'teacher_$index',
          username: 'teacher_$index',
          email: 'teacher_$index@temp.com',
          role: UserRole.teacher,
          department: 'Unknown',
          className: null,
          classId: null,
          saintName: null,
          fullName: 'Giáo lý viên ${index + 1}',
          birthDate: null,
          phoneNumber: null,
          address: null,
          isActive: true,
          lastLogin: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
      );

      emit(DashboardLoadedWithTeachers(
        stats: overview.toJson(),
        departments: departments,
        classes: [], // Dashboard không cần class details
        teachers: teachers,
        lastUpdated: overview.lastUpdated,
      ));
    } catch (e) {
      emit(DashboardError(
        message: 'Không thể tải dữ liệu dashboard: ${e.toString()}',
        errorCode: 'LOAD_ERROR',
      ));
    }
  }

  // ✅ SUPER FAST REFRESH: Vẫn chỉ 1 API call
  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;

    // Show refreshing state
    if (currentState is DashboardLoadedWithTeachers) {
      emit(DashboardRefreshing(currentState));
    } else if (currentState is DashboardLoaded) {
      emit(DashboardRefreshing(currentState));
    }

    try {
      // 🚀 FAST: Use quick refresh method
      final overview = await _dashboardService.refreshDashboard();

      // Convert data như trên
      final departments = overview.departmentStats.map((deptStat) {
        return DepartmentModel(
          id: int.tryParse(deptStat.id) ?? 0,
          name: deptStat.name,
          displayName: deptStat.displayName,
          description: null,
          classIds: [],
          totalClasses: deptStat.totalClasses,
          totalStudents: deptStat.totalStudents,
          totalTeachers: deptStat.totalTeachers,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();

      final teacherCount = overview.usersByRole['giao_ly_vien'] ?? 0;
      final teachers = List.generate(teacherCount, (index) => 
        UserModel(
          id: 'teacher_$index',
          username: 'teacher_$index',
          email: 'teacher_$index@temp.com',
          role: UserRole.teacher,
          department: 'Unknown',
          className: null,
          classId: null,
          saintName: null,
          fullName: 'Giáo lý viên ${index + 1}',
          birthDate: null,
          phoneNumber: null,
          address: null,
          isActive: true,
          lastLogin: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )
      );

      emit(DashboardLoadedWithTeachers(
        stats: overview.toJson(),
        departments: departments,
        classes: [],
        teachers: teachers,
        lastUpdated: overview.lastUpdated,
      ));
    } catch (e) {
      // Revert to previous state if refresh fails
      if (currentState is DashboardLoadedWithTeachers) {
        emit(currentState);
      } else if (currentState is DashboardLoaded) {
        emit(currentState);
      } else {
        emit(DashboardError(
          message: 'Không thể làm mới dữ liệu: ${e.toString()}',
          errorCode: 'REFRESH_ERROR',
        ));
      }
    }
  }

  Future<void> _onUpdateDashboardStats(
    UpdateDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;

    if (currentState is DashboardLoadedWithTeachers) {
      emit(currentState.copyWith(
        stats: event.stats,
        lastUpdated: DateTime.now(),
      ));
    } else if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(
        stats: event.stats,
        lastUpdated: DateTime.now(),
      ));
    }
  }

  void _setupPeriodicRefresh() {
    // ✅ OPTIMIZED: Use quick counts for background refresh
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (!isClosed &&
          (state is DashboardLoaded || state is DashboardLoadedWithTeachers)) {
        _quickRefreshStatsOnly();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _quickRefreshStatsOnly() async {
    try {
      // 🚀 SUPER FAST: Use quick counts API
      final quickCounts = await _dashboardService.getQuickCounts();
      
      if (quickCounts.hasData) {
        final currentState = state;
        if (currentState is DashboardLoadedWithTeachers) {
          final updatedStats = Map<String, dynamic>.from(currentState.stats);
          updatedStats['totalClasses'] = quickCounts.totalClasses;
          updatedStats['totalStudents'] = quickCounts.totalStudents;
          
          add(UpdateDashboardStats(updatedStats));
        }
      }
    } catch (e) {
      // Silently fail for background refresh
    }
  }

  // Helper methods for UI
  bool get isLoading => state is DashboardLoading;
  bool get hasError => state is DashboardError;
  bool get isRefreshing => state is DashboardRefreshing;

  Map<String, dynamic>? get currentStats {
    final currentState = state;
    if (currentState is DashboardLoadedWithTeachers) {
      return currentState.stats;
    } else if (currentState is DashboardLoaded) {
      return currentState.stats;
    } else if (currentState is DashboardRefreshing) {
      final prevState = currentState.previousState;
      if (prevState is DashboardLoadedWithTeachers) {
        return prevState.stats;
      } else if (prevState is DashboardLoaded) {
        return prevState.stats;
      }
    }
    return null;
  }

  List<DepartmentModel> get departments {
    final currentState = state;
    if (currentState is DashboardLoadedWithTeachers) {
      return currentState.departments;
    } else if (currentState is DashboardLoaded) {
      return currentState.departments;
    } else if (currentState is DashboardRefreshing) {
      final prevState = currentState.previousState;
      if (prevState is DashboardLoadedWithTeachers) {
        return prevState.departments;
      } else if (prevState is DashboardLoaded) {
        return prevState.departments;
      }
    }
    return [];
  }

  List<UserModel> get teachers {
    final currentState = state;
    if (currentState is DashboardLoadedWithTeachers) {
      return currentState.teachers;
    } else if (currentState is DashboardRefreshing) {
      final prevState = currentState.previousState;
      if (prevState is DashboardLoadedWithTeachers) {
        return prevState.teachers;
      }
    }
    return [];
  }

  // Quick access methods for stats
  int get totalStudents => currentStats?['totalStudents'] ?? 0;
  int get totalClasses => currentStats?['totalClasses'] ?? 0;
  int get totalTeachers => currentStats?['totalTeachers'] ?? 0;
  int get presentToday => currentStats?['presentToday'] ?? 0;
  int get absentToday => currentStats?['absentToday'] ?? 0;
  double get attendanceRate => currentStats?['attendanceRate'] ?? 0.0;
}