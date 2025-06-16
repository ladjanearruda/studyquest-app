import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Tema principal do app baseado na paleta amazônica
final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.forestGreen,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    background: AppColors.background,
    error: AppColors.error,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: AppColors.background,
  textTheme: const TextTheme(
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(fontSize: 16),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.forestGreen,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  useMaterial3: true,
);
