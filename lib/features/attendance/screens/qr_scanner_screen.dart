// lib/features/attendance/screens/qr_scanner_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:thieu_nhi_app/core/services/qr_scanner_service.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_bloc.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_event.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_state.dart';
import 'package:thieu_nhi_app/features/attendance/screens/manual_attendance_modal.dart';
import 'package:thieu_nhi_app/features/attendance/screens/widgets/qr_camera_view.dart';
import 'package:thieu_nhi_app/features/attendance/screens/widgets/scanned_students_list.dart';
import 'package:thieu_nhi_app/features/attendance/screens/widgets/scanner_bottom_actions.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? controller;
  bool isProcessing = false;
  bool _torchEnabled = false;

  // ✅ ANTI-SPAM MECHANISM
  String? lastDetectedCode;
  DateTime? lastDetectionTime;
  static const Duration cooldownDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    context.read<AttendanceBloc>().add(const InitializeQRScanner());
    _setupController();
  }

  void _setupController() {
    controller = QRScannerService.createOptimalController();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || !controller!.value.isInitialized) return;

    switch (state) {
      case AppLifecycleState.resumed:
        // Chỉ start khi tab này đang active
        if (mounted) controller!.start();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached: // Thêm detached state
        controller!.stop();
        break;
      default:
        break;
    }
  }

  @override
  void deactivate() {
    // Dừng camera khi chuyển tab
    controller?.stop();
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.stop();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AttendanceBloc, AttendanceState>(
      listener: _handleStateChanges,
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: _buildAppBar(state),
          body: _buildBody(state),
          bottomNavigationBar: ScannerBottomActions(
            scannedStudents: _getScannedStudents(state),
            isSubmitting: state is AttendanceSubmitting,
            onClearAll: () => context
                .read<AttendanceBloc>()
                .add(const ClearAllScannedStudents()),
            onSubmit: _handleSubmitAttendance,
          ),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, AttendanceState state) {
    if (state is QRScannerError) {
      _showError(state.message);
    } else if (state is AttendanceSubmitted) {
      _showSuccess(state.message);

      if (state.invalidCodes?.isNotEmpty == true) {
        _showInvalidCodesDialog(state.invalidCodes!);
      }

      // Sửa navigation để tránh lỗi locked
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, true);
        }
      });
    } else if (state is AttendanceSubmissionError) {
      _showError(state.message);

      if (state.invalidCodes?.isNotEmpty == true) {
        _showInvalidCodesDialog(state.invalidCodes!);
      }
    }
  }

  PreferredSizeWidget _buildAppBar(AttendanceState state) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Quét mã QR điểm danh',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_note, color: Colors.white),
          onPressed: () => _showManualAttendanceModal(),
          tooltip: 'Điểm danh thủ công',
        ),
        IconButton(
          icon: Icon(
            _torchEnabled ? Icons.flash_on : Icons.flash_off,
            color: Colors.white,
          ),
          onPressed: () async {
            await controller?.toggleTorch();
            setState(() {
              _torchEnabled = !_torchEnabled;
            });
          },
        ),
      ],
    );
  }

  Widget _buildBody(AttendanceState state) {
    if (state is QRScannerInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Đang khởi tạo camera...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (state is QRScannerReady && !state.hasPermission) {
      return _buildPermissionScreen();
    }

    return Column(
      children: [
        Expanded(
          flex: 2, // ✅ Giảm từ 3 xuống 2 - camera nhỏ hơn
          child: QRCameraView(
            controller: controller,
            isProcessing: isProcessing,
            onQRDetected: _handleBarcodeDetection,
          ),
        ),
        Expanded(
          flex: 3, // ✅ Tăng từ 2 lên 3 - list lớn hơn
          child: ScannedStudentsList(
            scannedStudents: _getScannedStudents(state),
            onRemoveStudent: (studentCode) =>
                context.read<AttendanceBloc>().add(
                      RemoveScannedStudent(studentCode),
                    ),
            onClearAll: () => context.read<AttendanceBloc>().add(
                  const ClearAllScannedStudents(),
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              size: 60,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Cần quyền truy cập camera',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AttendanceBloc>().add(const InitializeQRScanner());
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Cấp quyền camera'),
          ),
        ],
      ),
    );
  }

  // ✅ FIXED - Anti-spam barcode detection with name extraction
  void _handleBarcodeDetection(BarcodeCapture capture) async {
    if (isProcessing) return;

    final studentInfo = QRScannerService.processBarcodeCapture(capture);
    if (studentInfo == null) return;

    final qrData = studentInfo.studentCode;

    final now = DateTime.now();

    // ✅ Check if same code detected recently (anti-spam)
    if (lastDetectedCode == qrData &&
        lastDetectionTime != null &&
        now.difference(lastDetectionTime!) < cooldownDuration) {
      print('🚫 Ignored duplicate QR: "$qrData" (cooldown active)');
      return;
    }

    // Update tracking
    lastDetectedCode = qrData;
    lastDetectionTime = now;

    setState(() => isProcessing = true);

    try {
      print('📱 QR detected: "${studentInfo.rawData}"');
      print('👤 Name: ${studentInfo.studentName ?? "Unknown"}');
      context.read<AttendanceBloc>().add(ScanQRCode(studentInfo.rawData));
    } catch (e) {
      print('💥 Detection error: $e');
    }

    // Short delay to show processing state
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => isProcessing = false);
  }

  void _handleSubmitAttendance() {
    final scannedStudents =
        _getScannedStudents(context.read<AttendanceBloc>().state);
    final studentCodes = scannedStudents.map((s) => s.studentCode).toList();

    context.read<AttendanceBloc>().add(
          SubmitUniversalAttendance(
            studentCodes: studentCodes,
            attendanceDate: DateTime.now(),
            attendanceType: _getAttendanceType(),
            note: 'Universal QR Scan',
          ),
        );
  }

  // Helper methods
  List<ScannedStudentInfo> _getScannedStudents(AttendanceState state) {
    if (state is AttendanceScanning) return state.scannedStudents;
    if (state is AttendanceSubmitting) return state.scannedStudents;
    return [];
  }

  String _getAttendanceType() {
    final now = DateTime.now();
    return now.weekday == 7 ? 'sunday' : 'thursday';
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInvalidCodesDialog(List<String> invalidCodes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Một số thiếu nhi không tìm thấy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Các mã thiếu nhi sau không tìm thấy trong hệ thống:'),
            const SizedBox(height: 8),
            ...invalidCodes.map((code) => Text('• $code')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showManualAttendanceModal() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ManualAttendanceModal(),
    );

    if (result != null && mounted) {
      context.read<AttendanceBloc>().add(ScanQRCode(result));
    }
  }
}
