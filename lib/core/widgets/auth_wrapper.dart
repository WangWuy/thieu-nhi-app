import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_bloc.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';

class AuthWrapper extends StatelessWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (BuildContext context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (BuildContext context, state) {
          // LOADING STATE - Simple loading
          if (state is AuthLoading || state is AuthInitial) {
            return _buildSimpleLoadingScreen();
          }

          // AUTH STATES
          if (state is AuthUnauthenticated) {
            return _buildSimpleLoadingScreen(); // Show loading while navigating
          }

          if (state is AuthAuthenticated) {
            return child;
          }

          if (state is AuthError) {
            return _buildErrorScreen(state.message);
          }

          return _buildSimpleLoadingScreen();
        },
      ),
    );
  }

  Widget _buildSimpleLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fixed logo sizing - Dùng logo thật thay vì icon
            Container(
              width: 100,  // Tăng size container
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16), // Tăng padding
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain, // QUAN TRỌNG: contain không crop
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback với icon nếu không load được logo
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC3545),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.church,
                        size: 40,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // App name
            const Text(
              'Thiếu Nhi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC3545),
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Giáo xứ Thiên Ân',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6C757D),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Simple loading
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDC3545)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(0xFFDC3545),
            ),
            const SizedBox(height: 16),
            const Text(
              'Lỗi khởi tạo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFDC3545),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF6C757D),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Builder(
              builder: (BuildContext context) {
                return ElevatedButton(
                  onPressed: () {
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC3545),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thử lại'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}