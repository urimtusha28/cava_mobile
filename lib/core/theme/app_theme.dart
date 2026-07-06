import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_text_styles.dart';
import '../constants/app_radius.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final textTheme = TextTheme(
      headlineMedium: AppTextStyles.h1,
      titleLarge: AppTextStyles.h2,
      titleMedium: AppTextStyles.h3,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.button,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppFonts.family,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.burgundy,
        secondary: AppColors.gold,
        surface: AppColors.surface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.h3,
        toolbarTextStyle: AppTextStyles.body,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border),
      textTheme: textTheme,
      primaryTextTheme: textTheme,
    );
  }
}
