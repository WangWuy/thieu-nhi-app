// lib/features/auth/widgets/register_header.dart
import 'package:flutter/material.dart';

class RegisterHeader extends StatelessWidget {
  final Animation<double> pulseAnimation;

  const RegisterHeader({
    super.key,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated logo with modern styling
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: pulseAnimation.value,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFFDC143C).withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFFDC143C).withOpacity(0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(23),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFDC143C),
                                Color(0xFFB22222),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add,
                                size: 30,
                                color: Colors.white,
                              ),
                              SizedBox(height: 4),
                              Icon(
                                Icons.church,
                                size: 16,
                                color: Color(0xFFFFD700),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Modern typography
        Column(
          children: [
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFDC143C),
                    Color(0xFFFFD700),
                    Color(0xFF4169E1),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Đăng ký\n',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color(0xFF8B4513),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      height: 1.3,
                    ),
                  ),
                  TextSpan(
                    text: 'Thành viên',
                    style: TextStyle(
                      fontSize: 26,
                      color: Color(0xFFDC143C),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.8,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Giáo xứ Thiên Ân',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
