import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

abstract final class AppTextStyles {
  static const FontWeight _weight = FontWeight.w400;

  static TextStyle get _base => const TextStyle(
        fontFamily: AppFonts.family,
        fontWeight: _weight,
      );

  static TextStyle get display => _base.copyWith(
        fontSize: 28,
        color: Colors.white,
        height: 1.2,
        letterSpacing: -0.5,
      );

  static TextStyle get displaySub => _base.copyWith(
        fontSize: 14,
        color: Colors.white,
        letterSpacing: 0.3,
      );

  static TextStyle get h1 => _base.copyWith(
        fontSize: 24,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get h2 => _base.copyWith(
        fontSize: 20,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => _base.copyWith(
        fontSize: 17,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => _base.copyWith(
        fontSize: 15,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => _base.copyWith(
        fontSize: 13,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  static TextStyle get caption => _base.copyWith(
        fontSize: 12,
        color: AppColors.textSecondary,
      );

  static TextStyle get brand => _base.copyWith(
        fontSize: 11,
        color: AppColors.gold,
        letterSpacing: 1.2,
      );

  static TextStyle get price => _base.copyWith(
        fontSize: 18,
        color: AppColors.textPrimary,
      );

  static TextStyle get priceLarge => _base.copyWith(
        fontSize: 22,
        color: AppColors.textPrimary,
      );

  static TextStyle get button => _base.copyWith(
        fontSize: 15,
        color: Colors.white,
      );

  static TextStyle get navLabel => _base.copyWith(
        fontSize: 10,
      );
}
