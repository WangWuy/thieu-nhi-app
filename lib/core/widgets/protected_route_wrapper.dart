// lib/core/widgets/protected_route_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';
import '../models/user_model.dart';
import '../services/permission_service.dart';

class ProtectedRouteWrapper extends StatelessWidget {
  final Widget child;
  final List<UserRole>? allowedRoles;
  final String? requiredDepartment;
  final String? requiredClass;
  final String? fallbackRoute;

  const ProtectedRouteWrapper({
    super.key,
    required this.child,
    this.allowedRoles,
    this.requiredDepartment,
    this.requiredClass,
    this.fallbackRoute = '/dashboard',
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          // Chưa đăng nhập, redirect về login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const _LoadingScreen();
        }

        final user = state.user;
        final hasPermission = _checkPermission(user);

        if (!hasPermission) {
          return _UnauthorizedScreen(
            user: user,
            onGoBack: () => context.go(fallbackRoute!),
          );
        }

        return child;
      },
    );
  }

  bool _checkPermission(UserModel user) {
    final permissionService = PermissionService();

    // Check role permission
    if (allowedRoles != null && !allowedRoles!.contains(user.role)) {
      return false;
    }

    // Check department permission
    if (requiredDepartment != null) {
      if (!permissionService.hasDepartmentAccess(user, requiredDepartment!)) {
        return false;
      }
    }

    // Check class permission
    if (requiredClass != null) {
      if (!permissionService.hasClassAccess(user, requiredClass!)) {
        return false;
      }
    }

    return true;
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _UnauthorizedScreen extends StatelessWidget {
  final UserModel user;
  final VoidCallback onGoBack;

  const _UnauthorizedScreen({
    required this.user,
    required this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.primaryGradient,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Không có quyền truy cập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Tài khoản ${user.displayName} (${user.role.displayName}) không có quyền truy cập trang này.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: onGoBack,
                  icon: const Icon(Icons.home),
                  label: const Text('Về trang chủ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
