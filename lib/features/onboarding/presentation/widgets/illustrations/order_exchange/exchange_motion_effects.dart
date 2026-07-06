import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../utils/animation_utils.dart';

class ExchangeMotionEffects extends StatelessWidget {
  const ExchangeMotionEffects({
    super.key,
    required this.glowOpacity,
    required this.checkOpacity,
    required this.bagCenter,
    required this.scale,
  });

  final double glowOpacity;
  final double checkOpacity;
  final Offset bagCenter;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final glow = safeUnit(glowOpacity);
    final check = safeUnit(checkOpacity);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (glow > 0)
          Positioned(
            left: bagCenter.dx - 40 * scale,
            top: bagCenter.dy - 40 * scale,
            child: Opacity(
              opacity: glow,
              child: Container(
                width: 80 * scale,
                height: 80 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.gold.withValues(alpha: 0.28),
                      AppColors.gold.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (check > 0)
          Positioned(
            left: bagCenter.dx - 10 * scale,
            top: bagCenter.dy - 52 * scale,
            child: Opacity(
              opacity: check,
              child: Container(
                width: 22 * scale,
                height: 22 * scale,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.burgundy.withValues(alpha: 0.15),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.burgundy.withValues(alpha: 0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 14 * scale,
                  color: AppColors.burgundy,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
