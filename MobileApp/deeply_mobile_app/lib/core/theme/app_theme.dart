import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color bgDark = Color(0xFF0D0B1E);
  static const Color bgCard = Color(0xFF1A1730);
  static const Color bgInput = Color(0xFF1E1B2E);

  // Primary
  static const Color primary = Color(0xFFD63AF5);
  static const Color primaryLight = Color(0xFFE87EFF);

  // Gradient colors
  static const Color gradientPurple = Color(0xFF6B35B8);
  static const Color gradientPink = Color(0xFFD63AF5);
  static const Color gradientBlue = Color(0xFF2D1B6B);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAA9EC4);
  static const Color textHint = Color(0xFF6B6080);

  // Accent
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1060),
      Color(0xFF3D1580),
      Color(0xFF8B2FC9),
      Color(0xFFB44FE8),
      Color(0xFF0D0B1E),
    ],
    stops: [0.0, 0.25, 0.5, 0.65, 1.0],
  );

  static const LinearGradient authGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1060),
      Color(0xFF5C2090),
      Color(0xFF9B35C8),
      Color(0xFF0D0B1E),
    ],
    stops: [0.0, 0.35, 0.6, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFB44FE8), Color(0xFFD63AF5)],
  );
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      fontFamily: 'SF Pro Display',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.bgCard,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgInput,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: AppColors.textHint),
      ),
    );
  }
}
