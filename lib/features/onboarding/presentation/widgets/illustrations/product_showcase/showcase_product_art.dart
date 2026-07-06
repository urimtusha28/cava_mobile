import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

enum ShowcaseProductType { wine, spirit, tobacco, accessory }

class ShowcaseProductArt extends StatelessWidget {
  const ShowcaseProductArt({
    super.key,
    required this.type,
    required this.scale,
  });

  final ShowcaseProductType type;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: _sizeFor(type, scale),
      painter: _ShowcaseProductPainter(type: type),
    );
  }

  Size _sizeFor(ShowcaseProductType type, double scale) {
    return switch (type) {
      ShowcaseProductType.wine => Size(34 * scale, 72 * scale),
      ShowcaseProductType.spirit => Size(28 * scale, 64 * scale),
      ShowcaseProductType.tobacco => Size(38 * scale, 28 * scale),
      ShowcaseProductType.accessory => Size(18 * scale, 36 * scale),
    };
  }
}

class _ShowcaseProductPainter extends CustomPainter {
  const _ShowcaseProductPainter({required this.type});

  final ShowcaseProductType type;

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case ShowcaseProductType.wine:
        _paintWine(canvas, size);
      case ShowcaseProductType.spirit:
        _paintSpirit(canvas, size);
      case ShowcaseProductType.tobacco:
        _paintTobacco(canvas, size);
      case ShowcaseProductType.accessory:
        _paintAccessory(canvas, size);
    }
  }

  void _paintWine(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.22, size.height * 0.18, size.width * 0.56, size.height * 0.72),
      Radius.circular(size.width * 0.12),
    );
    final gradient = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF8B2D3C), AppColors.burgundyDark, Color(0xFF5A1824)],
      ).createShader(body.outerRect);
    canvas.drawRRect(body, gradient);

    final neck = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.12),
        width: size.width * 0.22,
        height: size.height * 0.12,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(
      neck,
      Paint()..color = AppColors.burgundyDark,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.05),
          width: size.width * 0.28,
          height: size.height * 0.05,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.gold.withValues(alpha: 0.85),
    );
  }

  void _paintSpirit(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.12, size.width * 0.64, size.height * 0.78),
      Radius.circular(size.width * 0.08),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4A96A), Color(0xFFB8843F), Color(0xFF8B6428)],
        ).createShader(body.outerRect),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.28, size.height * 0.42, size.width * 0.44, size.height * 0.16),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.gold.withValues(alpha: 0.55),
    );
  }

  void _paintTobacco(Canvas canvas, Size size) {
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.2, size.width, size.height * 0.65),
      Radius.circular(size.width * 0.08),
    );
    canvas.drawRRect(
      box,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF6B4A32), Color(0xFF4A3222)],
        ).createShader(box.outerRect),
    );

    canvas.drawLine(
      Offset(size.width * 0.12, size.height * 0.45),
      Offset(size.width * 0.88, size.height * 0.45),
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.5)
        ..strokeWidth = 1,
    );
  }

  void _paintAccessory(Canvas canvas, Size size) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.1, size.width * 0.7, size.height * 0.8),
      Radius.circular(size.width * 0.2),
    );
    canvas.drawRRect(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8D9B5), AppColors.gold, Color(0xFFB8943F)],
        ).createShader(body.outerRect),
    );

    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.72),
      size.width * 0.12,
      Paint()..color = AppColors.burgundy.withValues(alpha: 0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _ShowcaseProductPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}
