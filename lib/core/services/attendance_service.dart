// lib/core/services/attendance_service.dart
import 'http_client.dart';
import '../models/attendance_models.dart'; // Import from unified models

class AttendanceService {
  final HttpClient _httpClient = HttpClient();

  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  // Mark single attendance
  Future<bool> markAttendance({
    required int studentId,
    required String attendanceDate,
    required String attendanceType,
    required bool isPresent,
    String? note,
  }) async {
    try {
      final response = await _httpClient.post('/attendance', body: {
        'studentId': studentId,
        'attendanceDate': attendanceDate,
        'attendanceType': attendanceType,
        'isPresent': isPresent,
        'note': note,
      });

      return response.isSuccess;
    } catch (e) {
      print('Mark attendance error: $e');
      return false;
    }
  }

  // Get attendance by class and date
  Future<List<Map<String, dynamic>>> getAttendanceByClass({
    required String classId,
    required String date,
    required String type,
  }) async {
    try {
      final response =
          await _httpClient.get('/classes/$classId/attendance', queryParams: {
        'date': date,
        'type': type,
      });

      if (response.isSuccess) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      return [];
    } catch (e) {
      print('Get attendance by class error: $e');
      return [];
    }
  }

  // Batch mark attendance - sử dụng unified AttendanceRecord
  Future<BatchAttendanceResult> batchMarkAttendance({
    required String classId,
    required String attendanceDate,
    required String attendanceType,
    required List<AttendanceRecord> attendanceRecords, // Unified class
  }) async {
    try {
      final recordsData = attendanceRecords
          .map((record) => {
                'studentId': record.studentId,
                'isPresent': record.isPresent,
                'note': record.note,
              })
          .toList();

      final response =
          await _httpClient.post('/classes/$classId/attendance/batch', body: {
        'attendanceDate': attendanceDate,
        'attendanceType': attendanceType,
        'attendanceRecords': recordsData,
      });

      if (response.isSuccess) {
        return BatchAttendanceResult.success(
          message: response.data['message'],
          count: response.data['count'],
        );
      }

      return BatchAttendanceResult.error(
          response.error ?? 'Batch attendance failed');
    } catch (e) {
      return BatchAttendanceResult.error('Lỗi điểm danh: ${e.toString()}');
    }
  }

  // Get attendance statistics
  Future<Map<String, dynamic>> getAttendanceStats({
    String? startDate,
    String? endDate,
    String? classId,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (classId != null) queryParams['classId'] = classId;

      final response =
          await _httpClient.get('/attendance/stats', queryParams: queryParams);

      if (response.isSuccess) {
        return response.data;
      }
      return {};
    } catch (e) {
      print('Get attendance stats error: $e');
      return {};
    }
  }

  // Get today's attendance summary
  Future<Map<String, dynamic>> getTodayAttendanceSummary() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];

      final response = await _httpClient.get('/attendance/stats', queryParams: {
        'startDate': today,
        'endDate': today,
      });

      if (response.isSuccess) {
        return response.data;
      }
      return {
        'thursday': {'present': 0, 'absent': 0},
        'sunday': {'present': 0, 'absent': 0},
      };
    } catch (e) {
      print('Get today attendance summary error: $e');
      return {
        'thursday': {'present': 0, 'absent': 0},
        'sunday': {'present': 0, 'absent': 0},
      };
    }
  }

  // Get attendance history for a student - trả về unified AttendanceRecord
  Future<List<AttendanceRecord>> getStudentAttendanceHistory({
    required String studentId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        'studentId': studentId,
      };

      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _httpClient.get('/attendance/history',
          queryParams: queryParams);

      if (response.isSuccess) {
        return (response.data as List)
            .map((json) => AttendanceRecord.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('Get student attendance history error: $e');
      return [];
    }
  }

  // Get attendance rate for class
  Future<double> getClassAttendanceRate(
    String classId, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, String>{
        'classId': classId,
      };

      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response =
          await _httpClient.get('/attendance/rate', queryParams: queryParams);

      if (response.isSuccess) {
        return (response.data['rate'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      print('Get class attendance rate error: $e');
      return 0.0;
    }
  }

  Future<AttendanceResult> submitUniversalAttendance({
    required List<String> studentCodes,
    required DateTime attendanceDate,
    required String attendanceType,
    String? note,
  }) async {
    try {
      // Validate input
      if (studentCodes.isEmpty) {
        return AttendanceResult.error('Danh sách thiếu nhi trống');
      }

      final request = UniversalAttendanceRequest(
        studentCodes: studentCodes,
        attendanceDate: attendanceDate.toIso8601String().split('T')[0],
        attendanceType: attendanceType,
        note: note ?? 'Universal QR Scan',
      );

      print('🚀 Sending universal attendance: ${studentCodes.length} students');

      final response = await _httpClient.post(
        '/attendance/universal', // ← Endpoint mới trên backend
        body: request.toJson(),
      );

      if (response.isSuccess) {
        print('✅ Universal attendance success: ${response.data}');
        return AttendanceResult.fromJson(response.data);
      } else {
        print('❌ Universal attendance failed: ${response.error}');
        return AttendanceResult.error(
          response.error ?? 'Lỗi điểm danh',
        );
      }
    } catch (e) {
      print('💥 Universal attendance exception: $e');
      return AttendanceResult.error('Lỗi kết nối: ${e.toString()}');
    }
  }

  // ← THÊM method helper để validate student codes
  Future<List<String>> validateStudentCodes(List<String> studentCodes) async {
    try {
      final response =
          await _httpClient.post('/attendance/validate-codes', body: {
        'studentCodes': studentCodes,
      });

      if (response.isSuccess) {
        return List<String>.from(response.data['validCodes'] ?? []);
      }
      return [];
    } catch (e) {
      print('Validate student codes error: $e');
      return [];
    }
  }

  // ← THÊM method để lấy thông tin ngắn gọn về student từ code
  Future<Map<String, dynamic>> getStudentInfoFromCode(
      String studentCode) async {
    try {
      final response = await _httpClient.get('/students/by-code/$studentCode');

      if (response.isSuccess) {
        return {
          'studentCode': response.data['studentCode'],
          'name': response.data['fullName'],
          'className': response.data['class']?['name'],
          'department': response.data['class']?['department']?['displayName'],
        };
      }
      return {};
    } catch (e) {
      print('Get student info error: $e');
      return {};
    }
  }

  String formatDateForAPI(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  String getWeekIdentifier(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final weekNumber = ((date.difference(startOfYear).inDays) / 7).floor() + 1;
    return 'week$weekNumber';
  }

  // Helper method để tạo AttendanceRecord cho batch operations
  static AttendanceRecord createAttendanceRecord({
    required dynamic studentId,
    required DateTime attendanceDate,
    required String attendanceType,
    required bool isPresent,
    String? note,
  }) {
    return AttendanceRecord.create(
      studentId: studentId,
      attendanceDate: attendanceDate,
      attendanceType: attendanceType,
      isPresent: isPresent,
      note: note,
    );
  }
}
