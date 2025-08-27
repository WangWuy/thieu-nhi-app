// lib/features/auth/widgets/login_footer.dart
import 'package:flutter/material.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFDC143C).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              'Phiên bản 1.0.0',
              style: TextStyle(
                color: const Color(0xFF8B4513).withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '© 2025 Giáo xứ Thiên Ân',
              style: TextStyle(
                color: const Color(0xFF8B4513).withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}