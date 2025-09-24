// lib/features/attendance/screens/qr_scanner_screen.dart - FIXED CAMERA PERMISSION
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
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
  bool _isInitializing = false;

  // Anti-spam mechanism
  String? lastDetectedCode;
  DateTime? lastDetectionTime;
  static const Duration cooldownDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      // Check permission first
      final hasPermission = await Permission.camera.isGranted;

      if (!hasPermission) {
        // Check if permission is permanently denied
        final isPermanentlyDenied =
            await QRScannerService.isPermissionPermanentlyDenied();

        if (isPermanentlyDenied) {
          _showPermissionDeniedDialog();
          setState(() {
            _isInitializing = false;
          });
          return;
        }

        // Request permission
        final status = await QRScannerService.requestCameraPermission();
        if (!status.isGranted) {
          setState(() {
            _isInitializing = false;
          });
          return;
        }
      }

      // Only create controller if we don't have one
      controller ??= await _createControllerWithRetry();

      if (controller != null) {
        context.read<AttendanceBloc>().add(const InitializeQRScanner());
      } else {
        _showCameraErrorDialog();
      }
    } catch (e) {
      print('Camera initialization error: $e');
      _showCameraErrorDialog();
    } finally {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quyền camera bị từ chối'),
        content: const Text(
          'Ứng dụng cần quyền camera để quét mã QR.\n\nTrên iOS:\n- Vào Cài đặt > Quyền riêng tư & Bảo mật > Camera và bật cho ứng dụng,\n  hoặc Cài đặt > [Tên ứng dụng] > bật Camera (chỉ xuất hiện sau khi ứng dụng đã xin quyền ít nhất 1 lần).\n- Nếu không thấy mục Camera: bạn có thể đang dùng giả lập (không có camera),\n  hoặc Camera bị giới hạn bởi Screen Time: Cài đặt > Thời gian sử dụng > Nội dung & quyền riêng tư > Ứng dụng được phép > bật Camera.\n- Nếu vẫn không được, vào Cài đặt > Cài đặt chung > Chuyển hoặc đặt lại iPhone > Đặt lại > Đặt lại vị trí & quyền riêng tư.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Mở Cài đặt'),
          ),
        ],
      ),
    );
  }

  void _showCameraErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi camera'),
        content: const Text(
          'Không thể khởi tạo camera. Vui lòng thử lại hoặc kiểm tra quyền camera.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeCamera();
            },
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Future<MobileScannerController?> _createControllerWithRetry() async {
    try {
      print('Creating camera controller...');

      // Use the service method to create controller
      final controller = await QRScannerService.createSafeController();

      if (controller != null) {
        print('Camera controller created successfully');
        return controller;
      } else {
        print('Failed to create camera controller');
        return null;
      }
    } catch (e) {
      print('Camera controller creation failed: $e');
      return null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // MobileScanner widget handles lifecycle automatically
    // We don't need to manually start/stop the controller
    switch (state) {
      case AppLifecycleState.resumed:
        // Camera will resume automatically when widget is rebuilt
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        // Camera will pause automatically
        break;
      default:
        break;
    }
  }

  @override
  void deactivate() {
    // MobileScanner widget handles deactivation automatically
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Only dispose, don't call stop() as it's handled by MobileScanner widget
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
    // Show loading if initializing
    if (_isInitializing || state is QRScannerInitializing) {
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

    // Show camera view if we have a controller and permission
    if (controller != null && _hasCameraPermission()) {
      return BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, currentState) {
          return Stack(
            children: [
              // Camera view - Full screen
              QRCameraView(
                controller: controller,
                isProcessing: currentState is AttendanceProcessing,
                onQRDetected: _handleBarcodeDetection,
              ),

              // Status overlay
              if (currentState is AttendanceProcessing)
                _buildProcessingOverlay(currentState),

              if (currentState is AttendanceSuccess)
                _buildSuccessOverlay(currentState),

              if (currentState is AttendanceError)
                _buildErrorOverlay(currentState),
            ],
          );
        },
      );
    }

    // Show permission screen if no controller or no permission
    return _buildPermissionScreen();
  }

  bool _hasCameraPermission() {
    // Check if we have permission based on state
    return true; // We'll assume permission is granted if we have a controller
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
          const SizedBox(height: 16),
          const Text(
            'Ứng dụng cần quyền camera để quét mã QR điểm danh',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _isInitializing ? null : _handlePermissionButtonPressed,
            icon: _isInitializing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.camera_alt),
            label:
                Text(_isInitializing ? 'Đang khởi tạo...' : 'Cấp quyền camera'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Quay lại',
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePermissionButtonPressed() async {
    try {
      final status = await Permission.camera.status;
      _showInfo('Camera status trước request: $status');
      if (status.isPermanentlyDenied) {
        await openAppSettings();
        return;
      }

      if (status.isDenied || status.isRestricted || status.isLimited) {
        final request = await QRScannerService.requestCameraPermission();
        _showInfo('Kết quả request camera: $request');
        if (!mounted) return;
        if (request.isGranted) {
          await _initializeCamera();
        } else if (request.isPermanentlyDenied) {
          await openAppSettings();
        }
        return;
      }

      await _initializeCamera();
    } catch (_) {
      await _initializeCamera();
    }
  }

  void _showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
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
              const Text(
                'Đang điểm danh...',
                style: TextStyle(
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
