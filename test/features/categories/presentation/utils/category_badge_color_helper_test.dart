import 'package:cava_ecommerce/core/theme/app_colors.dart';
import 'package:cava_ecommerce/features/categories/presentation/utils/category_badge_color_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryBadgeColorHelper.parseHex', () {
    test('parses #RRGGBB hex', () {
      final color = CategoryBadgeColorHelper.parseHex('#7A1F32');
      expect(color, const Color(0xFF7A1F32));
    });

    test('parses RRGGBB without hash', () {
      final color = CategoryBadgeColorHelper.parseHex('7A1F32');
      expect(color, const Color(0xFF7A1F32));
    });

    test('returns fallback for invalid hex', () {
      final color = CategoryBadgeColorHelper.parseHex(
        'not-a-color',
        fallback: Colors.blue,
      );
      expect(color, Colors.blue);
    });

    test('returns burgundy when hex is null and no fallback', () {
      final color = CategoryBadgeColorHelper.parseHex(null);
      expect(color, AppColors.burgundy);
    });
  });

  group('CategoryBadgeColorHelper.textColor', () {
    test('uses white text on dark background', () {
      expect(
        CategoryBadgeColorHelper.textColor(const Color(0xFF7A1F32)),
        Colors.white,
      );
    });

    test('uses black text on light background', () {
      expect(
        CategoryBadgeColorHelper.textColor(const Color(0xFFF5F5F5)),
        Colors.black,
      );
    });
  });

  group('CategoryBadgeColorHelper.resolveBackground', () {
    test('prefers subcategory badgeColor over parent', () {
      final color = CategoryBadgeColorHelper.resolveBackground(
        badgeColor: '#AA0000',
        parentBadgeColor: '#7A1F32',
      );
      expect(color, const Color(0xFFAA0000));
    });

    test('inherits parent badgeColor when subcategory has none', () {
      final color = CategoryBadgeColorHelper.resolveBackground(
        parentBadgeColor: '#7A1F32',
      );
      expect(color, const Color(0xFF7A1F32));
    });

    test('uses fallback when badge and parent are missing', () {
      final color = CategoryBadgeColorHelper.resolveBackground(
        fallback: Colors.green,
      );
      expect(color, Colors.green);
    });
  });
}
