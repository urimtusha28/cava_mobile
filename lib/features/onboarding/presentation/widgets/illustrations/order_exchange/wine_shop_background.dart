import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class WineShopBackground extends StatelessWidget {
  const WineShopBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8F3EC),
                    Color(0xFFF0E8DC),
                    Color(0xFFEAE0D2),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.burgundy.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              bottom: -20,
              left: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: const _WineShelfLayer(),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WineShelfLayer extends StatelessWidget {
  const _WineShelfLayer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 80),
      child: Column(
        children: [
          _shelfRow(const [0.55, 0.7, 0.45, 0.6, 0.5]),
          const SizedBox(height: 18),
          _shelfRow(const [0.5, 0.65, 0.58, 0.48]),
        ],
      ),
    );
  }

  Widget _shelfRow(List<double> heights) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final h in heights) ...[
                  Expanded(child: _Bottle(heightFactor: h)),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Container(
            height: 3,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppColors.burgundy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bottle extends StatelessWidget {
  const _Bottle({required this.heightFactor});

  final double heightFactor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: heightFactor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.burgundyDark.withValues(alpha: 0.35),
                AppColors.burgundy.withValues(alpha: 0.25),
                AppColors.burgundyDark.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
