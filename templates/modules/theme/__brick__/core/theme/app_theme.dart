import 'package:flutter/material.dart';
import '../../shared/design_system/tokens/brand_colors.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.background,
        onSurface: AppColors.onBackground,
      ),
      extensions: const [
        BrandColors(
          dark: Color(0xFF26215C),
          mid: Color(0xFF534AB7),
          subtle: Color(0xFFEEEDFE),
          accent: Color(0xFFAFA9EC),
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.onPrimaryDark,
        surface: AppColors.backgroundDark,
        onSurface: AppColors.onBackgroundDark,
      ),
      extensions: const [
        BrandColors(
          dark: Color(0xFFEEEDFE),
          mid: Color(0xFFAFA9EC),
          subtle: Color(0xFF26215C),
          accent: Color(0xFF534AB7),
        ),
      ],
    );
  }
}
