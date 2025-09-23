import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// Thêm MarkerInfo class
class MarkerInfo extends Equatable {
  final int id;
  final String fullName;

  const MarkerInfo({
    required this.id,
    required this.fullName,
  });

  @override
  List<Object?> get props => [id, fullName];

  factory MarkerInfo.fromJson(Map<String, dynamic> json) {
    return MarkerInfo(
      id: json['id'],
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
    };
  }
}

class AttendanceRecord extends Equatable {
  final int? id;
  final dynamic studentId;
  final DateTime attendanceDate;
  final String attendanceType;
  final bool isPresent;
  final String? note;
  final DateTime? markedAt;
  final MarkerInfo? marker; // ✅ THÊM FIELD NÀY

  const AttendanceRecord({
    this.id,
    required this.studentId,
    required this.attendanceDate,
    required this.attendanceType,
    required this.isPresent,
    this.note,
    this.markedAt,
    this.marker, // ✅ THÊM VÀO CONSTRUCTOR
  });

  @override
  List<Object?> get props => [
        id,
        studentId,
        attendanceDate,
        attendanceType,
        isPresent,
        note,
        markedAt,
        marker, // ✅ THÊM VÀO PROPS
      ];

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    try {
      return AttendanceRecord(
        id: _parseId(json['id']),
        studentId: json['studentId'], // Keep as dynamic
        attendanceDate: DateTime.parse(
            json['attendanceDate'] ?? DateTime.now().toIso8601String()),
        attendanceType: json['attendanceType'] ?? 'thursday',
        isPresent: json['isPresent'] ?? false,
        note: json['note'],
        markedAt:
            json['markedAt'] != null ? DateTime.parse(json['markedAt']) : null,
        marker:
            json['marker'] != null ? MarkerInfo.fromJson(json['marker']) : null,
      );
    } catch (e) {
      print('⚠️ Error parsing AttendanceRecord: $e');
      print('⚠️ JSON data: $json');

      // Return safe fallback
      return AttendanceRecord(
        studentId: json['studentId'] ?? 0,
        attendanceDate: DateTime.now(),
        attendanceType: 'thursday',
        isPresent: false,
      );
    }
  }

  static int? _parseId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'studentId': studentId,
      'attendanceDate': attendanceDate.toIso8601String(),
      'attendanceType': attendanceType,
      'isPresent': isPresent,
      if (note != null) 'note': note,
      if (markedAt != null) 'markedAt': markedAt!.toIso8601String(),
      if (marker != null) 'marker': marker!.toJson(), // ✅ SERIALIZE MARKER
    };
  }

  // Sửa factory create method
  factory AttendanceRecord.create({
    required dynamic studentId,
    required DateTime attendanceDate,
    required String attendanceType,
    required bool isPresent,
    String? note,
    MarkerInfo? marker, // ✅ THÊM MARKER
  }) {
    return AttendanceRecord(
      studentId: studentId,
      attendanceDate: attendanceDate,
      attendanceType: attendanceType,
      isPresent: isPresent,
      note: note,
      marker: marker,
    );
  }
}

class BatchAttendanceResult {
  final bool isSuccess;
  final String? message;
  final int? count;
  final String? error;

  BatchAttendanceResult.success({
    required this.message,
    required this.count,
  })  : isSuccess = true,
        error = null;

  BatchAttendanceResult.error(this.error)
      : isSuccess = false,
        message = null,
        count = null;

  bool get isError => !isSuccess;
}

class AttendanceSummary extends Equatable {
  final int total;
  final int attended;
  final int absent;
  final int notMarked;

  const AttendanceSummary({
    required this.total,
    required this.attended,
    required this.absent,
    required this.notMarked,
  });

  @override
  List<Object?> get props => [total, attended, absent, notMarked];

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      total: json['total'] ?? 0,
      attended: json['attended'] ?? 0,
      absent: json['absent'] ?? 0,
      notMarked: json['notMarked'] ?? 0,
    );
  }

  double get attendanceRate => total > 0 ? (attended / total) * 100 : 0.0;
  String get attendanceRateFormatted => '${attendanceRate.toStringAsFixed(1)}%';
}

class AttendanceResult extends Equatable {
  final bool isSuccess;
  final String? message;
  final int? count;
  final String? error;
  final List<String>? invalidStudentCodes; // ← Thông tin chi tiết về lỗi

  const AttendanceResult({
    required this.isSuccess,
    this.message,
    this.count,
    this.error,
    this.invalidStudentCodes,
  });

  @override
  List<Object?> get props =>
      [isSuccess, message, count, error, invalidStudentCodes];

