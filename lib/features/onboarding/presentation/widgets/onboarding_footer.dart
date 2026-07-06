import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import 'onboarding_page_indicators.dart';

class OnboardingFooter extends StatelessWidget {
  const OnboardingFooter({
    super.key,
    required this.pageCount,
    required this.currentIndex,
    required this.pageProgress,
    required this.isLastPage,
    required this.onNext,
  });

  final int pageCount;
  final int currentIndex;
  final double pageProgress;
  final bool isLastPage;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        0,
        AppSpacing.screen,
        AppSpacing.xl,
      ),
      child: Column(
        children: [
          OnboardingPageIndicators(
            count: pageCount,
            index: currentIndex,
            progress: pageProgress,
          ),
          const SizedBox(height: AppSpacing.xl),
          PrimaryButton(
            label: isLastPage ? 'Fillo' : 'Vazhdo',
            icon: isLastPage ? null : Icons.arrow_forward_rounded,
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class OnboardingSkipButton extends StatelessWidget {
  const OnboardingSkipButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        'Kalo',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
