// lib/features/auth/bloc/auth_bloc.dart - UPDATED FOR API SERVICES
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<AuthAppStarted>(_onAppStarted);
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUpdateProfileRequested>(_onUpdateProfileRequested);
    on<AuthChangePasswordRequested>(_onChangePasswordRequested);
    on<AuthAvatarUploadRequested>(_onAvatarUploadRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final shouldShowLoading = state is! AuthAuthenticated;
    if (shouldShowLoading) {
      emit(AuthLoading());
    }

    try {
      // Check if user is authenticated via API
      final user = await _authService.getCurrentUser();

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      // If token is invalid/expired, user needs to login again
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final result = await _authService.login(
        username: event.username,
        password: event.password,
      );

      if (result.isSuccess) {
        emit(AuthAuthenticated(user: result.user!));
      } else {
        emit(AuthError(result.error ?? 'Đăng nhập thất bại'));
      }
    } catch (e) {
      emit(AuthError('Lỗi đăng nhập: ${e.toString()}'));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Even if logout API fails, clear local auth state
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    final currentState = state as AuthAuthenticated;

    try {
      // Update user profile via API
      final updatedUser =
          await _authService.updateUserProfile(currentState.user.id, {
        'fullName': event.updatedUser.fullName,
        'saintName': event.updatedUser.saintName,
        'phoneNumber': event.updatedUser.phoneNumber,
        'address': event.updatedUser.address,
        'birthDate': event.updatedUser.birthDate?.toIso8601String(),
      });

      if (updatedUser != null) {
        emit(AuthAuthenticated(user: updatedUser));
      } else {
        // Keep current state if update fails
        emit(AuthAuthenticated(user: currentState.user));
        throw Exception('Không thể cập nhật thông tin');
      }
    } catch (e) {
      // Keep current state and rethrow for UI error handling
      emit(AuthAuthenticated(user: currentState.user));
      rethrow;
    }
  }

  Future<void> _onChangePasswordRequested(
    AuthChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) return;

    final currentState = state as AuthAuthenticated;

    try {
      final success = await _authService.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      if (success) {
        // Password changed successfully, keep user logged in
        emit(AuthAuthenticated(user: currentState.user));
      } else {
        emit(AuthAuthenticated(user: currentState.user));
        throw Exception('Không thể đổi mật khẩu');
      }
    } catch (e) {
      emit(AuthAuthenticated(user: currentState.user));
      rethrow;
    }
  }

  Future<void> _onAvatarUploadRequested(
    AuthAvatarUploadRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! AuthAuthenticated) {
      event.completer?.completeError(Exception('Chưa đăng nhập'));
      return;
    }

    final currentState = state as AuthAuthenticated;
    emit(AuthAvatarUpdating(user: currentState.user));

    try {
      final updatedUser = await _authService.uploadAvatar(event.avatarFile);
      emit(AuthAuthenticated(user: updatedUser));
      event.completer?.complete(updatedUser);
      return;
    } catch (e) {
      emit(AuthAuthenticated(user: currentState.user));
      event.completer?.completeError(e);
    }
  }

  Future<void> _onAppStarted(
    AuthAppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // Check if user has saved token and get current user
      final user = await _authService.getCurrentUser();

      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  // Helper getters
  bool get isAuthenticated => state is AuthAuthenticated;
  bool get isLoading => state is AuthLoading;
  UserModel? get currentUser =>
      state is AuthAuthenticated ? (state as AuthAuthenticated).user : null;

  // Helper methods
  bool hasRole(UserRole role) {
    final user = currentUser;
    return user?.role == role;
  }

  bool canAccessDepartment(String department) {
    final user = currentUser;
    if (user == null) return false;

    return user.role == UserRole.admin || user.department == department;
  }

  bool canAccessClass(String className) {
    final user = currentUser;
    if (user == null) return false;

    return user.role == UserRole.admin || user.className == className;
  }
}
