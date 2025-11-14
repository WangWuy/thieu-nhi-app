// lib/features/admin/bloc/admin_event.dart - UPDATED FOR API SERVICES
import 'dart:io';

import 'package:equatable/equatable.dart';
import '../../../core/models/user_model.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllUsers extends AdminEvent {
  final int? page;
  final int? limit;
  final int? departmentId; // Thêm này

  const LoadAllUsers({this.page, this.limit, this.departmentId});

  @override
  List<Object?> get props => [page, limit, departmentId];
}

class LoadUsersByRole extends AdminEvent {
  final UserRole role;

  const LoadUsersByRole(this.role);

  @override
  List<Object?> get props => [role];
}

class LoadUsersByDepartment extends AdminEvent {
  final String department;

  const LoadUsersByDepartment(this.department);

  @override
  List<Object?> get props => [department];
}

// NEW: Search users event
class SearchUsers extends AdminEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object?> get props => [query];
}

class CreateUser extends AdminEvent {
  final UserModel user;
  final String password;
  final File? avatarFile;

  const CreateUser({
    required this.user,
    required this.password,
    this.avatarFile,
  });

  @override
  List<Object?> get props => [user, password, avatarFile?.path];
}

class UpdateUser extends AdminEvent {
  final UserModel user;
  final File? avatarFile;

  const UpdateUser(this.user, {this.avatarFile});

  @override
  List<Object?> get props => [user, avatarFile?.path];
}

class DeleteUser extends AdminEvent {
  final String userId;

  const DeleteUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ActivateUser extends AdminEvent {
  final String userId;

  const ActivateUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class DeactivateUser extends AdminEvent {
  final String userId;

  const DeactivateUser(this.userId);

  @override
  List<Object?> get props => [userId];
}

class ResetUserPassword extends AdminEvent {
  final String userId;
  final String newPassword; // NEW: Include new password for API

  const ResetUserPassword({
    required this.userId,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [userId, newPassword];
}

class BulkUpdateUsers extends AdminEvent {
  final List<BulkOperation> operations;

  const BulkUpdateUsers(this.operations);

  @override
  List<Object?> get props => [operations];
}

class RefreshUsers extends AdminEvent {
  const RefreshUsers();
}

// NEW: Load more users for pagination
class LoadMoreUsers extends AdminEvent {
  final int page;

  const LoadMoreUsers(this.page);

  @override
  List<Object?> get props => [page];
}

// NEW: Filter users event  
class FilterUsers extends AdminEvent {
  final UserFilter filter;

  const FilterUsers(this.filter);

  @override
  List<Object?> get props => [filter];
}

// Bulk operation model
class BulkOperation extends Equatable {
  final String userId;
  final BulkOperationType type;

  const BulkOperation({
    required this.userId,
    required this.type,
  });

  @override
  List<Object?> get props => [userId, type];
}

enum BulkOperationType {
  activate,
  deactivate,
  delete,
}

enum UserOperationType {
  create,
  update,
  delete,
  activate,
  deactivate,
  resetPassword,
  bulkUpdate,
}

// NEW: User filter model
class UserFilter extends Equatable {
  final UserRole? role;
  final String? department;
  final bool? isActive;
  final UserSortBy sortBy;
  final bool isDescending;

  const UserFilter({
    this.role,
    this.department,
    this.isActive,
    this.sortBy = UserSortBy.name,
    this.isDescending = false,
  });

  UserFilter copyWith({
    UserRole? role,
    String? department,
    bool? isActive,
    UserSortBy? sortBy,
    bool? isDescending,
  }) {
    return UserFilter(
      role: role ?? this.role,
      department: department ?? this.department,
      isActive: isActive ?? this.isActive,
      sortBy: sortBy ?? this.sortBy,
      isDescending: isDescending ?? this.isDescending,
    );
  }

  @override
  List<Object?> get props => [role, department, isActive, sortBy, isDescending];
}

enum UserSortBy {
  name,
  role,
  department,
  createdAt,
  lastLogin,
}
