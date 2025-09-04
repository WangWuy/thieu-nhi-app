// lib/features/attendance/screens/qr_scanner_screen.dart - SIMPLIFIED VERSION
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:thieu_nhi_app/core/services/qr_scanner_service.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_bloc.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_event.dart';
import 'package:thieu_nhi_app/features/attendance/bloc/attendance_state.dart';
import 'package:thieu_nhi_app/features/attendance/screens/widgets/qr_camera_view.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen>
    with WidgetsBindingObserver {
  MobileScannerController? controller;
  bool _torchEnabled = false;

  // Anti-spam mechanism
  String? lastDetectedCode;
  DateTime? lastDetectionTime;
  static const Duration cooldownDuration = Duration(seconds: 3);

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
        if (mounted) controller!.start();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        controller!.stop();
        break;
      default:
        break;
    }
  }

  @override
  void deactivate() {
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
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, AttendanceState state) {
    if (state is QRScannerError) {
      _showError(state.message);
    } else if (state is AttendanceSuccess) {
      _showSuccess('✅ ${state.studentName} - ${state.message}');
    } else if (state is AttendanceError) {
      _showError('❌ ${state.studentName} - ${state.error}');
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

    return Stack(
      children: [
        // Camera view - Full screen
        QRCameraView(
          controller: controller,
          isProcessing: state is AttendanceProcessing,
          onQRDetected: _handleBarcodeDetection,
        ),
        
        // Status overlay
        if (state is AttendanceProcessing)
          _buildProcessingOverlay(state),
        
        if (state is AttendanceSuccess)
          _buildSuccessOverlay(state),
          
        if (state is AttendanceError)
          _buildErrorOverlay(state),
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

  Widget _buildProcessingOverlay(AttendanceProcessing state) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: AppColors.secondary,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Đang điểm danh...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.studentName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay(AttendanceSuccess state) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Điểm danh thành công!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.studentName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(AttendanceError state) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Điểm danh thất bại',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.studentName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                state.error,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBarcodeDetection(BarcodeCapture capture) async {
    final studentInfo = QRScannerService.processBarcodeCapture(capture);
    if (studentInfo == null) return;

    final qrData = studentInfo.studentCode;
    final now = DateTime.now();

    // Anti-spam check
    if (lastDetectedCode == qrData &&
        lastDetectionTime != null &&
        now.difference(lastDetectionTime!) < cooldownDuration) {
      return;
    }

    lastDetectedCode = qrData;
    lastDetectionTime = now;

    context.read<AttendanceBloc>().add(ScanQRCode(studentInfo.rawData));
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
}