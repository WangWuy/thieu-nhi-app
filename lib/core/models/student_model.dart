import 'package:equatable/equatable.dart';
import 'package:thieu_nhi_app/core/models/attendance_models.dart';

class StudentModel extends Equatable {
  final String id;
  final String? qrId; // studentCode từ backend
  final String? qrRawData; // qrCode từ backend
  final String name; // fullName từ backend
  final String phone;
  final String parentPhone;
  final String address;
  final DateTime birthDate;
  final String classId;
  final String className;
  final String department;
  final String? note;

  // Attendance & grades data
  final Map<String, bool> attendance;
  final List<double> grades;

  final String? photoUrl;
  final String? avatarUrl;
  final String? avatarPublicId;
  final bool? isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Backend API specific fields - thêm vào model cũ
  final String? saintName;
  final String? parentPhone2;
  final int? thursdayAttendanceCount;
  final int? sundayAttendanceCount;
  final double? attendanceAverage;
  final double? study45Hk1;
  final double? examHk1;
  final double? study45Hk2;
  final double? examHk2;
  final double? studyAverage;
  final double? finalAverage;
  final int? academicYearId;
  final String? academicYearName;
  final int? academicYearTotalWeeks;
  final DateTime? academicYearStartDate;
  final DateTime? academicYearEndDate;
  final bool? academicYearIsCurrent;
  final bool? academicYearIsActive;
  final double? thursdayScore;
  final double? sundayScore;
  final AttendanceProgress? thursdayProgress;
  final AttendanceProgress? sundayProgress;
  final List<AttendanceRecord>? recentAttendance;

  const StudentModel({
    required this.id,
    this.qrId,
    this.qrRawData,
    required this.name,
    required this.phone,
    required this.parentPhone,
    required this.address,
    required this.birthDate,
    required this.classId,
    required this.className,
    required this.department,
    required this.attendance,
    required this.grades,
    this.photoUrl,
    this.avatarUrl,
    this.avatarPublicId,
    this.isActive,
    required this.createdAt,
    required this.updatedAt,
    // New fields
    this.saintName,
    this.parentPhone2,
    this.thursdayAttendanceCount,
    this.sundayAttendanceCount,
    this.attendanceAverage,
    this.study45Hk1,
    this.examHk1,
    this.study45Hk2,
    this.examHk2,
    this.studyAverage,
    this.finalAverage,
    this.academicYearId,
    this.academicYearName,
    this.academicYearTotalWeeks,
    this.academicYearStartDate,
    this.academicYearEndDate,
    this.academicYearIsCurrent,
    this.academicYearIsActive,
    this.thursdayScore,
    this.sundayScore,
    this.thursdayProgress,
    this.sundayProgress,
    this.recentAttendance,
    this.note,
  });

  // Helper getters - giữ nguyên
  String get scanningId => qrId ?? id;
  bool get hasValidQR => qrId != null && qrId!.isNotEmpty;

  // Updated getter - ưu tiên backend data
  double get averageGrade {
    if (finalAverage != null) return finalAverage!;
    if (studyAverage != null) return studyAverage!;
    if (grades.isEmpty) return 0.0;
    return grades.reduce((a, b) => a + b) / grades.length;
  }

  int get attendanceCount =>
      attendance.values.where((present) => present).length;
  int get absenceCount => attendance.values.where((present) => !present).length;

  // Updated getter - ưu tiên backend data
  double get attendanceRate {
    if (attendanceAverage != null) return attendanceAverage!;
    if (attendance.isEmpty) return 0.0;
    return (attendanceCount / attendance.length) * 100;
  }

