// lib/features/attendance/widgets/qr_camera_view.dart - REMOVED CIRCLE BORDER
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:thieu_nhi_app/theme/app_colors.dart';

class QRCameraView extends StatefulWidget {
  final MobileScannerController? controller;
  final bool isProcessing;
  final Function(BarcodeCapture) onQRDetected;

  const QRCameraView({
    super.key,
    required this.controller,
    required this.isProcessing,
    required this.onQRDetected,
  });

  @override
  State<QRCameraView> createState() => _QRCameraViewState();
}

class _QRCameraViewState extends State<QRCameraView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Stack(
        children: [
          // Camera view
          if (widget.controller != null)
            MobileScanner(
              controller: widget.controller!,
              onDetect: widget.onQRDetected,
            ),

          // ✅ CLEAN Scanning overlay - CHỈ CÓ 4 GÓC VUÔNG
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                children: [
                  // Corner indicators ONLY - BỎ KHUNG TRÒN
                  ..._buildCornerIndicators(),

                  // Animated scanning line
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: _animation.value * 250,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.8),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Center instructions
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Quét mã QR thiếu nhi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 2)
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '✨ Giữ ổn định\n📱 Tránh rung lắc',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 2)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Processing overlay
          if (widget.isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang xử lý...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerIndicators() {
    const cornerSize = 25.0; // ✅ Tăng size góc lên một chút
    const cornerThickness = 4.0;

    return [
      // Top-left corner
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: AppColors.secondary, width: cornerThickness),
              left: BorderSide(
                  color: AppColors.secondary, width: cornerThickness),
            ),
          ),
        ),
      ),
      // Top-right corner
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: AppColors.secondary, width: cornerThickness),
              right: BorderSide(
                  color: AppColors.secondary, width: cornerThickness),
            ),
          ),
        ),
      ),
      // Bottom-left corner
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: AppColors.secondary, width: cornerThickness),
              left: BorderSide(
                  color: AppColors.secondary, width: cornerThickness),
            ),
          ),
        ),
      ),
      // Bottom-right corner
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: cornerSize,
          height: cornerSize,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                  color: AppColors.secondary, width: cornerThickness),
              right: BorderSide(
                  color: AppColors.secondary, width: cornerThickness),
            ),
          ),
        ),
      ),
    ];
  }
}