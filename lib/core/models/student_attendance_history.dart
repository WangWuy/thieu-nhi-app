// lib/core/models/student_attendance_history.dart
import 'package:equatable/equatable.dart';
import 'attendance_models.dart';

class StudentAttendanceHistory extends Equatable {
  final StudentBasicInfo student;
  final List<AttendanceRecord> records;
  final List<MonthlyAttendanceGroup> groupedByMonth;
  final AttendancePagination pagination;
  final AttendanceFilters filters;

  const StudentAttendanceHistory({
    required this.student,
    required this.records,
    required this.groupedByMonth,
    required this.pagination,
    required this.filters,
  });

  @override
  List<Object?> get props =>
      [student, records, groupedByMonth, pagination, filters];

  factory StudentAttendanceHistory.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceHistory(
      student: StudentBasicInfo.fromJson(json['student']),
      records: (json['records'] as List)
          .map((record) => AttendanceRecord.fromJson(record))
          .toList(),
      groupedByMonth: (json['groupedByMonth'] as List)
          .map((group) => MonthlyAttendanceGroup.fromJson(group))
          .toList(),
      pagination: AttendancePagination.fromJson(json['pagination']),
      filters: AttendanceFilters.fromJson(json['filters']),
    );
  }

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

class StudentBasicInfo extends Equatable {
  final int id;
  final String name;
  final String studentCode;
  final String? className;
  final String? department;

  const StudentBasicInfo({
    required this.id,
    required this.name,
    required this.studentCode,
    this.className,
    this.department,
  });

  @override
  List<Object?> get props => [id, name, studentCode, className, department];

  factory StudentBasicInfo.fromJson(Map<String, dynamic> json) {
    return StudentBasicInfo(
      id: _parseId(json['id']),
      name: json['name'],
      studentCode: json['studentCode'],
      className: json['className'],
      department: json['department'],
    );
  }

  static int _parseId(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is num) return value.toInt();
    return 0;
  }
}

class MonthlyAttendanceGroup extends Equatable {
  final String monthKey;
  final int year;
  final int month;
  final String monthName;
  final List<AttendanceRecord> records;
  final MonthlyAttendanceStats stats;

  const MonthlyAttendanceGroup({
    required this.monthKey,
    required this.year,
    required this.month,
    required this.monthName,
    required this.records,
    required this.stats,
  });

  @override
  List<Object?> get props => [monthKey, year, month, monthName, records, stats];

  factory MonthlyAttendanceGroup.fromJson(Map<String, dynamic> json) {
    return MonthlyAttendanceGroup(
      monthKey: json['monthKey'],
      year: json['year'],
      month: json['month'],
      monthName: json['monthName'],
      records: (json['records'] as List)
          .map((record) => AttendanceRecord.fromJson(record))
          .toList(),
      stats: MonthlyAttendanceStats.fromJson(json['stats']),
    );
  }
}

class MonthlyAttendanceStats extends Equatable {
  final int total;
  final int present;
  final int absent;
  final AttendanceTypeStats thursday;
  final AttendanceTypeStats sunday;

  const MonthlyAttendanceStats({
    required this.total,
    required this.present,
    required this.absent,
    required this.thursday,
    required this.sunday,
  });

  double get presentPercentage => total > 0 ? (present / total) * 100 : 0;
  double get absentPercentage => total > 0 ? (absent / total) * 100 : 0;

  @override
  List<Object?> get props => [total, present, absent, thursday, sunday];

  factory MonthlyAttendanceStats.fromJson(Map<String, dynamic> json) {
    return MonthlyAttendanceStats(
      total: json['total'],
      present: json['present'],
      absent: json['absent'],
      thursday: AttendanceTypeStats.fromJson(json['thursday']),
      sunday: AttendanceTypeStats.fromJson(json['sunday']),
    );
  }
}

class AttendanceTypeStats extends Equatable {
  final int total;
  final int present;

  const AttendanceTypeStats({
    required this.total,
    required this.present,
  });

  int get absent => total - present;
  double get percentage => total > 0 ? (present / total) * 100 : 0;

  @override
  List<Object?> get props => [total, present];

  factory AttendanceTypeStats.fromJson(Map<String, dynamic> json) {
    return AttendanceTypeStats(
      total: json['total'],
      present: json['present'],
    );
  }
}

class AttendancePagination extends Equatable {
  final int page;
  final int limit;
  final int total;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  const AttendancePagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });

  @override
  List<Object?> get props => [page, limit, total, pages, hasNext, hasPrev];

  factory AttendancePagination.fromJson(Map<String, dynamic> json) {
    return AttendancePagination(
      page: json['page'],
      limit: json['limit'],
      total: json['total'],
      pages: json['pages'],
      hasNext: json['hasNext'],
      hasPrev: json['hasPrev'],
    );
  }
}

class AttendanceFilters extends Equatable {
  final String? startDate;
  final String? endDate;
  final String? type;
  final String? status;
  final String? month;

  const AttendanceFilters({
    this.startDate,
    this.endDate,
    this.type,
    this.status,
    this.month,
  });

  @override
  List<Object?> get props => [startDate, endDate, type, status, month];

