import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

class PremiumWineGiftBag extends StatelessWidget {
  const PremiumWineGiftBag({
    super.key,
    required this.scale,
    required this.handleSway,
  });

  final double scale;
  final double handleSway;

  @override
  Widget build(BuildContext context) {
    final w = 52.0 * scale;
    final h = 78.0 * scale;

    return SizedBox(
      width: w + 12,
      height: h + 20,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Transform.rotate(
            angle: handleSway,
            origin: Offset(w / 2, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _RopeHandle(scale: scale),
                _RopeHandle(scale: scale),
              ],
            ),
          ),
          Positioned(
            top: 10 * scale,
            child: CustomPaint(
              size: Size(w, h),
              painter: _WineBagPainter(),
              child: SizedBox(
                width: w,
                height: h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomPaint(
                      size: Size(18 * scale, 36 * scale),
                      painter: const _BottleOutlinePainter(),
                    ),
                    SizedBox(height: 6 * scale),
                    Text(
                      'CAVA',
                      style: AppTextStyles.brand.copyWith(
                        color: AppColors.gold,
                        fontSize: 8 * scale,
                        letterSpacing: 1.6,
                      ),
                    ),
                    Text(
                      'Premium',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.gold.withValues(alpha: 0.85),
                        fontSize: 6 * scale,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RopeHandle extends StatelessWidget {
  const _RopeHandle({required this.scale});

  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3 * scale,
      height: 14 * scale,
      decoration: BoxDecoration(
        color: const Color(0xFFC9A96E),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _WineBagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.14),
    );

    final gradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF7A2433),
          AppColors.burgundyDark,
          AppColors.burgundy,
        ],
      ).createShader(rect.outerRect);

    final shadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawRRect(
      rect.shift(const Offset(0, 2)),
      shadow,
    );
    canvas.drawRRect(rect, gradient);

    final texture = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 0.6;
    for (var i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(4, y), Offset(size.width - 4, y), texture);
    }

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.gold.withValues(alpha: 0.25);
    canvas.drawRRect(rect, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BottleOutlinePainter extends CustomPainter {
  const _BottleOutlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AppColors.gold.withValues(alpha: 0.75);

    final neck = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.14),
        width: size.width * 0.28,
        height: size.height * 0.12,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(neck, paint);

    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.55),
        width: size.width * 0.62,
        height: size.height * 0.62,
      ),
      Radius.circular(size.width * 0.12),
    );
    canvas.drawRRect(body, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
