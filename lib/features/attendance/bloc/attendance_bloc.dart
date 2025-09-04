// lib/features/attendance/bloc/attendance_bloc.dart - IMMEDIATE ATTENDANCE
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thieu_nhi_app/core/services/qr_scanner_service.dart';
import 'package:thieu_nhi_app/core/services/attendance_service.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceService _attendanceService;
  final Set<String> _processedCodes = {}; // Track processed codes to avoid duplicates

  AttendanceBloc({
    required AttendanceService attendanceService,
  })  : _attendanceService = attendanceService,
        super(const AttendanceInitial()) {
    on<InitializeQRScanner>(_onInitializeQRScanner);
    on<ScanQRCode>(_onScanQRCode);
    on<ManualAttendance>(_onManualAttendance); // ✅ NEW: Manual attendance
    on<ResetAttendanceState>(_onResetAttendanceState);
  }

  Future<void> _onInitializeQRScanner(
    InitializeQRScanner event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(const QRScannerInitializing());

    try {
      final hasPermission = await QRScannerService.ensureCameraPermission();

      if (hasPermission) {
        emit(const QRScannerReady(hasPermission: true));
      } else {
        emit(const QRScannerReady(hasPermission: false));
      }
    } catch (e) {
      emit(QRScannerError('Lỗi khởi tạo camera: $e'));
    }
  }

  Future<void> _onScanQRCode(
    ScanQRCode event,
    Emitter<AttendanceState> emit,
  ) async {
    try {
      // ✅ Parse student info
      QRStudentInfo? studentInfo = QRScannerService.parseStudentInfo(event.qrData);

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
      // Check duplicate
      if (_processedCodes.contains(event.studentCode)) {
        emit(const QRScannerError('Thiếu nhi đã được điểm danh'));
        return;
      }

      emit(AttendanceProcessing(
        studentCode: event.studentCode,
        studentName: event.studentName,
        isPresent: event.isPresent, // ✅ Include presence status
      ));

      final result = await _attendanceService.submitUniversalAttendance(
        studentCodes: [event.studentCode],
        attendanceDate: DateTime.now(),
        attendanceType: _getAttendanceType(),
        isPresent: event.isPresent, // ✅ Pass presence status
        note: event.isPresent 
            ? 'Manual Present Entry - ${event.studentName}'
            : 'Manual Absent Entry - ${event.studentName}',
      );

      if (result.isSuccess) {
        _processedCodes.add(event.studentCode);
        
        emit(AttendanceSuccess(
          studentCode: event.studentCode,
          studentName: event.studentName,
          message: event.isPresent ? 'Điểm danh có mặt thành công!' : 'Điểm danh vắng mặt thành công!',
          isPresent: event.isPresent, // ✅ Include in success state
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