  StudentModel copyWith({
    String? id,
    String? qrId,
    String? qrRawData,
    String? name,
    String? phone,
    String? parentPhone,
    String? address,
    DateTime? birthDate,
    String? classId,
    String? className,
    String? department,
    Map<String, bool>? attendance,
    List<double>? grades,
    String? photoUrl,
    String? avatarUrl,
    String? avatarPublicId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? note,

    // New copyWith params
    String? saintName,
    String? parentPhone2,
    int? thursdayAttendanceCount,
    int? sundayAttendanceCount,
    double? attendanceAverage,
    double? study45Hk1,
    double? examHk1,
    double? study45Hk2,
    double? examHk2,
    double? studyAverage,
    double? finalAverage,
    int? academicYearId,
    String? academicYearName,
    int? academicYearTotalWeeks,
    DateTime? academicYearStartDate,
    DateTime? academicYearEndDate,
    bool? academicYearIsCurrent,
    bool? academicYearIsActive,
    double? thursdayScore,
    double? sundayScore,
    AttendanceProgress? thursdayProgress,
    AttendanceProgress? sundayProgress,
    List<AttendanceRecord>? recentAttendance,
  }) {
    return StudentModel(
      id: id ?? this.id,
      qrId: qrId ?? this.qrId,
      qrRawData: qrRawData ?? this.qrRawData,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      parentPhone: parentPhone ?? this.parentPhone,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      department: department ?? this.department,
      attendance: attendance ?? this.attendance,
      grades: grades ?? this.grades,
      photoUrl: photoUrl ?? this.photoUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarPublicId: avatarPublicId ?? this.avatarPublicId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      note: note ?? this.note,
      
      // New fields
      saintName: saintName ?? this.saintName,
      parentPhone2: parentPhone2 ?? this.parentPhone2,
      thursdayAttendanceCount: thursdayAttendanceCount ?? this.thursdayAttendanceCount,
      sundayAttendanceCount: sundayAttendanceCount ?? this.sundayAttendanceCount,
      attendanceAverage: attendanceAverage ?? this.attendanceAverage,
      study45Hk1: study45Hk1 ?? this.study45Hk1,
      examHk1: examHk1 ?? this.examHk1,
      study45Hk2: study45Hk2 ?? this.study45Hk2,
      examHk2: examHk2 ?? this.examHk2,
      studyAverage: studyAverage ?? this.studyAverage,
      finalAverage: finalAverage ?? this.finalAverage,
      academicYearId: academicYearId ?? this.academicYearId,
      academicYearName: academicYearName ?? this.academicYearName,
      academicYearTotalWeeks: academicYearTotalWeeks ?? this.academicYearTotalWeeks,
      academicYearStartDate: academicYearStartDate ?? this.academicYearStartDate,
      academicYearEndDate: academicYearEndDate ?? this.academicYearEndDate,
      academicYearIsCurrent: academicYearIsCurrent ?? this.academicYearIsCurrent,
      academicYearIsActive: academicYearIsActive ?? this.academicYearIsActive,
      thursdayScore: thursdayScore ?? this.thursdayScore,
      sundayScore: sundayScore ?? this.sundayScore,
      thursdayProgress: thursdayProgress ?? this.thursdayProgress,
      sundayProgress: sundayProgress ?? this.sundayProgress,
      recentAttendance: recentAttendance ?? this.recentAttendance,
    );
  }

  @override
  List<Object?> get props => [
        id,
        qrId,
        qrRawData,
        name,
        phone,
        parentPhone,
        address,
        birthDate,
        classId,
        className,
        department,
        attendance,
        grades,
        photoUrl,
        avatarUrl,
        avatarPublicId,
        isActive,
        createdAt,
        updatedAt,
        // New props
        saintName,
        parentPhone2,
        thursdayAttendanceCount,
        sundayAttendanceCount,
        attendanceAverage,
        study45Hk1,
        examHk1,
        study45Hk2,
        examHk2,
        studyAverage,
        finalAverage,
        academicYearId,
        academicYearName,
        academicYearTotalWeeks,
        academicYearStartDate,
        academicYearEndDate,
        academicYearIsCurrent,
        academicYearIsActive,
        thursdayScore,
        sundayScore,
        thursdayProgress,
        sundayProgress,
        recentAttendance,
      ];
}

class AttendanceProgress extends Equatable {
  final int attended;
  final int total;
  final int percentage;
  final double? score;

  const AttendanceProgress({
    required this.attended,
    required this.total,
    required this.percentage,
    this.score,
  });

  factory AttendanceProgress.fromJson(Map<String, dynamic> json) {
    return AttendanceProgress(
      attended: _parseInt(json['attended']),
      total: _parseInt(json['total']),
      percentage: _parseInt(json['percentage']),
      score: _parseDouble(json['score']),
    );
  }

  @override
  List<Object?> get props => [attended, total, percentage, score];

  static int _parseInt(dynamic value) => int.tryParse(value?.toString() ?? '') ?? 0;
  static double? _parseDouble(dynamic value) =>
      value == null ? null : double.tryParse(value.toString());
}

// StudentAttendanceRecord - specifically for student detail history
class StudentAttendanceRecord extends Equatable {
  final int id;
  final int studentId;
  final DateTime attendanceDate;
  final String attendanceType; // 'thursday' or 'sunday'
  final bool isPresent;
  final String? note;
  final DateTime markedAt;

  const StudentAttendanceRecord({
    required this.id,
    required this.studentId,
    required this.attendanceDate,
    required this.attendanceType,
    required this.isPresent,
    this.note,
    required this.markedAt,
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
      ];

  factory StudentAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceRecord(
      id: json['id'],
      studentId: json['studentId'],
      attendanceDate: DateTime.parse(json['attendanceDate']),
      attendanceType: json['attendanceType'],
      isPresent: json['isPresent'],
      note: json['note'],
      markedAt: DateTime.parse(json['markedAt']),
    );
  }
}
