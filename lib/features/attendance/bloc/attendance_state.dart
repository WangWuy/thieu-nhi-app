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

// ✅ SIMPLIFIED: Processing individual attendance
class AttendanceProcessing extends AttendanceState {
  final String studentCode;
  final String studentName;
  final bool isUndo; // Track if this is undo operation

  const AttendanceProcessing({
    required this.studentCode,
    required this.studentName,
    this.isUndo = false,
  });

  @override
  List<Object?> get props => [studentCode, studentName, isUndo];
}

// ✅ SIMPLIFIED: Individual attendance success
class AttendanceSuccess extends AttendanceState {
  final String studentCode;
  final String studentName;
  final String message;
  final bool isUndo; // Track if this was undo operation

  const AttendanceSuccess({
    required this.studentCode,
    required this.studentName,
    required this.message,
    this.isUndo = false,
  });

  @override
  List<Object?> get props => [studentCode, studentName, message, isUndo];
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