  // Success constructor
  AttendanceResult.success({
    required this.message,
    required this.count,
  })  : isSuccess = true,
        error = null,
        invalidStudentCodes = null;

  // Error constructor
  AttendanceResult.error(this.error, {this.invalidStudentCodes})
      : isSuccess = false,
        message = null,
        count = null;

  factory AttendanceResult.fromJson(Map<String, dynamic> json) {
    return AttendanceResult(
      isSuccess: json['success'] ?? json['isSuccess'] ?? false,
      message: json['message'],
      count: json['count'] ?? json['successCount'],
      error: json['error'],
      invalidStudentCodes: json['invalidStudentCodes'] != null
          ? List<String>.from(json['invalidStudentCodes'])
          : null,
    );
  }
}

// ← THÊM UniversalAttendanceRequest để gửi lên backend
class UniversalAttendanceRequest {
  final List<String> studentCodes;
  final String attendanceDate;
  final String attendanceType;
  final String? note;

  const UniversalAttendanceRequest({
    required this.studentCodes,
    required this.attendanceDate,
    required this.attendanceType,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentCodes': studentCodes,
      'attendanceDate': attendanceDate,
      'attendanceType': attendanceType,
      if (note != null) 'note': note,
    };
  }
}

// ✅ NEW: Today's attendance status model
class TodayAttendanceStatus extends Equatable {
  final String date;
  final String type;
  final Map<String, StudentAttendanceStatus> attendanceStatus;
  final AttendanceSummary summary;

  const TodayAttendanceStatus({
    required this.date,
    required this.type,
    required this.attendanceStatus,
    required this.summary,
  });

  @override
  List<Object?> get props => [date, type, attendanceStatus, summary];

  factory TodayAttendanceStatus.fromJson(Map<String, dynamic> json) {
    final statusMap = <String, StudentAttendanceStatus>{};

    if (json['attendanceStatus'] != null) {
      (json['attendanceStatus'] as Map<String, dynamic>).forEach((key, value) {
        statusMap[key] = StudentAttendanceStatus.fromJson(value);
      });
    }

    return TodayAttendanceStatus(
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      attendanceStatus: statusMap,
      summary: AttendanceSummary.fromJson(json['summary'] ?? {}),
    );
  }

  // Helper methods
  bool isStudentAttended(String studentCode) {
    return attendanceStatus.containsKey(studentCode) &&
        attendanceStatus[studentCode]!.isPresent;
  }

  bool isStudentAbsent(String studentCode) {
    return attendanceStatus.containsKey(studentCode) &&
        !attendanceStatus[studentCode]!.isPresent;
  }

  bool isStudentNotMarked(String studentCode) {
    return !attendanceStatus.containsKey(studentCode);
  }

  StudentAttendanceStatus? getStudentStatus(String studentCode) {
    return attendanceStatus[studentCode];
  }
}

// ✅ NEW: Individual student attendance status
class StudentAttendanceStatus extends Equatable {
  final String studentCode;
  final String studentName;
  final String? className;
  final String? department;
  final bool isPresent;
  final DateTime markedAt;
  final String? markedBy;
  final String? note;
  final bool canToggle;

  const StudentAttendanceStatus({
    required this.studentCode,
    required this.studentName,
    this.className,
    this.department,
    required this.isPresent,
    required this.markedAt,
    this.markedBy,
    this.note,
    this.canToggle = true,
  });

  @override
  List<Object?> get props => [
        studentCode,
        studentName,
        className,
        department,
        isPresent,
        markedAt,
        markedBy,
        note,
        canToggle
      ];

  factory StudentAttendanceStatus.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceStatus(
      studentCode: json['studentCode'] ?? '',
      studentName: json['studentName'] ?? '',
      className: json['className'],
      department: json['department'],
      isPresent: json['isPresent'] ?? false,
      markedAt:
          DateTime.parse(json['markedAt'] ?? DateTime.now().toIso8601String()),
      markedBy: json['markedBy'],
      note: json['note'],
      canToggle: json['canToggle'] ?? true,
    );
  }

  // Helper getters
  String get statusText => isPresent ? 'Có mặt' : 'Vắng mặt';
  Color get statusColor => isPresent ? Colors.green : Colors.red;
  IconData get statusIcon => isPresent ? Icons.check_circle : Icons.cancel;
}

class UndoAttendanceRequest {
  final List<String> studentCodes;
  final String attendanceDate;
  final String attendanceType;
  final String? note;

  const UndoAttendanceRequest({
    required this.studentCodes,
    required this.attendanceDate,
    required this.attendanceType,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentCodes': studentCodes,
      'attendanceDate': attendanceDate,
      'attendanceType': attendanceType,
      if (note != null) 'note': note,
    };
  }
}
