// lib/features/dashboard/bloc/dashboard_event.dart - UPDATED
import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboardData extends DashboardEvent {
  const LoadDashboardData();
}

class RefreshDashboardData extends DashboardEvent {
  const RefreshDashboardData();
}

class UpdateDashboardStats extends DashboardEvent {
  final Map<String, dynamic> stats;

  const UpdateDashboardStats(this.stats);

  @override
  List<Object?> get props => [stats];
}

class LoadDepartmentData extends DashboardEvent {
  final String department;

  const LoadDepartmentData(this.department);

  @override
  List<Object?> get props => [department];
}

class LoadClassData extends DashboardEvent {
  final String classId;

  const LoadClassData(this.classId);

  @override
  List<Object?> get props => [classId];
}

// NEW: Load teachers data event
class LoadTeachersData extends DashboardEvent {
  const LoadTeachersData();
}
