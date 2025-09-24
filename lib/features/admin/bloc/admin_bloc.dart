// lib/features/admin/bloc/admin_bloc.dart - UPDATED FOR API SERVICES
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_model.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AuthService _authService;
  Timer? _refreshTimer;

  AdminBloc({
    required AuthService authService,
  })  : _authService = authService,
        super(const AdminInitial()) {
    on<LoadAllUsers>(_onLoadAllUsers);
    on<LoadUsersByRole>(_onLoadUsersByRole);
    on<LoadUsersByDepartment>(_onLoadUsersByDepartment);
    on<CreateUser>(_onCreateUser);
    on<UpdateUser>(_onUpdateUser);
    on<DeleteUser>(_onDeleteUser);
    on<ActivateUser>(_onActivateUser);
    on<DeactivateUser>(_onDeactivateUser);
    on<ResetUserPassword>(_onResetUserPassword);
    on<BulkUpdateUsers>(_onBulkUpdateUsers);
    on<RefreshUsers>(_onRefreshUsers);
    on<SearchUsers>(_onSearchUsers);
    
    // Setup periodic refresh
    _setupPeriodicRefresh();
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }

  void _setupPeriodicRefresh() {
    // Refresh users every 10 minutes
    _refreshTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      if (!isClosed && state is AdminLoaded) {
        add(const RefreshUsers());
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _onLoadAllUsers(
    LoadAllUsers event,
    Emitter<AdminState> emit,
  ) async {
    // Only show loading if no data exists
    if (state is! AdminLoaded) {
      emit(const AdminLoading());
    }

    try {
      final users = await _authService.getUsers(
        page: event.page ?? 1,
        limit: event.limit ?? 20,
        departmentId: event.departmentId,
      );

      emit(AdminLoaded(
        users: users,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(AdminError(
        message: 'Không thể tải danh sách người dùng: ${e.toString()}',
        errorCode: 'LOAD_USERS_ERROR',
      ));
    }
  }

  Future<void> _onLoadUsersByRole(
    LoadUsersByRole event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    try {
      final users = await _authService.getUsers(
        roleFilter: _roleToBackendString(event.role),
        limit: 100,
      );

      emit(AdminLoaded(
        users: users,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(AdminError(
        message: 'Không thể tải danh sách ${event.role.displayName}: ${e.toString()}',
        errorCode: 'LOAD_USERS_BY_ROLE_ERROR',
      ));
    }
  }

  Future<void> _onLoadUsersByDepartment(
    LoadUsersByDepartment event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    try {
      // Load all users and filter by department on client side
      // TODO: Implement department filter in API
      final users = await _authService.getUsers(limit: 50);
      
      final filteredUsers = users.where((user) => 
          user.department.toLowerCase() == event.department.toLowerCase()
      ).toList();

      emit(AdminLoaded(
        users: filteredUsers,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(AdminError(
        message: 'Không thể tải danh sách ngành ${event.department}: ${e.toString()}',
        errorCode: 'LOAD_USERS_BY_DEPARTMENT_ERROR',
      ));
    }
  }

  Future<void> _onCreateUser(
    CreateUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final userModel = await _authService.createUser(
        username: event.user.username,
        password: event.password,
        role: _roleToBackendString(event.user.role),
        fullName: event.user.fullName ?? event.user.username,
        saintName: event.user.saintName,
        phoneNumber: event.user.phoneNumber,
        address: event.user.address,
        departmentId: _getDepartmentId(event.user.department),
        birthDate: event.user.birthDate,
      );

      if (userModel != null) {
        emit(UserOperationSuccess(
          message: '''✅ Đã tạo tài khoản ${userModel.displayName} thành công!

👤 Username: ${userModel.username}
🔑 Mật khẩu: ${event.password}
📧 Vai trò: ${userModel.role.displayName}''',
          operationType: UserOperationType.create,
        ));
        
        // Refresh users list
        add(const RefreshUsers());
      } else {
        emit(const AdminError(
          message: 'Không thể tạo tài khoản',
          errorCode: 'CREATE_USER_FAILED',
        ));
      }
    } catch (e) {
      emit(AdminError(
        message: 'Lỗi khi tạo tài khoản: ${e.toString()}',
        errorCode: 'CREATE_USER_ERROR',
      ));
    }
  }

  Future<void> _onUpdateUser(
    UpdateUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final updateData = {
        'fullName': event.user.fullName,
        'saintName': event.user.saintName,
        'phoneNumber': event.user.phoneNumber,
        'address': event.user.address,
        'birthDate': event.user.birthDate?.toIso8601String(),
        'isActive': event.user.isActive,
      };

      final updatedUser = await _authService.updateUserProfile(
        event.user.id,
        updateData,
      );

      if (updatedUser != null) {
        emit(UserOperationSuccess(
          message: 'Đã cập nhật thông tin ${updatedUser.displayName}',
          operationType: UserOperationType.update,
        ));
        
        // Update local state immediately
        final currentState = state;
        if (currentState is AdminLoaded) {
          final updatedUsers = currentState.users.map((user) {
            return user.id == event.user.id ? updatedUser : user;
          }).toList();

          emit(currentState.copyWith(
            users: updatedUsers,
            lastUpdated: DateTime.now(),
          ));
        }
      } else {
        emit(const AdminError(
          message: 'Không thể cập nhật thông tin',
          errorCode: 'UPDATE_USER_FAILED',
        ));
      }
    } catch (e) {
      emit(AdminError(
        message: 'Không thể cập nhật thông tin: ${e.toString()}',
        errorCode: 'UPDATE_USER_ERROR',
      ));
    }
  }

  Future<void> _onDeleteUser(
    DeleteUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      // For API, we'll use deactivate instead of hard delete
      final success = await _authService.deactivateUser(event.userId);

      if (success) {
        emit(const UserOperationSuccess(
          message: 'Đã vô hiệu hóa tài khoản',
          operationType: UserOperationType.delete,
        ));
        
        // Refresh users list
        add(const RefreshUsers());
      } else {
        emit(const AdminError(
          message: 'Không thể xóa tài khoản',
          errorCode: 'DELETE_USER_FAILED',
        ));
      }
    } catch (e) {
      emit(AdminError(
        message: 'Không thể xóa tài khoản: ${e.toString()}',
        errorCode: 'DELETE_USER_ERROR',
      ));
    }
  }

  Future<void> _onActivateUser(
    ActivateUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final updateData = {'isActive': true};
      
      final updatedUser = await _authService.updateUserProfile(
        event.userId,
        updateData,
      );

      if (updatedUser != null) {
        emit(const UserOperationSuccess(
          message: 'Đã kích hoạt tài khoản',
          operationType: UserOperationType.activate,
        ));
        
        // Update local state
        final currentState = state;
        if (currentState is AdminLoaded) {
          final updatedUsers = currentState.users.map((user) {
            return user.id == event.userId 
                ? user.copyWith(isActive: true) 
                : user;
          }).toList();

          emit(currentState.copyWith(
            users: updatedUsers,
            lastUpdated: DateTime.now(),
          ));
        }
      }
    } catch (e) {
      emit(AdminError(
        message: 'Không thể kích hoạt tài khoản: ${e.toString()}',
        errorCode: 'ACTIVATE_USER_ERROR',
      ));
    }
  }

  Future<void> _onDeactivateUser(
    DeactivateUser event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final updateData = {'isActive': false};
      
      final updatedUser = await _authService.updateUserProfile(
        event.userId,
        updateData,
      );

      if (updatedUser != null) {
        emit(const UserOperationSuccess(
          message: 'Đã vô hiệu hóa tài khoản',
          operationType: UserOperationType.deactivate,
        ));
        
        // Update local state
        final currentState = state;
        if (currentState is AdminLoaded) {
          final updatedUsers = currentState.users.map((user) {
            return user.id == event.userId 
                ? user.copyWith(isActive: false) 
                : user;
          }).toList();

          emit(currentState.copyWith(
            users: updatedUsers,
            lastUpdated: DateTime.now(),
          ));
        }
      }
    } catch (e) {
      emit(AdminError(
        message: 'Không thể vô hiệu hóa tài khoản: ${e.toString()}',
        errorCode: 'DEACTIVATE_USER_ERROR',
      ));
    }
  }

  Future<void> _onResetUserPassword(
    ResetUserPassword event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final success = await _authService.resetPassword(
        event.userId,
        event.newPassword,
      );

      if (success) {
        emit(const UserOperationSuccess(
          message: 'Đã đặt lại mật khẩu thành công',
          operationType: UserOperationType.resetPassword,
        ));
      } else {
        emit(const AdminError(
          message: 'Không thể đặt lại mật khẩu',
          errorCode: 'RESET_PASSWORD_FAILED',
        ));
      }
    } catch (e) {
      emit(AdminError(
        message: 'Không thể đặt lại mật khẩu: ${e.toString()}',
        errorCode: 'RESET_PASSWORD_ERROR',
      ));
    }
  }

  Future<void> _onBulkUpdateUsers(
    BulkUpdateUsers event,
    Emitter<AdminState> emit,
  ) async {
    try {
      int successCount = 0;
      int failCount = 0;

      for (final operation in event.operations) {
        try {
          switch (operation.type) {
            case BulkOperationType.activate:
              await _authService.updateUserProfile(
                operation.userId, 
                {'isActive': true}
              );
              break;
            case BulkOperationType.deactivate:
              await _authService.updateUserProfile(
                operation.userId, 
                {'isActive': false}
              );
              break;
            case BulkOperationType.delete:
              await _authService.deactivateUser(operation.userId);
              break;
          }
          successCount++;
        } catch (e) {
          failCount++;
        }
      }

      emit(UserOperationSuccess(
        message: 'Hoàn thành: $successCount thành công, $failCount thất bại',
        operationType: UserOperationType.bulkUpdate,
      ));
      
      // Refresh users list
      add(const RefreshUsers());
    } catch (e) {
      emit(AdminError(
        message: 'Lỗi khi thực hiện thao tác hàng loạt: ${e.toString()}',
        errorCode: 'BULK_UPDATE_ERROR',
      ));
    }
  }

  Future<void> _onSearchUsers(
    SearchUsers event,
    Emitter<AdminState> emit,
  ) async {
    try {
      final users = await _authService.getUsers(
        search: event.query,
        limit: 100,
      );

      emit(AdminLoaded(
        users: users,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(AdminError(
        message: 'Không thể tìm kiếm người dùng: ${e.toString()}',
        errorCode: 'SEARCH_USERS_ERROR',
      ));
    }
  }

  Future<void> _onRefreshUsers(
    RefreshUsers event,
    Emitter<AdminState> emit,
  ) async {
    final currentState = state;
    if (currentState is AdminLoaded) {
      emit(AdminRefreshing(currentState));
    }

    // Reload all users
    add(const LoadAllUsers());
  }

  // Helper methods
  String _roleToBackendString(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'ban_dieu_hanh';
      case UserRole.department:
        return 'phan_doan_truong';
      case UserRole.teacher:
        return 'giao_ly_vien';
    }
  }

  int? _getDepartmentId(String departmentName) {
    // Map department names to IDs
    // TODO: Get this from API or make it dynamic
    switch (departmentName.toLowerCase()) {
      case 'chiên':
        return 1;
      case 'âu':
        return 2;
      case 'thiếu':
        return 3;
      case 'nghĩa':
        return 4;
      default:
        return null;
    }
  }

  // Helper getters
  bool get isLoading => state is AdminLoading;
  bool get hasError => state is AdminError;
  bool get isRefreshing => state is AdminRefreshing;
  
  List<UserModel> get users {
    final currentState = state;
    if (currentState is AdminLoaded) {
      return currentState.users;
    } else if (currentState is AdminRefreshing) {
      return currentState.previousState.users;
    }
    return [];
  }
}