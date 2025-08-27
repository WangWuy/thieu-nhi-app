// lib/features/dashboard/bloc/dashboard_state.dart - UPDATED
import 'package:equatable/equatable.dart';
import '../../../core/models/class_model.dart';
import '../../../core/models/department_model.dart';
import '../../../core/models/user_model.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final Map<String, dynamic> stats;
  final List<DepartmentModel> departments;
  final List<ClassModel> classes;
  final DateTime lastUpdated;

  const DashboardLoaded({
    required this.stats,
    required this.departments,
    required this.classes,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [stats, departments, classes, lastUpdated];

  DashboardLoaded copyWith({
    Map<String, dynamic>? stats,
    List<DepartmentModel>? departments,
    List<ClassModel>? classes,
    DateTime? lastUpdated,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      departments: departments ?? this.departments,
      classes: classes ?? this.classes,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

// NEW: Extended state with teachers data
class DashboardLoadedWithTeachers extends DashboardState {
  final Map<String, dynamic> stats;
  final List<DepartmentModel> departments;
  final List<ClassModel> classes;
  final List<UserModel> teachers;
  final DateTime lastUpdated;

  const DashboardLoadedWithTeachers({
    required this.stats,
    required this.departments,
    required this.classes,
    required this.teachers,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props =>
      [stats, departments, classes, teachers, lastUpdated];

  DashboardLoadedWithTeachers copyWith({
    Map<String, dynamic>? stats,
    List<DepartmentModel>? departments,
    List<ClassModel>? classes,
    List<UserModel>? teachers,
    DateTime? lastUpdated,
  }) {
    return DashboardLoadedWithTeachers(
      stats: stats ?? this.stats,
      departments: departments ?? this.departments,
      classes: classes ?? this.classes,
      teachers: teachers ?? this.teachers,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;
  final String? errorCode;

  const DashboardError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class DashboardRefreshing extends DashboardState {
  final DashboardState previousState;

  const DashboardRefreshing(this.previousState);

  @override
  List<Object?> get props => [previousState];
}
