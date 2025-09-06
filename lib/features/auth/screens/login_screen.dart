// lib/features/auth/screens/login_screen.dart - SIMPLIFIED
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thieu_nhi_app/core/models/user_model.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_event.dart';
import 'package:thieu_nhi_app/features/auth/bloc/auth_state.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/login_header.dart';
import '../widgets/login_form.dart';
import '../widgets/login_footer.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            username: _usernameController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Quên mật khẩu',
          style: TextStyle(
            color: Color(0xFFDC143C),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Vui lòng liên hệ Ban Điều Hành để được hỗ trợ đặt lại mật khẩu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Đóng',
              style: TextStyle(color: Color(0xFFDC143C)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              _navigateBasedOnRole(state.user.role);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFFDC143C),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF8F9FA),
                  Color(0xFFFFFBF0),
                  Color(0xFFF5F5DC),
                  Color(0xFFE6F3FF),
                ],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.35,
                              child: LoginHeader(pulseAnimation: _pulseAnimation),
                            ),
                            LoginForm(
                              formKey: _formKey,
                              usernameController: _usernameController,
                              passwordController: _passwordController,
                              onLogin: _onLogin,
                              onForgotPassword: _showForgotPasswordDialog,
                            ),
                            const Spacer(),
                            const LoginFooter(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateBasedOnRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        context.go('/dashboard');
        _showWelcomeMessage('Chào mừng Ban Điều Hành!');
        break;
      case UserRole.department:
        context.go('/dashboard');
        _showWelcomeMessage('Chào mừng Phân Đoàn Trưởng!');
        break;
      case UserRole.teacher:
        context.go('/dashboard');
        _showWelcomeMessage('Chào mừng Giáo Lý Viên!');
        break;
    }
  }

  void _showWelcomeMessage(String message) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: const Color(0xFF38A169),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }
}