// lib/features/dashboard/cubit/dashboard_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../core/services/dashboard_service.dart';
import '../../../core/models/dashboard_model.dart';

// States
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardData data;
  DashboardLoaded(this.data);
}

class DashboardRefreshing extends DashboardState {
  final DashboardData previousData;
  DashboardRefreshing(this.previousData);
}

class DashboardError extends DashboardState {
  final String message;
  final String? errorCode;

  DashboardError({required this.message, this.errorCode});
}

// Cubit
class DashboardCubit extends Cubit<DashboardState> {
  final DashboardService _service;
  Timer? _refreshTimer;

  DashboardCubit(this._service) : super(DashboardInitial()) {
    _startPeriodicRefresh();
  }

  // Load dashboard data
  void loadDashboard() async {
    if (state is! DashboardLoaded) {
      emit(DashboardLoading());
    }

    try {
      final data = await _service.getDashboard();
      emit(DashboardLoaded(data));
    } catch (e) {
      emit(DashboardError(
        message: 'Không thể tải dữ liệu dashboard: $e',
        errorCode: 'LOAD_ERROR',
      ));
    }
  }

  // Refresh dashboard data
  void refreshDashboard() async {
    final currentState = state;

    // Show refreshing state with previous data
    if (currentState is DashboardLoaded) {
      emit(DashboardRefreshing(currentState.data));
    }

    try {
      final data = await _service.getDashboard();
      emit(DashboardLoaded(data));
    } catch (e) {
      // Revert to previous state if refresh fails
      if (currentState is DashboardLoaded) {
        emit(currentState);
      } else {
        emit(DashboardError(
          message: 'Không thể làm mới dữ liệu: $e',
          errorCode: 'REFRESH_ERROR',
        ));
      }
    }
  }

  // Auto refresh every 5 minutes
  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(Duration(minutes: 5), (timer) {
      if (!isClosed && state is DashboardLoaded) {
        refreshDashboard();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  // Helper getters for UI
  bool get isLoading => state is DashboardLoading;
  bool get hasError => state is DashboardError;
  bool get isRefreshing => state is DashboardRefreshing;
  bool get hasData => state is DashboardLoaded || state is DashboardRefreshing;

  DashboardData? get currentData {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      return currentState.data;
    } else if (currentState is DashboardRefreshing) {
      return currentState.previousData;
    }
    return null;
  }
}
