import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryGreen = Color(0xFF007A3D);
  static const Color darkGreen = Color(0xFF064333);
  static const Color lightGreen = Color(0xFFEAF7EF);
  static const Color mintGreen = Color(0xFFDFF5E7);
  static const Color softBlue = Color(0xFFEAF3FF);
  static const Color blueAccent = Color(0xFF0B4F93);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color textDark = Color(0xFF102A2A);
  static const Color textGrey = Color(0xFF667085);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color primary = primaryGreen;
  static const Color primaryDark = darkGreen;
  static const Color secondary = blueAccent;
  static const Color textPrimary = textDark;
  static const Color textSecondary = textGrey;
  static const Color border = borderLight;
  static const Color warning = warningOrange;
  static const Color danger = dangerRed;
  static const Color success = primaryGreen;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, darkGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: textDark.withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}
