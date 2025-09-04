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

// ✅ UPDATED: Manual attendance with isPresent parameter
class ManualAttendance extends AttendanceEvent {
  final String studentCode;
  final String studentName;
  final bool isPresent; // ✅ NEW: Support absent marking

  const ManualAttendance({
    required this.studentCode,
    required this.studentName,
    this.isPresent = true, // ✅ Default present
  });

  @override
  List<Object?> get props => [studentCode, studentName, isPresent];
}

class ResetAttendanceState extends AttendanceEvent {
  const ResetAttendanceState();
}