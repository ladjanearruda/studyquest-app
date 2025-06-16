import 'package:flutter/material.dart';

/// Paleta de cores inspirada na Amazônia:
/// Verdes das matas, azuis dos rios e céus, marrons da terra.
class AppColors {
  static const Color forestGreen = Color(0xFF2E7D32);
  static const Color riverBlue = Color(0xFF0288D1);
  static const Color skyBlue = Color(0xFF81D4FA);
  static const Color earthBrown = Color(0xFF6D4C41);
  static const Color leafGreen = Color(0xFF66BB6A);
  static const Color lightBeige = Color(0xFFF3E5AB);

  // Cores principais do app
  static const Color primary = forestGreen;
  static const Color secondary = riverBlue;
  static const Color background = lightBeige;
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFE53935);
  static const Color success = leafGreen;
  static const Color warning = Color(0xFFFF9800);

  // Cores de texto
  static const Color textPrimary = Color(0xFF2E2E2E);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Colors.white;
}
