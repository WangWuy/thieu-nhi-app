// lib/core/services/qr_scanner_service.dart - COMPLETE VERSION
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

// ✅ Class để lưu cả mã và tên
class QRStudentInfo {
  final String studentCode;
  final String? studentName;
  final String rawData;

  QRStudentInfo({
    required this.studentCode,
    this.studentName,
    required this.rawData,
  });
}

class QRScannerService {
  static final QRScannerService _instance = QRScannerService._internal();
  factory QRScannerService() => _instance;
  QRScannerService._internal();

  // ========== CAMERA PERMISSION ==========
  
  static Future<bool> ensureCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) return true;
      
      final result = await Permission.camera.request();
      return result.isGranted;
    } catch (e) {
      return false;
    }
  }

  // ========== QR PARSING WITH NAME EXTRACTION ==========

  static QRStudentInfo? parseStudentInfo(String qrData) {
    try {
      if (qrData.isEmpty) return null;
      
      // Clean và normalize
      final cleaned = qrData.trim();
      final normalized = cleaned.toUpperCase()
          .replaceAll('Ð', 'Đ')  // Eth -> D with Stroke
          .replaceAll(RegExp(r'\s+'), ' ');
      
      // Extract student code pattern
      final codePattern = RegExp(r'([A-ZĐ]{2}\d{1,6})');
      final codeMatch = codePattern.firstMatch(normalized);
      
      if (codeMatch == null) {
        return null;
      }
      
      final studentCode = codeMatch.group(1)!;
      
      // Extract name từ QR data gốc
      String? studentName = _extractStudentName(cleaned, studentCode);
      
      return QRStudentInfo(
        studentCode: studentCode,
        studentName: studentName,
        rawData: cleaned,
      );
      
    } catch (e) {
      return null;
    }
  }

  // Helper method để extract tên từ QR data
  static String? _extractStudentName(String qrData, String studentCode) {
    try {
      // Tách theo dấu " - "
      final parts = qrData.split(' - ');
      if (parts.length >= 2) {
        final namePart = parts[1].trim();
        if (namePart.isNotEmpty) {
          // Bỏ dấu và normalize thành chữ thường
          final cleanName = _removeVietnameseAccents(namePart);
          
          if (cleanName.isNotEmpty && cleanName.length > 2) {
            return cleanName;
          }
        }
      }
      
      // Fallback: tìm tên sau mã code
      final afterCode = qrData.replaceFirst(RegExp(r'[A-ZĐ]{2}\d{1,6}'), '').trim();
      if (afterCode.isNotEmpty && afterCode.length > 2) {
        final cleanName = _removeVietnameseAccents(afterCode);
        
        if (cleanName.isNotEmpty && cleanName.length > 2) {
          return cleanName;
        }
      }
      
      return null;
      
    } catch (e) {
      return null;
    }
  }

  // Vietnamese accent removal với smart ? replacement
  static String _removeVietnameseAccents(String text) {
    String result = text;
    
    // FIRST: Replace ? with most common Vietnamese letters based on context
    result = result
        .replaceAll('?n', 'en')    // Nguy?n -> Nguyen, Thi?n -> Thien  
        .replaceAll('?ng', 'ang')  // H?ng -> Hang, L?ng -> Lang
        .replaceAll('?c', 'ac')    // Tr?c -> Trac
        .replaceAll('?i', 'ai')    // Tr?i -> Trai
        .replaceAll('?o', 'ao')    // B?o -> Bao
        .replaceAll('?u', 'au')    // C?u -> Cau
        .replaceAll('?', 'e');     // Default fallback cho ? đơn lẻ
    
    // Vietnamese to ASCII mapping
    const Map<String, String> accentMap = {
      // A variations
      'à': 'a', 'á': 'a', 'ạ': 'a', 'ả': 'a', 'ã': 'a',
      'ă': 'a', 'ằ': 'a', 'ắ': 'a', 'ặ': 'a', 'ẳ': 'a', 'ẵ': 'a',
      'â': 'a', 'ầ': 'a', 'ấ': 'a', 'ậ': 'a', 'ẩ': 'a', 'ẫ': 'a',
      'À': 'A', 'Á': 'A', 'Ạ': 'A', 'Ả': 'A', 'Ã': 'A',
      'Ă': 'A', 'Ằ': 'A', 'Ắ': 'A', 'Ặ': 'A', 'Ẳ': 'A', 'Ẵ': 'A',
      'Â': 'A', 'Ầ': 'A', 'Ấ': 'A', 'Ậ': 'A', 'Ẩ': 'A', 'Ẫ': 'A',
      // E variations
      'è': 'e', 'é': 'e', 'ẹ': 'e', 'ẻ': 'e', 'ẽ': 'e',
      'ê': 'e', 'ề': 'e', 'ế': 'e', 'ệ': 'e', 'ể': 'e', 'ễ': 'e',
      'È': 'E', 'É': 'E', 'Ẹ': 'E', 'Ẻ': 'E', 'Ẽ': 'E',
      'Ê': 'E', 'Ề': 'E', 'Ế': 'E', 'Ệ': 'E', 'Ể': 'E', 'Ễ': 'E',
      // I variations
      'ì': 'i', 'í': 'i', 'ị': 'i', 'ỉ': 'i', 'ĩ': 'i',
      'Ì': 'I', 'Í': 'I', 'Ị': 'I', 'Ỉ': 'I', 'Ĩ': 'I',
      // O variations
      'ò': 'o', 'ó': 'o', 'ọ': 'o', 'ỏ': 'o', 'õ': 'o',
      'ô': 'o', 'ồ': 'o', 'ố': 'o', 'ộ': 'o', 'ổ': 'o', 'ỗ': 'o',
      'ơ': 'o', 'ờ': 'o', 'ớ': 'o', 'ợ': 'o', 'ở': 'o', 'ỡ': 'o',
      'Ò': 'O', 'Ó': 'O', 'Ọ': 'O', 'Ỏ': 'O', 'Õ': 'O',
      'Ô': 'O', 'Ồ': 'O', 'Ố': 'O', 'Ộ': 'O', 'Ổ': 'O', 'Ỗ': 'O',
      'Ơ': 'O', 'Ờ': 'O', 'Ớ': 'O', 'Ợ': 'O', 'Ở': 'O', 'Ỡ': 'O',
      // U variations
      'ù': 'u', 'ú': 'u', 'ụ': 'u', 'ủ': 'u', 'ũ': 'u',
      'ư': 'u', 'ừ': 'u', 'ứ': 'u', 'ự': 'u', 'ử': 'u', 'ữ': 'u',
      'Ù': 'U', 'Ú': 'U', 'Ụ': 'U', 'Ủ': 'U', 'Ũ': 'U',
      'Ư': 'U', 'Ừ': 'U', 'Ứ': 'U', 'Ự': 'U', 'Ử': 'U', 'Ữ': 'U',
      // Y variations
      'ỳ': 'y', 'ý': 'y', 'ỵ': 'y', 'ỷ': 'y', 'ỹ': 'y',
      'Ỳ': 'Y', 'Ý': 'Y', 'Ỵ': 'Y', 'Ỷ': 'Y', 'Ỹ': 'Y',
      // D variations
      'đ': 'd', 'Đ': 'D',
    };
    
    // Replace Vietnamese characters
    for (final entry in accentMap.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    
    // Final cleanup
    result = result
        .replaceAll(RegExp(r'[^a-zA-Z\s]'), '') // Keep only letters and spaces
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();
    
    // Capitalize first letter of each word
    return result.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // ========== BACKWARD COMPATIBILITY ==========
  
  // Giữ method cũ để không break existing code
  static String? parseStudentId(String qrData) {
    final info = parseStudentInfo(qrData);
    return info?.studentCode;
  }

  // ========== VALIDATION - SIMPLIFIED ==========

  static bool isValidStudentCode(String code) {
    if (code.length < 3 || code.length > 8) return false;
    
    // Pattern: 2 letters + 1-6 numbers
    final pattern = RegExp(r'^[A-ZĐ]{2}\d{1,6}$');
    if (!pattern.hasMatch(code)) return false;
    
    // Not all zeros
    final numbers = code.substring(2);
    return !RegExp(r'^0+$').hasMatch(numbers);
  }

  static bool isValidQRFormat(String qrData) {
    return parseStudentId(qrData) != null;
  }

  // ========== CAMERA CONTROLLER WITH ERROR HANDLING ==========

  static MobileScannerController createOptimalController() {
    return MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      formats: [BarcodeFormat.qrCode],
      returnImage: false,
    );
  }

  // ✅ NEW: Safe camera initialization với delay và retry
  static Future<MobileScannerController?> createSafeController() async {
    try {
      // Delay để system ổn định
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Try back camera first với timeout
      var controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        formats: [BarcodeFormat.qrCode],
        returnImage: false,
      );
      
      try {
        await controller.start().timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('Camera start timeout'),
        );
        
        return controller;
        
      } on TimeoutException {
        await controller.dispose();
        throw Exception('Camera timeout');
        
      } catch (e) {
        await controller.dispose();
        
        // Delay trước khi thử front camera
        await Future.delayed(const Duration(milliseconds: 300));
        
        // Fallback to front camera
        controller = MobileScannerController(
          detectionSpeed: DetectionSpeed.normal,
          facing: CameraFacing.front,
          formats: [BarcodeFormat.qrCode],
          returnImage: false,
        );
        
        await controller.start().timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw TimeoutException('Front camera timeout'),
        );
        
        return controller;
      }
      
    } catch (e) {
      return null;
    }
  }

  // ✅ NEW: Check camera availability
  static Future<bool> isCameraAvailable() async {
    try {
      final controller = await createSafeController();
      if (controller != null) {
        await controller.stop();
        await controller.dispose();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ========== BARCODE PROCESSING ==========

  static QRStudentInfo? processBarcodeCapture(BarcodeCapture capture) {
    try {
      if (capture.barcodes.isEmpty) return null;
      
      for (final barcode in capture.barcodes) {
        // Try display value first
        final displayResult = _tryParseBarcode(barcode.displayValue);
        if (displayResult != null) return displayResult;
        
        // Fallback to raw value
        final rawResult = _tryParseBarcode(barcode.rawValue);
        if (rawResult != null) return rawResult;
      }
      
      return null;
      
    } catch (e) {
      return null;
    }
  }

  static QRStudentInfo? _tryParseBarcode(String? value) {
    if (value == null || value.isEmpty) return null;
    return parseStudentInfo(value);
  }

  // ========== FEEDBACK ==========

  static void successFeedback() {
    try {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silent fail
    }
  }

  static void errorFeedback() {
    try {
      HapticFeedback.mediumImpact();
    } catch (e) {
      // Silent fail  
    }
  }

  // ========== UTILITY ==========

  static String formatStudentIdDisplay(String studentId) {
    try {
      if (studentId.length >= 3) {
        final letters = studentId.substring(0, 2);
        final numbers = studentId.substring(2);
        return '$letters-$numbers';
      }
      return studentId;
    } catch (e) {
      return studentId;
    }
  }

  // ========== DEBUG ==========

  static void debugQRContent(String qrData) {
    // print('\n🔍 === QR DEBUG ===');
    // print('📄 Raw: "$qrData"');
    // print('📏 Length: ${qrData.length}');
    // print('🔢 Bytes: ${qrData.codeUnits}');
    // print('🎯 Parsed: ${parseStudentId(qrData)}');
    // print('✅ Valid: ${isValidQRFormat(qrData)}');
    // print('==================\n');
  }

}