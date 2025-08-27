// lib/features/attendance/widgets/scanner_bottom_actions.dart - CLEANED UP
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_state.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ScannerBottomActions extends StatelessWidget {
  final List<ScannedStudentInfo> scannedStudents;
  final bool isSubmitting;
  final VoidCallback onClearAll; // ✅ Giữ param nhưng không dùng
  final VoidCallback onSubmit;

  const ScannerBottomActions({
    super.key,
    required this.scannedStudents,
    required this.isSubmitting,
    required this.onClearAll,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        // borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                scannedStudents.isEmpty || isSubmitting ? null : onSubmit,
            icon: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.check_circle),
            label: Text(isSubmitting ? 'Đang gửi...' : 'Xác nhận điểm danh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
      ),
    );
  }
}
