// lib/features/admin/bloc/admin_state.dart
import 'package:equatable/equatable.dart';
import '../../../core/models/user_model.dart';
import 'admin_event.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminLoaded extends AdminState {
  final List<UserModel> users;
  final DateTime lastUpdated;

  const AdminLoaded({
    required this.users,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [users, lastUpdated];

  AdminLoaded copyWith({
    List<UserModel>? users,
    DateTime? lastUpdated,
  }) {
    return AdminLoaded(
      users: users ?? this.users,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class AdminError extends AdminState {
  final String message;
  final String? errorCode;

  const AdminError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}

class UserOperationSuccess extends AdminState {
  final String message;
  final UserOperationType operationType;

  const UserOperationSuccess({
    required this.message,
    required this.operationType,
  });

  @override
  List<Object?> get props => [message, operationType];
}

class AdminRefreshing extends AdminState {
  final AdminLoaded previousState;

  const AdminRefreshing(this.previousState);

  @override
  List<Object?> get props => [previousState];
}
