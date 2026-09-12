import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        titleTextStyle: AppTextStyles.semiBold(fontSize: 18, color: AppColors.white),
      ),
      textTheme: TextTheme(
        bodySmall: AppTextStyles.regular(fontSize: 12),
        bodyMedium: AppTextStyles.regular(fontSize: 14),
        bodyLarge: AppTextStyles.regular(fontSize: 16),
        titleSmall: AppTextStyles.medium(fontSize: 14),
        titleMedium: AppTextStyles.semiBold(fontSize: 16),
        titleLarge: AppTextStyles.semiBold(fontSize: 20),
        headlineSmall: AppTextStyles.bold(fontSize: 22),
        headlineMedium: AppTextStyles.bold(fontSize: 26),
        labelLarge: AppTextStyles.medium(fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          textStyle: AppTextStyles.semiBold(fontSize: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: AppTextStyles.regular(color: AppColors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
      ),
    );
  }
}
