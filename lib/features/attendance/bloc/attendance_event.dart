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

// ✅ SIMPLIFIED: Manual attendance - only present
class ManualAttendance extends AttendanceEvent {
  final String studentCode;
  final String studentName;

  const ManualAttendance({
    required this.studentCode,
    required this.studentName,
  });

  @override
  List<Object?> get props => [studentCode, studentName];
}

// ✅ NEW: Undo attendance event
class UndoAttendance extends AttendanceEvent {
  final String studentCode;
  final String studentName;

  const UndoAttendance({
    required this.studentCode,
    required this.studentName,
  });

  @override
  List<Object?> get props => [studentCode, studentName];
}

class ResetAttendanceState extends AttendanceEvent {
  const ResetAttendanceState();
}
