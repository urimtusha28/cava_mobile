import 'package:flutter/material.dart';

import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/onboarding_page.dart';
import 'illustrations/delivery_ready_illustration.dart';
import 'illustrations/order_received_illustration.dart';
import 'illustrations/order_review_illustration.dart';
import 'illustrations/product_showcase_illustration.dart';

class OnboardingIllustrationArea extends StatelessWidget {
  const OnboardingIllustrationArea({
    super.key,
    required this.page,
    required this.isActive,
    required this.pageOffset,
  });

  final OnboardingPage page;
  final bool isActive;
  final double pageOffset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 340,
      width: double.infinity,
      child: switch (page.illustration) {
        OnboardingIllustrationType.orderReceived => OrderReceivedIllustration(
            isActive: isActive,
            pageOffset: pageOffset,
          ),
        OnboardingIllustrationType.productShowcase => ProductShowcaseIllustration(
            isActive: isActive,
          ),
        OnboardingIllustrationType.orderReview => OrderReviewIllustration(
            isActive: isActive,
          ),
        OnboardingIllustrationType.deliveryReady => DeliveryReadyIllustration(
            isActive: isActive,
          ),
      },
    );
  }
}

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({
    super.key,
    required this.page,
    required this.isActive,
    required this.pageOffset,
  });

  final OnboardingPage page;
  final bool isActive;
  final double pageOffset;

  @override
  Widget build(BuildContext context) {
    final textOpacity = (1 - pageOffset.abs()).clamp(0.0, 1.0);
    final textSlide = pageOffset * 20;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          OnboardingIllustrationArea(
            page: page,
            isActive: isActive,
            pageOffset: pageOffset,
          ),
          const SizedBox(height: AppSpacing.xxxl),
          Opacity(
            opacity: textOpacity,
            child: Transform.translate(
              offset: Offset(textSlide, 0),
              child: Column(
                children: [
                  Text(
                    page.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 26,
                      letterSpacing: -0.4,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    page.subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  if (page.features != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    _OnboardingFeatureList(features: page.features!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingFeatureList extends StatelessWidget {
  const _OnboardingFeatureList({required this.features});

  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final feature in features)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.burgundy,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  feature,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class OnboardingSurfaceCard extends StatelessWidget {
  const OnboardingSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsets padding;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.burgundy.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}
