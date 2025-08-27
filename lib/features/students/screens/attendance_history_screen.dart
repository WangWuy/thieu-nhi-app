// lib/features/students/screens/attendance_history_screen.dart
import 'package:flutter/material.dart';
import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:thieu_nhi_app/core/models/student_model.dart';
import 'package:thieu_nhi_app/core/models/student_attendance_history.dart';
import 'package:thieu_nhi_app/core/services/student_service.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  final StudentModel student;
  final StudentAttendanceHistory? initialHistory;
  final StudentService studentService;

  const AttendanceHistoryScreen({
    super.key,
    required this.student,
    this.initialHistory,
    required this.studentService,
  });

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  late StudentAttendanceHistory _attendanceHistory;
  AttendanceHistoryFilter _currentFilter = const AttendanceHistoryFilter();
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    if (widget.initialHistory != null) {
      _attendanceHistory = widget.initialHistory!;
    }
    
    _loadFullHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadFullHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await widget.studentService.getStudentAttendanceHistory(
        widget.student.id,
        page: 1,
        limit: 100,
        filter: _currentFilter,
      );

      setState(() {
        if (response.isSuccess && response.data != null) {
          _attendanceHistory = response.data!;
        } else {
          _error = response.error;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi tải dữ liệu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_attendanceHistory.pagination.hasNext || _isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final response = await widget.studentService.loadMoreAttendanceHistory(
        widget.student.id,
        _attendanceHistory.pagination.page + 1,
        filter: _currentFilter,
      );

      if (response.isSuccess && response.data != null) {
        setState(() {
          _attendanceHistory = _attendanceHistory.copyWith(
            records: [..._attendanceHistory.records, ...response.data!.records],
            pagination: response.data!.pagination,
          );
        });
      }
    } catch (e) {
      print('Error loading more: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _applyFilter(AttendanceHistoryFilter filter) async {
    setState(() {
      _currentFilter = filter;
    });
    await _loadFullHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử điểm danh - ${widget.student.name}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(),

          // Records list
          Expanded(
            child: _buildRecordsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FilterChip(
              label: const Text('Tháng này'),
              selected: _currentFilter.month == AttendanceHistoryDateUtils.getCurrentMonthFilter(),
              onSelected: (_) => _applyFilter(AttendanceHistoryUtils.currentMonth()),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Thứ 5'),
              selected: _currentFilter.type == 'thursday',
              onSelected: (_) => _applyFilter(_currentFilter.copyWith(
                type: _currentFilter.type == 'thursday' ? null : 'thursday',
              )),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Chủ nhật'),
              selected: _currentFilter.type == 'sunday',
              onSelected: (_) => _applyFilter(_currentFilter.copyWith(
                type: _currentFilter.type == 'sunday' ? null : 'sunday',
              )),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Có mặt'),
              selected: _currentFilter.status == 'present',
              onSelected: (_) => _applyFilter(_currentFilter.copyWith(
                status: _currentFilter.status == 'present' ? null : 'present',
              )),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Vắng'),
              selected: _currentFilter.status == 'absent',
              onSelected: (_) => _applyFilter(_currentFilter.copyWith(
                status: _currentFilter.status == 'absent' ? null : 'absent',
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFullHistory,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_attendanceHistory.records.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: AppColors.grey400),
            SizedBox(height: 16),
            Text(
              'Không có dữ liệu điểm danh',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _attendanceHistory.records.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _attendanceHistory.records.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final record = _attendanceHistory.records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: AttendanceRecordListTile(record: record),
        );
      },
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lọc dữ liệu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.clear_all),
              title: const Text('Tất cả'),
              onTap: () {
                Navigator.pop(context);
                _applyFilter(const AttendanceHistoryFilter());
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.today),
              title: const Text('30 ngày gần đây'),
              onTap: () {
                Navigator.pop(context);
                _applyFilter(AttendanceHistoryUtils.last30Days());
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Năm học hiện tại'),
              onTap: () {
                Navigator.pop(context);
                _applyFilter(AttendanceHistoryUtils.currentAcademicYear());
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('Tháng này'),
              onTap: () {
                Navigator.pop(context);
                _applyFilter(AttendanceHistoryUtils.currentMonth());
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Detailed list tile for full screen
class AttendanceRecordListTile extends StatelessWidget {
  final AttendanceRecord record;

  const AttendanceRecordListTile({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: record.isPresent 
              ? AppColors.success.withOpacity(0.1)
              : AppColors.error.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          record.isPresent ? Icons.check_circle : Icons.cancel,
          color: record.isPresent ? AppColors.success : AppColors.error,
          size: 20,
        ),
      ),
      title: Text(
        _formatDate(record.attendanceDate),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                record.attendanceType == 'thursday' ? Icons.event : Icons.church,
                size: 14,
                color: AppColors.grey600,
              ),
              const SizedBox(width: 4),
              Text(
                record.attendanceType == 'thursday' ? 'Thứ 5' : 'Chủ nhật',
                style: TextStyle(color: AppColors.grey600),
              ),
              if (record.markedAt != null) ...[
                const SizedBox(width: 12),
                Icon(Icons.schedule, size: 14, color: AppColors.grey600),
                const SizedBox(width: 4),
                Text(
                  _formatTime(record.markedAt!),
                  style: TextStyle(color: AppColors.grey600),
                ),
              ],
            ],
          ),
          if (record.note?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.note, size: 14, color: AppColors.grey500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    record.note!,
                    style: TextStyle(
                      color: AppColors.grey500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (record.marker?.fullName != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: AppColors.grey500),
                const SizedBox(width: 4),
                Text(
                  'Điểm danh bởi: ${record.marker!.fullName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: record.isPresent 
              ? AppColors.success.withOpacity(0.1)
              : AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: record.isPresent 
                ? AppColors.success.withOpacity(0.3)
                : AppColors.error.withOpacity(0.3),
          ),
        ),
        child: Text(
          record.isPresent ? 'Có mặt' : 'Vắng',
          style: TextStyle(
            color: record.isPresent ? AppColors.success : AppColors.error,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
      onTap: () => _showRecordDetails(context, record),
    );
  }

  void _showRecordDetails(BuildContext context, AttendanceRecord record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết điểm danh'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Ngày', _formatDate(record.attendanceDate)),
            _buildDetailRow(
              'Loại', 
              record.attendanceType == 'thursday' ? 'Thứ 5' : 'Chủ nhật',
            ),
            _buildDetailRow(
              'Trạng thái', 
              record.isPresent ? 'Có mặt' : 'Vắng',
              valueColor: record.isPresent ? AppColors.success : AppColors.error,
            ),
            if (record.note?.isNotEmpty ?? false)
              _buildDetailRow('Ghi chú', record.note!),
            if (record.marker?.fullName != null)
              _buildDetailRow('Người điểm danh', record.marker!.fullName!),
            if (record.markedAt != null)
              _buildDetailRow('Thời gian', _formatDateTime(record.markedAt!)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${_formatTime(dateTime)}';
  }
}

// Extension for copyWith method
extension StudentAttendanceHistoryExtension on StudentAttendanceHistory {
  StudentAttendanceHistory copyWith({
    StudentBasicInfo? student,
    List<AttendanceRecord>? records,
    List<MonthlyAttendanceGroup>? groupedByMonth,
    AttendancePagination? pagination,
    AttendanceFilters? filters,
  }) {
    return StudentAttendanceHistory(
      student: student ?? this.student,
      records: records ?? this.records,
      groupedByMonth: groupedByMonth ?? this.groupedByMonth,
      pagination: pagination ?? this.pagination,
      filters: filters ?? this.filters,
    );
  }
}