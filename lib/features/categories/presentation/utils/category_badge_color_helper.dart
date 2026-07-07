import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Parses category [badgeColor] hex values and picks readable label colors.
abstract final class CategoryBadgeColorHelper {
  static Color parseHex(
    String? hex, {
    Color? fallback,
  }) {
    final normalized = hex?.trim();
    if (normalized == null || normalized.isEmpty) {
      return fallback ?? AppColors.burgundy;
    }

    var value = normalized;
    if (value.startsWith('#')) {
      value = value.substring(1);
    }

    if (value.length == 6) {
      value = 'FF$value';
    }

    if (value.length != 8) {
      return fallback ?? AppColors.burgundy;
    }

    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) {
      return fallback ?? AppColors.burgundy;
    }

    return Color(parsed);
  }

  /// Resolves chip/badge background: own color → parent → [fallback].
  static Color resolveBackground({
    String? badgeColor,
    String? parentBadgeColor,
    Color? fallback,
  }) {
    if (badgeColor != null && badgeColor.trim().isNotEmpty) {
      return parseHex(badgeColor, fallback: fallback);
    }
    if (parentBadgeColor != null && parentBadgeColor.trim().isNotEmpty) {
      return parseHex(parentBadgeColor, fallback: fallback);
    }
    return fallback ?? AppColors.burgundy;
  }

  /// Picks dark or light text for contrast on [background].
  static Color textColor(Color background) {
    return background.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