  factory AttendanceFilters.fromJson(Map<String, dynamic> json) {
    return AttendanceFilters(
      startDate: json['startDate'],
      endDate: json['endDate'],
      type: json['type'],
      status: json['status'],
      month: json['month'],
    );
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (startDate != null) params['startDate'] = startDate!;
    if (endDate != null) params['endDate'] = endDate!;
    if (type != null) params['type'] = type!;
    if (status != null) params['status'] = status!;
    if (month != null) params['month'] = month!;
    return params;
  }
}

// Student Attendance Stats Models
class StudentAttendanceStats extends Equatable {
  final StudentStatsInfo student;
  final List<MonthlyStatItem> monthlyStats;
  final OverallTypeStats typeStats;
  final int year;

  const StudentAttendanceStats({
    required this.student,
    required this.monthlyStats,
    required this.typeStats,
    required this.year,
  });

  @override
  List<Object?> get props => [student, monthlyStats, typeStats, year];

  factory StudentAttendanceStats.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceStats(
      student: StudentStatsInfo.fromJson(json['student']),
      monthlyStats: (json['monthlyStats'] as List)
          .map((stat) => MonthlyStatItem.fromJson(stat))
          .toList(),
      typeStats: OverallTypeStats.fromJson(json['typeStats']),
      year: json['year'],
    );
  }
}

class StudentStatsInfo extends Equatable {
  final String name;
  final String studentCode;
  final int? thursdayCount;
  final int? sundayCount;
  final double attendanceAverage;

  const StudentStatsInfo({
    required this.name,
    required this.studentCode,
    this.thursdayCount,
    this.sundayCount,
    required this.attendanceAverage,
  });

  @override
  List<Object?> get props =>
      [name, studentCode, thursdayCount, sundayCount, attendanceAverage];

  factory StudentStatsInfo.fromJson(Map<String, dynamic> json) {
    return StudentStatsInfo(
      name: json['name'],
      studentCode: json['studentCode'],
      thursdayCount: json['thursdayCount'],
      sundayCount: json['sundayCount'],
      attendanceAverage: (json['attendanceAverage'] as num).toDouble(),
    );
  }
}

class MonthlyStatItem extends Equatable {
  final int year;
  final int month;
  final String type;
  final int total;
  final int present;
  final int absent;
  final int percentage;

  const MonthlyStatItem({
    required this.year,
    required this.month,
    required this.type,
    required this.total,
    required this.present,
    required this.absent,
    required this.percentage,
  });

  String get monthName {
    const months = [
      '',
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12'
    ];
    return '${months[month]} $year';
  }

  String get typeDisplayName => type == 'thursday' ? 'Thứ 5' : 'Chủ nhật';

  @override
  List<Object?> get props =>
      [year, month, type, total, present, absent, percentage];

  factory MonthlyStatItem.fromJson(Map<String, dynamic> json) {
    return MonthlyStatItem(
      year: json['year'],
      month: json['month'],
      type: json['type'],
      total: json['total'],
      present: json['present'],
      absent: json['absent'],
      percentage: json['percentage'],
    );
  }
}

class OverallTypeStats extends Equatable {
  final AttendanceTypeStats thursday;
  final AttendanceTypeStats sunday;

  const OverallTypeStats({
    required this.thursday,
    required this.sunday,
  });

  int get totalPresent => thursday.present + sunday.present;
  int get totalAbsent => thursday.absent + sunday.absent;
  int get grandTotal => totalPresent + totalAbsent;
  double get overallPercentage =>
      grandTotal > 0 ? (totalPresent / grandTotal) * 100 : 0;

  @override
  List<Object?> get props => [thursday, sunday];

  factory OverallTypeStats.fromJson(Map<String, dynamic> json) {
    return OverallTypeStats(
      thursday: AttendanceTypeStats.fromJson(json['thursday']),
      sunday: AttendanceTypeStats.fromJson(json['sunday']),
    );
  }
}

// Filter helper classes
class AttendanceHistoryFilter {
  final String? month;
  final String? type;
  final String? status;
  final String? startDate;
  final String? endDate;

  const AttendanceHistoryFilter({
    this.month,
    this.type,
    this.status,
    this.startDate,
    this.endDate,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (month != null) params['month'] = month!;
    if (type != null) params['type'] = type!;
    if (status != null) params['status'] = status!;
    if (startDate != null) params['startDate'] = startDate!;
    if (endDate != null) params['endDate'] = endDate!;
    return params;
  }

  AttendanceHistoryFilter copyWith({
    String? month,
    String? type,
    String? status,
    String? startDate,
    String? endDate,
  }) {
    return AttendanceHistoryFilter(
      month: month ?? this.month,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

// Response wrapper for service layer
class AttendanceHistoryResponse {
  final StudentAttendanceHistory? data;
  final String? error;
  final bool isSuccess;

  const AttendanceHistoryResponse({
    this.data,
    this.error,
    required this.isSuccess,
  });

  factory AttendanceHistoryResponse.success(StudentAttendanceHistory data) {
    return AttendanceHistoryResponse(data: data, isSuccess: true);
  }

  factory AttendanceHistoryResponse.error(String error) {
    return AttendanceHistoryResponse(error: error, isSuccess: false);
  }
}
