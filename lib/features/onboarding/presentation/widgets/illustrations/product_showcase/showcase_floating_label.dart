import 'package:flutter/material.dart';

import '../../../utils/animation_utils.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

class ShowcaseFloatingLabel extends StatelessWidget {
  const ShowcaseFloatingLabel({
    super.key,
    required this.label,
    required this.opacity,
    required this.scale,
    required this.dotProgress,
  });

  final String label;
  final double opacity;
  final double scale;
  final double dotProgress;

  @override
  Widget build(BuildContext context) {
    final safeOpacity = safeUnit(opacity);
    final safeScale = scale.clamp(0.9, 1.1);
    final safeDots = safeUnit(dotProgress);

    return Opacity(
      opacity: safeOpacity,
      child: Transform.scale(
        scale: safeScale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size(28, 14),
              painter: _DottedArcPainter(progress: safeDots),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                  color: AppColors.burgundy.withValues(alpha: 0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.burgundy.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.burgundy,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DottedArcPainter extends CustomPainter {
  const _DottedArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final clamped = safeUnit(progress);
    if (clamped <= 0) return;

    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.4 * clamped)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const dash = 2.5;
    const gap = 3.0;
    final path = Path()
      ..moveTo(size.width * 0.15, size.height)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.1,
        size.width * 0.85,
        size.height,
      );

    for (final metric in path.computeMetrics()) {
      final maxLength = metric.length * clamped;
      var distance = 0.0;
      while (distance < maxLength) {
        final end = (distance + dash).clamp(distance, maxLength);
        if (end > distance) {
          canvas.drawPath(metric.extractPath(distance, end), paint);
        }
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DottedArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
