// lib/core/services/student_service.dart
import 'package:thieu_nhi_app/core/models/attendance_models.dart';
import 'package:thieu_nhi_app/core/models/student_attendance_history.dart';

import '../models/student_model.dart';
import 'http_client.dart';
import 'backend_adapters.dart';

class StudentService {
  final HttpClient _httpClient = HttpClient();

  // Singleton
  static final StudentService _instance = StudentService._internal();
  factory StudentService() => _instance;
  StudentService._internal();

  // Get students with pagination and filters
  Future<StudentListResult> getStudents({
    int page = 1,
    int limit = 20,
    String? search,
    String? classFilter, // This will be classId as string
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (classFilter != null && classFilter.isNotEmpty) {
        queryParams['classFilter'] = classFilter; // Send classId to backend
      }

      print('📡 API call: /students with params: $queryParams');

      final response =
          await _httpClient.get('/students', queryParams: queryParams);

      if (response.isSuccess) {
        final students = (response.data['students'] as List)
            .map((json) => BackendStudentAdapter.fromBackendJson(json))
            .toList();

        final pagination = response.data['pagination'];

        return StudentListResult.success(
          students: students,
          totalPages: pagination['pages'],
          currentPage: pagination['page'],
          totalStudents: pagination['total'],
        );
      }

      return StudentListResult.error(
          response.error ?? 'Lỗi tải danh sách thiếu nhi');
    } catch (e) {
      print('❌ StudentService.getStudents error: $e');
      return StudentListResult.error('Lỗi kết nối: ${e.toString()}');
    }
  }

