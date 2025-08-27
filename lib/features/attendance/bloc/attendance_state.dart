// lib/features/attendance/bloc/attendance_state.dart - UPDATED
import 'package:equatable/equatable.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {
  const AttendanceInitial();
}

class QRScannerInitializing extends AttendanceState {
  const QRScannerInitializing();
}

class QRScannerReady extends AttendanceState {
  final bool hasPermission;

  const QRScannerReady({required this.hasPermission});

  @override
  List<Object?> get props => [hasPermission];
}

class QRScannerError extends AttendanceState {
  final String message;

  const QRScannerError(this.message);

  @override
  List<Object?> get props => [message];
}

class AttendanceScanning extends AttendanceState {
  final List<ScannedStudentInfo> scannedStudents;
  final bool isScanning;

  const AttendanceScanning({
    required this.scannedStudents,
    required this.isScanning,
  });

  @override
  List<Object?> get props => [scannedStudents, isScanning];

  AttendanceScanning copyWith({
    List<ScannedStudentInfo>? scannedStudents,
    bool? isScanning,
  }) {
    return AttendanceScanning(
      scannedStudents: scannedStudents ?? this.scannedStudents,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

class AttendanceSubmitting extends AttendanceState {
  final List<ScannedStudentInfo> scannedStudents;

  const AttendanceSubmitting({required this.scannedStudents});

  @override
  List<Object?> get props => [scannedStudents];
}

class AttendanceSubmitted extends AttendanceState {
  final String message;
  final int successCount;
  final List<String>? invalidCodes;

  const AttendanceSubmitted({
    required this.message,
    required this.successCount,
    this.invalidCodes,
  });

  @override
  List<Object?> get props => [message, successCount, invalidCodes];
}

class AttendanceSubmissionError extends AttendanceState {
  final String message;
  final List<String>? invalidCodes;

  const AttendanceSubmissionError({
    required this.message,
    this.invalidCodes,
  });

  @override
  List<Object?> get props => [message, invalidCodes];
}

// ✅ UPDATED: Model cho scanned student info với rawQRData
class ScannedStudentInfo extends Equatable {
  final String studentCode;
  final String displayName;
  final DateTime scannedAt;
  final String? className;
  final String? rawQRData; // ✅ Thêm để debug

  const ScannedStudentInfo({
    required this.studentCode,
    required this.displayName,
    required this.scannedAt,
    this.className,
    this.rawQRData,
  });

  @override
  List<Object?> get props => [studentCode, displayName, scannedAt, className, rawQRData];
}