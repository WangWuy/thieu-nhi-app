// lib/features/attendance/widgets/scanned_students_list.dart - FIXED DISPLAY
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_state.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ScannedStudentsList extends StatelessWidget {
  final List<ScannedStudentInfo> scannedStudents;
  final Function(String) onRemoveStudent;
  final VoidCallback onClearAll;

  const ScannedStudentsList({
    super.key,
    required this.scannedStudents,
    required this.onRemoveStudent,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: scannedStudents.isEmpty
                ? _buildEmptyState()
                : _buildStudentsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.people, color: AppColors.secondary),
        const SizedBox(width: 8),
        Text(
          'Thiếu nhi đã quét (${scannedStudents.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_2,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Chưa có thiếu nhi nào được quét',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hãy quét mã QR để thêm thiếu nhi',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsList() {
    return ListView.builder(
      itemCount: scannedStudents.length,
      itemBuilder: (context, index) {
        final student = scannedStudents[index];
        return _buildStudentItem(student, index);
      },
    );
  }

  Widget _buildStudentItem(ScannedStudentInfo student, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6), // ✅ Giảm margin
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // ✅ Giảm padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // ✅ Giảm border radius
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ COMPACT: Số thứ tự nhỏ gọn
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // ✅ COMPACT: Thông tin chính
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // ✅ Quan trọng: chỉ chiếm không gian cần thiết
              children: [
                // Mã thiếu nhi - prominent
                Text(
                  student.studentCode,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.2,
                    color: AppColors.secondary,
                  ),
                ),
                
                // ✅ COMPACT: Thông tin phụ trong 1 dòng
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (student.className != null) ...[
                      Icon(Icons.class_, size: 12, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        student.className!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Icon(Icons.access_time, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(student.scannedAt),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // ✅ COMPACT: Nút xóa nhỏ gọn
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 18),
            onPressed: () => onRemoveStudent(student.studentCode),
            tooltip: 'Xóa',
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }

  // ✅ Bỏ helper method _getStudentName() vì không cần nữa

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}