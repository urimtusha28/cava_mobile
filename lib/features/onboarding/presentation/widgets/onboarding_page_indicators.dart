import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OnboardingPageIndicators extends StatelessWidget {
  const OnboardingPageIndicators({
    super.key,
    required this.count,
    required this.index,
    required this.progress,
  });

  final int count;
  final int index;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == index;
        final isPast = i < index;
        final width = isActive ? 24.0 + (progress * 8) : (isPast ? 16.0 : 8.0);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: width,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: isActive
                ? AppColors.burgundy
                : isPast
                    ? AppColors.burgundy.withValues(alpha: 0.35)
                    : AppColors.border,
          ),
        );
      }),
    );
  }
}
