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

// ✅ UPDATED: Processing individual attendance with presence status
class AttendanceProcessing extends AttendanceState {
  final String studentCode;
  final String studentName;
  final bool isPresent; // ✅ NEW: Track if marking present or absent

  const AttendanceProcessing({
    required this.studentCode,
    required this.studentName,
    this.isPresent = true, // ✅ Default present
  });

  @override
  List<Object?> get props => [studentCode, studentName, isPresent];
}

// ✅ UPDATED: Individual attendance success with presence status
class AttendanceSuccess extends AttendanceState {
  final String studentCode;
  final String studentName;
  final String message;
  final bool isPresent; // ✅ NEW: Track final presence status

  const AttendanceSuccess({
    required this.studentCode,
    required this.studentName,
    required this.message,
    this.isPresent = true, // ✅ Default present
  });

  @override
  List<Object?> get props => [studentCode, studentName, message, isPresent];
}

// Keep AttendanceError unchanged
class AttendanceError extends AttendanceState {
  final String studentCode;
  final String studentName;
  final String error;

  const AttendanceError({
    required this.studentCode,
    required this.studentName,
    required this.error,
  });

  @override
  List<Object?> get props => [studentCode, studentName, error];
}