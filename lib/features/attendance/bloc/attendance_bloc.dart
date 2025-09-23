// lib/features/attendance/bloc/attendance_bloc.dart - IMMEDIATE ATTENDANCE
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thieu_nhi_app/core/services/qr_scanner_service.dart';
import 'package:thieu_nhi_app/core/services/attendance_service.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceService _attendanceService;
  final Set<String> _processedCodes = {};

  AttendanceBloc({
    required AttendanceService attendanceService,
  })  : _attendanceService = attendanceService,
        super(const AttendanceInitial()) {
    on<InitializeQRScanner>(_onInitializeQRScanner);
    on<ScanQRCode>(_onScanQRCode);
    on<ManualAttendance>(_onManualAttendance); // ✅ SIMPLIFIED
    on<UndoAttendance>(_onUndoAttendance); // ✅ NEW
    on<ResetAttendanceState>(_onResetAttendanceState);
  }

  Future<void> _onInitializeQRScanner(
    InitializeQRScanner event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const QRScannerInitializing());

    try {
      // Check if camera permission is granted
      final hasPermission = await QRScannerService.ensureCameraPermission();

      if (hasPermission) {
        emit(const QRScannerReady(hasPermission: true));
      } else {
        emit(const QRScannerReady(hasPermission: false));
      }
    } catch (e) {
      print('QR Scanner initialization error: $e');
      emit(QRScannerError('Lỗi khởi tạo camera: $e'));
    }
  }

  Future<void> _onScanQRCode(
    ScanQRCode event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      // ✅ Parse student info
      QRStudentInfo? studentInfo =
          QRScannerService.parseStudentInfo(event.qrData);

      if (studentInfo == null || studentInfo.studentCode.isEmpty) {
        emit(const QRScannerError('Mã QR không hợp lệ'));
        await Future.delayed(const Duration(seconds: 2));
        emit(const QRScannerReady(hasPermission: true));
        return;
      }

      final studentCode = studentInfo.studentCode;

      // ✅ Check if already processed recently (anti-spam)
      if (_processedCodes.contains(studentCode)) {
        emit(const QRScannerError('Thiếu nhi đã được điểm danh'));
        await Future.delayed(const Duration(seconds: 2));
        emit(const QRScannerReady(hasPermission: true));
        return;
      }

      // ✅ Show processing state
      emit(AttendanceProcessing(
        studentCode: studentCode,
        studentName: studentInfo.studentName ?? 'Thiếu nhi $studentCode',
      ));

      // ✅ IMMEDIATE ATTENDANCE - Call API right away
      final result = await _attendanceService.submitUniversalAttendance(
        studentCodes: [studentCode],
        attendanceDate: DateTime.now(),
        attendanceType: _getAttendanceType(),
        note: 'QR Scan - ${studentInfo.studentName ?? studentCode}',
      );

      if (result.isSuccess) {
        // ✅ Add to processed set
        _processedCodes.add(studentCode);

        // ✅ Show success
        emit(AttendanceSuccess(
          studentCode: studentCode,
          studentName: studentInfo.studentName ?? 'Thiếu nhi $studentCode',
          message: 'Điểm danh thành công!',
        ));

        QRScannerService.successFeedback();

        // ✅ Auto return to scanning after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        emit(const QRScannerReady(hasPermission: true));
      } else {
        emit(AttendanceError(
          studentCode: studentCode,
          studentName: studentInfo.studentName ?? 'Thiếu nhi $studentCode',
          error: result.error ?? 'Lỗi điểm danh',
        ));

        // ✅ Return to scanning after error
        await Future.delayed(const Duration(seconds: 3));
        emit(const QRScannerReady(hasPermission: true));
      }
    } catch (e) {
      print('💥 QR processing error: $e');
      emit(QRScannerError('Lỗi xử lý QR: $e'));

      await Future.delayed(const Duration(seconds: 2));
      emit(const QRScannerReady(hasPermission: true));
    }
  }

  Future<void> _onManualAttendance(
    ManualAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      emit(AttendanceProcessing(
        studentCode: event.studentCode,
        studentName: event.studentName,
        isUndo: false,
      ));

      final result = await _attendanceService.submitUniversalAttendance(
        studentCodes: [event.studentCode],
        attendanceDate: DateTime.now(),
        attendanceType: _getAttendanceType(),
        note: 'Manual Present Entry - ${event.studentName}',
      );

      if (result.isSuccess) {
        emit(AttendanceSuccess(
          studentCode: event.studentCode,
          studentName: event.studentName,
          message: 'Điểm danh thành công!',
          isUndo: false,
        ));
      } else {
        emit(AttendanceError(
          studentCode: event.studentCode,
          studentName: event.studentName,
          error: result.error ?? 'Lỗi điểm danh',
        ));
      }
    } catch (e) {
      emit(AttendanceError(
        studentCode: event.studentCode,
        studentName: event.studentName,
        error: 'Lỗi kết nối: $e',
      ));
    }
  }

   // ✅ NEW: Handle undo attendance
  Future<void> _onUndoAttendance(
    UndoAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      emit(AttendanceProcessing(
        studentCode: event.studentCode,
        studentName: event.studentName,
        isUndo: true,
      ));

      final result = await _attendanceService.undoAttendance(
        studentCodes: [event.studentCode],
        attendanceDate: DateTime.now(),
        attendanceType: _getAttendanceType(),
        note: 'Undo attendance - ${event.studentName}',
      );

      print('🔍 Undo result: isSuccess=${result.isSuccess}, error=${result.error}');

      if (result.isSuccess) {
        // Remove from processed codes to allow re-attendance
        _processedCodes.remove(event.studentCode);

        print('✅ Emitting AttendanceSuccess with isUndo=true');
        emit(AttendanceSuccess(
          studentCode: event.studentCode,
          studentName: event.studentName,
          message: 'Đã hủy điểm danh thành công!',
          isUndo: true,
        ));
      } else {
        print('❌ Emitting AttendanceError');
        emit(AttendanceError(
          studentCode: event.studentCode,
          studentName: event.studentName,
          error: result.error ?? 'Lỗi hủy điểm danh',
        ));
      }
    } catch (e) {
      print('💥 Exception in _onUndoAttendance: $e');
      emit(AttendanceError(
        studentCode: event.studentCode,
        studentName: event.studentName,
        error: 'Lỗi kết nối: $e',
      ));
    }
  }

  Future<void> _onResetAttendanceState(
    ResetAttendanceState event,
    Emitter<AttendanceState> emit,
  ) async {
    _processedCodes.clear();
    emit(const AttendanceInitial());
  }

  String _getAttendanceType() {
    final now = DateTime.now();
    return now.weekday == 7 ? 'sunday' : 'thursday';
  }
}
