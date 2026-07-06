import 'package:flutter/material.dart';

import '../../../../../core/constants/app_radius.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../onboarding_page_view.dart';

class DeliveryReadyIllustration extends StatefulWidget {
  const DeliveryReadyIllustration({super.key, required this.isActive});

  final bool isActive;

  @override
  State<DeliveryReadyIllustration> createState() =>
      _DeliveryReadyIllustrationState();
}

class _DeliveryReadyIllustrationState extends State<DeliveryReadyIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.14),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    if (widget.isActive) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant DeliveryReadyIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OnboardingSurfaceCard(
              width: 220,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.detailBackground,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      size: 42,
                      color: AppColors.burgundy,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.burgundy,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
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
                  Icon(
                    Icons.local_shipping_outlined,
                    size: 16,
                    color: AppColors.burgundy.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Gati për dorëzim',
                    style: AppTextStyles.caption.copyWith(color: AppColors.burgundy),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
