// lib/features/students/widgets/attendance_loading_state.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AttendanceLoadingState extends StatelessWidget {
  const AttendanceLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final muted =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 8),
            Text(
              'Đang tải lịch sử điểm danh...',
              style: TextStyle(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