  // Get students by class
  Future<List<StudentModel>> getStudentsByClass(String classId) async {
    try {
      final response = await _httpClient.get('/classes/$classId/students');

      if (response.isSuccess) {
        return (response.data as List)
            .map((json) => BackendStudentAdapter.fromBackendJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get students by class error: $e');
      return [];
    }
  }

  // Get student by ID
  Future<StudentModel?> getStudentById(String studentId) async {
    try {
      final response = await _httpClient.get('/students/$studentId');

      if (response.isSuccess) {
        return BackendStudentAdapter.fromBackendJson(response.data);
      }
      return null;
    } catch (e) {
      print('Get student by ID error: $e');
      return null;
    }
  }

  // Create student
  Future<StudentModel?> createStudent({
    required String studentCode,
    required String fullName,
    required int classId,
    String? saintName,
    DateTime? birthDate,
    String? phoneNumber,
    String? parentPhone1,
    String? parentPhone2,
    String? address,
  }) async {
    try {
      final response = await _httpClient.post('/students', body: {
        'studentCode': studentCode,
        'fullName': fullName,
        'classId': classId,
        'saintName': saintName,
        'birthDate': birthDate?.toIso8601String(),
        'phoneNumber': phoneNumber,
        'parentPhone1': parentPhone1,
        'parentPhone2': parentPhone2,
        'address': address,
      });

      if (response.isSuccess) {
        return BackendStudentAdapter.fromBackendJson(response.data);
      }
      return null;
    } catch (e) {
      print('Create student error: $e');
      return null;
    }
  }

  // Update student
  Future<StudentModel?> updateStudent(
      String studentId, Map<String, dynamic> updates) async {
    try {
      final response =
          await _httpClient.put('/students/$studentId', body: updates);

      if (response.isSuccess) {
        return BackendStudentAdapter.fromBackendJson(response.data);
      }
      return null;
    } catch (e) {
      print('Update student error: $e');
      return null;
    }
  }

  // Delete student
  Future<bool> deleteStudent(String studentId) async {
    try {
      final response = await _httpClient.delete('/students/$studentId');
      return response.isSuccess;
    } catch (e) {
      print('Delete student error: $e');
      return false;
    }
  }

  // Search students by name
  Future<List<StudentModel>> searchStudents(String query) async {
    try {
      final response = await _httpClient.get('/students', queryParams: {
        'search': query,
        'limit': '50', // Increase limit for search
      });

      if (response.isSuccess) {
        return (response.data['students'] as List)
            .map((json) => BackendStudentAdapter.fromBackendJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Search students error: $e');
      return [];
    }
  }

  // Find student by QR ID
  Future<StudentModel?> findStudentByQRId(String qrId) async {
    try {
      // Search by student code (which maps to qrId)
      final response = await _httpClient.get('/students', queryParams: {
        'search': qrId,
        'limit': '1',
      });

      if (response.isSuccess) {
        final students = (response.data['students'] as List)
            .map((json) => BackendStudentAdapter.fromBackendJson(json))
            .toList();

        // Find exact match by qrId
        for (final student in students) {
          if (student.qrId == qrId) {
            return student;
          }
        }
      }
      return null;
    } catch (e) {
      print('Find student by QR error: $e');
      return null;
    }
  }

  // Get student statistics
  Future<Map<String, dynamic>> getStudentStats({
    String? classId,
    String? department,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (classId != null) queryParams['classId'] = classId;
      if (department != null) queryParams['department'] = department;

      final response =
          await _httpClient.get('/students/stats', queryParams: queryParams);

      if (response.isSuccess) {
        return response.data;
      }
      return {};
    } catch (e) {
      print('Get student stats error: $e');
      return {};
    }
  }

  // Export students data
  Future<List<Map<String, dynamic>>> exportStudents({
    String? classId,
    String? department,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (classId != null) queryParams['classId'] = classId;
      if (department != null) queryParams['department'] = department;

      final response =
          await _httpClient.get('/students/export', queryParams: queryParams);

      if (response.isSuccess) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print('Export students error: $e');
      return [];
    }
  }

  /// Get student attendance history with filtering and pagination
  Future<AttendanceHistoryResponse> getStudentAttendanceHistory(
    String studentId, {
    int page = 1,
    int limit = 50,
    AttendanceHistoryFilter? filter,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Add filter parameters
      if (filter != null) {
        queryParams.addAll(filter.toQueryParams());
      }

      print('📞 Fetching attendance history for student $studentId');
      print('🔍 Query params: $queryParams');

      final response = await _httpClient.get(
        '/students/$studentId/attendance/history',
        queryParams: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        print('✅ Attendance history loaded successfully');
        final history = StudentAttendanceHistory.fromJson(response.data);
        return AttendanceHistoryResponse.success(history);
      } else {
        final error = response.error ?? 'Không thể tải lịch sử điểm danh';
        print('❌ Failed to load attendance history: $error');
        return AttendanceHistoryResponse.error(error);
      }
    } catch (e, stackTrace) {
      print('❌ Error getting student attendance history: $e');
      print('❌ Stack trace: $stackTrace');
      return AttendanceHistoryResponse.error('Lỗi kết nối: ${e.toString()}');
    }
  }

  /// Get student attendance history for specific month (convenience method)
  Future<AttendanceHistoryResponse> getStudentAttendanceForMonth(
    String studentId,
    String month, {
    int limit = 100,
  }) async {
    final filter = AttendanceHistoryFilter(month: month);
    return getStudentAttendanceHistory(
      studentId,
      page: 1,
      limit: limit,
      filter: filter,
    );
  }

  /// Get student attendance history by type (convenience method)
  Future<AttendanceHistoryResponse> getStudentAttendanceByType(
    String studentId,
    String type, {
    int page = 1,
    int limit = 50,
  }) async {
    final filter = AttendanceHistoryFilter(type: type);
    return getStudentAttendanceHistory(
      studentId,
      page: page,
      limit: limit,
      filter: filter,
    );
  }

  /// Get student attendance history by date range (convenience method)
  Future<AttendanceHistoryResponse> getStudentAttendanceByDateRange(
    String studentId,
    String startDate,
    String endDate, {
    int page = 1,
    int limit = 50,
  }) async {
    final filter = AttendanceHistoryFilter(
      startDate: startDate,
      endDate: endDate,
    );
    return getStudentAttendanceHistory(
      studentId,
      page: page,
      limit: limit,
      filter: filter,
    );
  }

  /// Get student attendance statistics
  Future<StudentAttendanceStats?> getStudentAttendanceStats(
    String studentId, {
    int? year,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (year != null) {
        queryParams['year'] = year.toString();
      }

      print('📊 Fetching attendance stats for student $studentId');
      if (year != null) print('📅 Year filter: $year');

      final response = await _httpClient.get(
        '/students/$studentId/attendance/stats',
        queryParams: queryParams,
      );

      if (response.isSuccess && response.data != null) {
        print('✅ Attendance stats loaded successfully');
        return StudentAttendanceStats.fromJson(response.data);
      } else {
        print('❌ Failed to load attendance stats: ${response.error}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ Error getting student attendance stats: $e');
      print('❌ Stack trace: $stackTrace');
      return null;
    }
  }

  /// Load more attendance records (pagination helper)
  Future<AttendanceHistoryResponse> loadMoreAttendanceHistory(
    String studentId,
    int nextPage, {
    int limit = 50,
    AttendanceHistoryFilter? filter,
  }) async {
    return getStudentAttendanceHistory(
      studentId,
      page: nextPage,
      limit: limit,
      filter: filter,
    );
  }

  /// Search attendance records (combines filtering)
  Future<AttendanceHistoryResponse> searchStudentAttendance(
    String studentId, {
    String? month,
    String? type,
    String? status,
    int page = 1,
    int limit = 50,
  }) async {
    final filter = AttendanceHistoryFilter(
      month: month,
      type: type,
      status: status,
    );

    return getStudentAttendanceHistory(
      studentId,
      page: page,
      limit: limit,
      filter: filter,
    );
  }

  /// Get recent attendance (convenience for widget)
  Future<List<AttendanceRecord>> getRecentAttendance(
    String studentId, {
    int limit = 10,
  }) async {
    try {
      final response = await getStudentAttendanceHistory(
        studentId,
        page: 1,
        limit: limit,
      );

      if (response.isSuccess && response.data != null) {
        return response.data!.records;
      }
      return [];
    } catch (e) {
      print('❌ Error getting recent attendance: $e');
      return [];
    }
  }

  /// Get attendance summary (for cards)
  Future<Map<String, dynamic>> getAttendanceSummary(String studentId) async {
    try {
      final stats = await getStudentAttendanceStats(studentId);

      if (stats != null) {
        return {
          'thursdayCount': stats.student.thursdayCount ?? 0,
          'sundayCount': stats.student.sundayCount ?? 0,
          'attendanceAverage': stats.student.attendanceAverage,
          'totalPresent': stats.typeStats.totalPresent,
          'totalAbsent': stats.typeStats.totalAbsent,
          'overallPercentage': stats.typeStats.overallPercentage,
        };
      }
      return {};
    } catch (e) {
      print('❌ Error getting attendance summary: $e');
      return {};
    }
  }
}

// Result classes
class StudentListResult {
  final bool isSuccess;
  final List<StudentModel>? students;
  final int? totalPages;
  final int? currentPage;
  final int? totalStudents;
  final String? error;

  StudentListResult.success({
    required this.students,
    required this.totalPages,
    required this.currentPage,
    required this.totalStudents,
  })  : isSuccess = true,
        error = null;

  StudentListResult.error(this.error)
      : isSuccess = false,
        students = null,
        totalPages = null,
        currentPage = null,
        totalStudents = null;

  bool get isError => !isSuccess;
}

class ImportResult {
  final bool isSuccess;
  final String? message;
  final int? successCount;
  final int? failedCount;
  final Map<String, dynamic>? details;
  final String? error;

  ImportResult.success({
    required this.message,
    required this.successCount,
    required this.failedCount,
    this.details,
  })  : isSuccess = true,
        error = null;

  ImportResult.error(this.error)
      : isSuccess = false,
        message = null,
        successCount = null,
        failedCount = null,
        details = null;

  bool get isError => !isSuccess;
}

extension AttendanceHistoryDateUtils on StudentService {
  /// Format date for API (YYYY-MM-DD)
  static String formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format month for API (YYYY-MM)
  static String formatMonthForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  /// Get current month filter
  static String getCurrentMonthFilter() {
    final now = DateTime.now();
    return formatMonthForAPI(now);
  }

  /// Get month filter for specific month
  static String getMonthFilter(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }
}

// Usage examples and convenience methods
class AttendanceHistoryUtils {
  /// Create filter for current month
  static AttendanceHistoryFilter currentMonth() {
    return AttendanceHistoryFilter(
      month: AttendanceHistoryDateUtils.getCurrentMonthFilter(),
    );
  }

  /// Create filter for specific month
  static AttendanceHistoryFilter forMonth(int year, int month) {
    return AttendanceHistoryFilter(
      month: AttendanceHistoryDateUtils.getMonthFilter(year, month),
    );
  }

  /// Create filter for Thursday only
  static AttendanceHistoryFilter thursdayOnly() {
    return const AttendanceHistoryFilter(type: 'thursday');
  }

  /// Create filter for Sunday only
  static AttendanceHistoryFilter sundayOnly() {
    return const AttendanceHistoryFilter(type: 'sunday');
  }

  /// Create filter for present only
  static AttendanceHistoryFilter presentOnly() {
    return const AttendanceHistoryFilter(status: 'present');
  }

  /// Create filter for absent only
  static AttendanceHistoryFilter absentOnly() {
    return const AttendanceHistoryFilter(status: 'absent');
  }

  /// Create filter for date range
  static AttendanceHistoryFilter dateRange(DateTime start, DateTime end) {
    return AttendanceHistoryFilter(
      startDate: AttendanceHistoryDateUtils.formatDateForAPI(start),
      endDate: AttendanceHistoryDateUtils.formatDateForAPI(end),
    );
  }

  /// Create filter for last 30 days
  static AttendanceHistoryFilter last30Days() {
    final end = DateTime.now();
    final start = end.subtract(const Duration(days: 30));
    return dateRange(start, end);
  }

  /// Create filter for current academic year (rough)
  static AttendanceHistoryFilter currentAcademicYear() {
    final now = DateTime.now();
    final start = DateTime(now.month >= 9 ? now.year : now.year - 1, 9, 1);
    final end = DateTime(now.month >= 9 ? now.year + 1 : now.year, 8, 31);
    return dateRange(start, end);
  }
}
