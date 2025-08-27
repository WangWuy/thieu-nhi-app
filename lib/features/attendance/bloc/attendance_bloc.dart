// lib/features/attendance/bloc/attendance_bloc.dart - UPDATED
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thieu_nhi_app/core/services/qr_scanner_service.dart';
import 'package:thieu_nhi_app/core/services/attendance_service.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final AttendanceService _attendanceService;
  final Set<String> _scannedCodes = {};

  AttendanceBloc({
    required AttendanceService attendanceService,
  })  : _attendanceService = attendanceService,
        super(const AttendanceInitial()) {
    on<InitializeQRScanner>(_onInitializeQRScanner);
    on<ScanQRCode>(_onScanQRCode);
    on<RemoveScannedStudent>(_onRemoveScannedStudent);
    on<ClearAllScannedStudents>(_onClearAllScannedStudents);
    on<SubmitUniversalAttendance>(_onSubmitUniversalAttendance);
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
        emit(const AttendanceScanning(
          scannedStudents: [],
          isScanning: true,
        ));
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
    final currentState = state;
    if (currentState is! AttendanceScanning) return;

    try {
      // ✅ UPDATED: Sử dụng parseStudentInfo thay vì parseStudentId
      QRStudentInfo? studentInfo = QRScannerService.parseStudentInfo(event.qrData);

      if (studentInfo == null || studentInfo.studentCode.isEmpty) {
        emit(const QRScannerError('Mã QR không hợp lệ'));
        await Future.delayed(const Duration(seconds: 2));
        emit(currentState);
        return;
      }

      final studentCode = studentInfo.studentCode;
      
      // Check duplicate
      if (_scannedCodes.contains(studentCode)) {
        emit(const QRScannerError('Thiếu nhi đã được quét'));
        await Future.delayed(const Duration(seconds: 2));
        emit(currentState);
        return;
      }

      // Add to scanned list
      _scannedCodes.add(studentCode);

      // ✅ UPDATED: Sử dụng tên thật thay vì tên generic
      final displayName = studentInfo.studentName ?? 'Thiếu nhi $studentCode';
      
      final newStudent = ScannedStudentInfo(
        studentCode: studentCode,
        displayName: displayName,
        scannedAt: DateTime.now(),
        // Có thể thêm rawData để debug
        rawQRData: studentInfo.rawData,
      );

      final updatedStudents = [...currentState.scannedStudents, newStudent];

      QRScannerService.successFeedback();

      emit(currentState.copyWith(
        scannedStudents: updatedStudents,
      ));
      
      print('✅ Added student: $displayName ($studentCode)');
      
    } catch (e) {
      print('💥 QR processing error: $e');
      emit(QRScannerError('Lỗi xử lý QR: $e'));

      await Future.delayed(const Duration(seconds: 2));
      emit(currentState);
    }
  }

  Future<void> _onRemoveScannedStudent(
    RemoveScannedStudent event,
    Emitter<AttendanceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AttendanceScanning) return;

    _scannedCodes.remove(event.studentCode);

    final updatedStudents = currentState.scannedStudents
        .where((student) => student.studentCode != event.studentCode)
        .toList();

    emit(currentState.copyWith(scannedStudents: updatedStudents));
  }

  Future<void> _onClearAllScannedStudents(
    ClearAllScannedStudents event,
    Emitter<AttendanceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AttendanceScanning) return;

    _scannedCodes.clear();
    emit(currentState.copyWith(scannedStudents: []));
  }

  Future<void> _onSubmitUniversalAttendance(
    SubmitUniversalAttendance event,
    Emitter<AttendanceState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AttendanceScanning) return;

    emit(AttendanceSubmitting(scannedStudents: currentState.scannedStudents));

    try {
      final result = await _attendanceService.submitUniversalAttendance(
        studentCodes: event.studentCodes,
        attendanceDate: event.attendanceDate,
        attendanceType: event.attendanceType,
        note: event.note,
      );

      if (result.isSuccess) {
        emit(AttendanceSubmitted(
          message: result.message ?? 'Điểm danh thành công',
          successCount: result.count ?? 0,
          invalidCodes: result.invalidStudentCodes,
        ));
      } else {
        emit(AttendanceSubmissionError(
          message: result.error ?? 'Lỗi điểm danh',
          invalidCodes: result.invalidStudentCodes,
        ));
      }
    } catch (e) {
      emit(AttendanceSubmissionError(
        message: 'Lỗi kết nối: $e',
      ));
    }
  }

  Future<void> _onResetAttendanceState(
    ResetAttendanceState event,
    Emitter<AttendanceState> emit,
  ) async {
    _scannedCodes.clear();
    emit(const AttendanceInitial());
  }
}