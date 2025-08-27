import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/services/student_service.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class ManualAttendanceModal extends StatefulWidget {
  const ManualAttendanceModal({super.key});

  @override
  State<ManualAttendanceModal> createState() => _ManualAttendanceModalState();
}

class _ManualAttendanceModalState extends State<ManualAttendanceModal> {
  final TextEditingController _searchController = TextEditingController();
  final StudentService _studentService = StudentService();

  List<StudentModel> _searchResults = [];
  bool _isSearching = false;
  StudentModel? _selectedStudent;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _selectedStudent = null;
      });
      return;
    }

    if (query.trim().length < 2) return;

    setState(() => _isSearching = true);

    try {
      final results = await _studentService.searchStudents(query.trim());
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  void _selectStudent(StudentModel student) {
    setState(() => _selectedStudent = student);
  }

  void _confirmAttendance() {
    if (_selectedStudent != null) {
      Navigator.of(context).pop(_selectedStudent!.qrId ?? _selectedStudent!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border:
                  Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit_note, color: AppColors.grey800),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Điểm danh thủ công',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Nhập tên thiếu nhi...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.secondary),
                ),
              ),
            ),
          ),

          // Search results
          Expanded(
            child: _searchResults.isEmpty
                ? Center(
                    child: Text(
                      _searchController.text.trim().isEmpty
                          ? 'Nhập tên để tìm kiếm thiếu nhi'
                          : 'Không tìm thấy thiếu nhi nào',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final student = _searchResults[index];
                      final isSelected = _selectedStudent?.id == student.id;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected
                              ? AppColors.secondary
                              : Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        title: Text(
                          student.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mã: ${student.qrId ?? student.id}'),
                            Text('Lớp: ${student.className}'),
                          ],
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected ? AppColors.success : Colors.grey,
                        ),
                        selected: isSelected,
                        selectedTileColor: AppColors.secondary.withOpacity(0.1),
                        onTap: () => _selectStudent(student),
                      );
                    },
                  ),
          ),

          // Confirm button
          if (_selectedStudent != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _confirmAttendance,
                icon: const Icon(Icons.check),
                label: Text('Xác nhận điểm danh - ${_selectedStudent!.name}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
