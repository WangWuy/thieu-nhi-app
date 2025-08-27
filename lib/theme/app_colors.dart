import 'package:flutter/material.dart';

class AppColors {
  // ==================== RELIGIOUS THEME COLORS ====================
  
  // Primary colors - Based on Login Screen
  static const Color primary = Color(0xFFDC143C);      // Crimson Red (từ login)
  static const Color primaryDark = Color(0xFFB22222);   // Dark Red
  static const Color primaryLight = Color(0xFFFF6B6B); // Light Red
  
  // Religious accent colors
  static const Color secondary = Color(0xFFFFD700);     // Gold (vàng thánh)
  static const Color accent = Color(0xFF4169E1);        // Royal Blue (xanh thánh)
  static const Color tertiary = Color(0xFF8B4513);      // Saddle Brown (nâu gỗ)

  // Status colors - Adjusted to match theme
  static const Color success = Color(0xFF2E8B57);       // Sea Green (xanh lá nhẹ nhàng)
  static const Color warning = Color(0xFFFF8C00);       // Dark Orange
  static const Color error = Color(0xFFDC143C);         // Same as primary
  static const Color info = Color(0xFF4169E1);          // Same as accent

  // Neutral colors - Warmer tones
  static const Color grey50 = Color(0xFFFFFBF0);        // Warm white (từ login)
  static const Color grey100 = Color(0xFFF5F5DC);       // Beige
  static const Color grey200 = Color(0xFFE6E6FA);       // Lavender
  static const Color grey300 = Color(0xFFD3D3D3);       // Light Gray
  static const Color grey400 = Color(0xFFA9A9A9);       // Dark Gray
  static const Color grey500 = Color(0xFF808080);       // Gray
  static const Color grey600 = Color(0xFF696969);       // Dim Gray
  static const Color grey700 = Color(0xFF2F4F4F);       // Dark Slate Gray
  static const Color grey800 = Color(0xFF1C1C1C);       // Almost Black
  static const Color grey900 = Color(0xFF000000);       // Black

  // Department colors - Religious inspired
  static const Color chienColor = Color(0xFFDC143C);    // Crimson (Chiên sĩ)
  static const Color auColor = Color(0xFF4169E1);       // Royal Blue (Ấu nhi)
  static const Color thieuColor = Color(0xFF2E8B57);    // Sea Green (Thiếu nhi)
  static const Color nghiaColor = Color(0xFF9370DB);    // Medium Purple (Nghĩa sĩ)

  // ==================== GRADIENTS ====================
  
  // Primary gradient - Religious red
  static const List<Color> primaryGradient = [
    Color(0xFFDC143C), // Crimson
    Color(0xFFB22222), // Fire Brick
  ];
  
  // Login background gradient - Enhanced
  static const List<Color> loginBackgroundGradient = [
    Color(0xFFF8F9FA), // Light cream
    Color(0xFFFFFBF0), // Warm white
    Color(0xFFF5F5DC), // Beige
    Color(0xFFE6F3FF), // Very light blue
  ];

  // Success gradient - Green
  static const List<Color> successGradient = [
    Color(0xFF2E8B57), // Sea Green
    Color(0xFF3CB371), // Medium Sea Green
  ];

  // Warning gradient - Orange
  static const List<Color> warningGradient = [
    Color(0xFFFF8C00), // Dark Orange
    Color(0xFFFFA500), // Orange
  ];

  // Error gradient - Red
  static const List<Color> errorGradient = [
    Color(0xFFDC143C), // Crimson
    Color(0xFFFF6B6B), // Light Red
  ];

  // Gold gradient - For special elements
  static const List<Color> goldGradient = [
    Color(0xFFFFD700), // Gold
    Color(0xFFFFA500), // Orange
  ];

  // Royal gradient - Blue
  static const List<Color> royalGradient = [
    Color(0xFF4169E1), // Royal Blue
    Color(0xFF6495ED), // Cornflower Blue
  ];

  // Department gradients
  static const List<Color> chienGradient = [
    Color(0xFFDC143C), // Crimson
    Color(0xFFFF6B6B), // Light Red
  ];

  static const List<Color> auGradient = [
    Color(0xFF4169E1), // Royal Blue
    Color(0xFF6495ED), // Cornflower Blue
  ];

  static const List<Color> thieuGradient = [
    Color(0xFF2E8B57), // Sea Green
    Color(0xFF3CB371), // Medium Sea Green
  ];

  static const List<Color> nghiaGradient = [
    Color(0xFF9370DB), // Medium Purple
    Color(0xFFBA55D3), // Medium Orchid
  ];

  // ==================== HELPER METHODS ====================
  
  /// Get department color by name
  static Color getDepartmentColor(String department) {
    switch (department.toLowerCase()) {
      case 'Chiên':
        return chienColor;
      case 'âu':
        return auColor;
      case 'thiếu':
        return thieuColor;
      case 'nghĩa':
        return nghiaColor;
      default:
        return primary;
    }
  }

  /// Get department gradient by name
  static List<Color> getDepartmentGradient(String department) {
    switch (department.toLowerCase()) {
      case 'Chiên':
        return chienGradient;
      case 'âu':
        return auGradient;
      case 'thiếu':
        return thieuGradient;
      case 'nghĩa':
        return nghiaGradient;
      default:
        return primaryGradient;
    }
  }

  /// Get role color
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return error; // Red for admin
      case 'department':
        return primary; // Crimson for department
      case 'teacher':
        return success; // Green for teacher
      default:
        return primary;
    }
  }

  /// Get role gradient
  static List<Color> getRoleGradient(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return errorGradient;
      case 'department':
        return primaryGradient;
      case 'teacher':
        return successGradient;
      default:
        return primaryGradient;
    }
  }

  // ==================== SEMANTIC COLORS ====================
  
  // Background colors
  static const Color scaffoldBackground = Color(0xFFFFFBF0); // Warm white
  static const Color cardBackground = Colors.white;
  static const Color surfaceColor = Color(0xFFF8F9FA);       // Light cream

  // Text colors
  static const Color primaryText = Color(0xFF1C1C1C);        // Almost black
  static const Color secondaryText = Color(0xFF696969);      // Dim gray
  static const Color hintText = Color(0xFFA9A9A9);          // Dark gray

  // Border colors
  static const Color borderPrimary = Color(0xFFD3D3D3);     // Light gray
  static const Color borderSecondary = Color(0xFFE6E6FA);   // Lavender
  static const Color borderAccent = Color(0xFFDC143C);      // Primary red

  // Shadow colors
  static const Color shadowLight = Color(0x1A000000);       // 10% black
  static const Color shadowMedium = Color(0x33000000);      // 20% black
  static const Color shadowDark = Color(0x4D000000);        // 30% black
}