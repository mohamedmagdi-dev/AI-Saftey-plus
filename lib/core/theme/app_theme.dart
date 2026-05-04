import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette - Dark/Gold/Cyan
  static const Color primaryDark = Color(0xFF020712);
  static const Color secondaryDark = Color(0xFF101727);
  static const Color accentCyan = Color(0xFF00D2F2);
  static const Color accentCyanDark = Color(0xFF0092B8);
  static const Color accentGold = Color(0xFFF0B000);
  static const Color accentGoldDark = Color(0xFFD08700);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF99A1AE);
  static const Color textTertiary = Color(0xFF697282);
  static const Color borderColor = Color(0xFFD0D5DB);
  
  // Status Colors
  static const Color statusOnline = Color(0xFF00C950);
  static const Color statusOffline = Color(0xFF99A1AE);
  static const Color statusWarning = Color(0xFFF0B000);
  static const Color statusError = Color(0xFFE53E3E);
  
  // Background Gradient
  static const List<Color> backgroundGradient = [
    primaryDark,
    secondaryDark,
    Colors.black,
  ];
  
  // Glassmorphism
  static const double glassBlur = 12.0;
  static const double glassOpacity = 0.05;
  static const double glassBorderOpacity = 0.10;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentCyan,
        brightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accentCyan,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: primaryDark,
    );
  }
}
