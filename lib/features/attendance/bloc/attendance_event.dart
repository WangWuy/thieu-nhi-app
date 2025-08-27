// lib/features/attendance/bloc/attendance_event.dart
import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class InitializeQRScanner extends AttendanceEvent {
  const InitializeQRScanner();
}

class ScanQRCode extends AttendanceEvent {
  final String qrData;

  const ScanQRCode(this.qrData);

  @override
  List<Object?> get props => [qrData];
}

class RemoveScannedStudent extends AttendanceEvent {
  final String studentCode;

  const RemoveScannedStudent(this.studentCode);

  @override
  List<Object?> get props => [studentCode];
}

class ClearAllScannedStudents extends AttendanceEvent {
  const ClearAllScannedStudents();
}

class SubmitUniversalAttendance extends AttendanceEvent {
  final List<String> studentCodes;
  final DateTime attendanceDate;
  final String attendanceType;
  final String? note;

  const SubmitUniversalAttendance({
    required this.studentCodes,
    required this.attendanceDate,
    required this.attendanceType,
    this.note,
  });

  @override
  List<Object?> get props =>
      [studentCodes, attendanceDate, attendanceType, note];
}

class ResetAttendanceState extends AttendanceEvent {
  const ResetAttendanceState();
}
