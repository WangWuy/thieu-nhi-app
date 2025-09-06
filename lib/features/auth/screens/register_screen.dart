// lib/features/auth/screens/register_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/register_header.dart';
import '../widgets/register_form.dart';
import '../widgets/login_footer.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _saintNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthDateController = TextEditingController();
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _saintNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _onRegister() {
    // Simulate registration process
    _showRegistrationSuccessDialog();
  }

  void _showRegistrationSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF38A169).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 50,
                  color: Color(0xFF38A169),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Đăng ký thành công!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF38A169),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF38A169).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin tài khoản của bạn:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Tên đăng nhập:', _usernameController.text),
                    _buildInfoRow('Email:', _emailController.text),
                    _buildInfoRow('Họ tên:', _fullNameController.text),
                    _buildInfoRow('Số điện thoại:', _phoneController.text),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F3FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF4169E1).withOpacity(0.3),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Color(0xFF4169E1),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Quy trình phê duyệt:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4169E1),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Tài khoản đã được tạo thành công\n'
                            '• Ban Điều Hành sẽ xem xét và phê duyệt trong 1-2 ngày làm việc\n'
                            '• Bạn sẽ nhận được email thông báo khi tài khoản được kích hoạt\n'
                            '• Sau khi được phê duyệt, bạn có thể đăng nhập và sử dụng ứng dụng',
                            style: TextStyle(
                              color: Color(0xFF4169E1),
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBF0),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFDC143C).withOpacity(0.3),
                        ),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.security,
                                size: 16,
                                color: Color(0xFFDC143C),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Bảo mật thông tin:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFDC143C),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Thông tin cá nhân được mã hóa và bảo mật\n'
                            '• Chỉ Ban Điều Hành có quyền truy cập thông tin\n'
                            '• Dữ liệu được sử dụng chỉ cho mục đích giáo dục\n'
                            '• Tuân thủ các quy định về bảo vệ dữ liệu cá nhân',
                            style: TextStyle(
                              color: Color(0xFFDC143C),
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearForm();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: const Color(0xFF38A169).withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Đăng ký thêm',
                        style: TextStyle(
                          color: Color(0xFF38A169),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38A169),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF8B4513),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _usernameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _fullNameController.clear();
    _saintNameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _birthDateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        body: Container(
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
                            height: MediaQuery.of(context).size.height * 0.25,
                            child:
                                RegisterHeader(pulseAnimation: _pulseAnimation),
                          ),
                          RegisterForm(
                            formKey: _formKey,
                            usernameController: _usernameController,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            confirmPasswordController:
                                _confirmPasswordController,
                            fullNameController: _fullNameController,
                            saintNameController: _saintNameController,
                            phoneController: _phoneController,
                            addressController: _addressController,
                            birthDateController: _birthDateController,
                            onRegister: _onRegister,
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
    );
  }
}
