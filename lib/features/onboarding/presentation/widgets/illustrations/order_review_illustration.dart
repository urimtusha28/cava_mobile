import 'package:flutter/material.dart';

import '../../../../../core/constants/app_radius.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../onboarding_page_view.dart';

class OrderReviewIllustration extends StatefulWidget {
  const OrderReviewIllustration({super.key, required this.isActive});

  final bool isActive;

  @override
  State<OrderReviewIllustration> createState() => _OrderReviewIllustrationState();
}

class _OrderReviewIllustrationState extends State<OrderReviewIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    if (widget.isActive) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant OrderReviewIllustration oldWidget) {
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
      child: ScaleTransition(
        scale: _scale,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: OnboardingSurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.detailTag,
                      child: Text(
                        'UT',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.burgundy,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Urim Tusha', style: AppTextStyles.h3.copyWith(fontSize: 15)),
                          Text('Klient', style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Text('Porosi #1042', style: AppTextStyles.caption),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                const _OrderLine(
                  name: 'Stone Castle Merlot',
                  qty: 'x1',
                  price: '18,90 €',
                ),
                const SizedBox(height: AppSpacing.sm),
                const _OrderLine(
                  name: 'Glenfiddich 12 YO',
                  qty: 'x1',
                  price: '15,90 €',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                Row(
                  children: [
                    Text('Totali', style: AppTextStyles.body),
                    const Spacer(),
                    Text(
                      '34,80 €',
                      style: AppTextStyles.price.copyWith(fontSize: 20),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.burgundy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    'Gati për konfirmim',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(color: AppColors.burgundy),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderLine extends StatelessWidget {
  const _OrderLine({
    required this.name,
    required this.qty,
    required this.price,
  });

  final String name;
  final String qty;
  final String price;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(name, style: AppTextStyles.bodySmall)),
        Text(qty, style: AppTextStyles.caption),
        const SizedBox(width: AppSpacing.md),
        Text(price, style: AppTextStyles.bodySmall),
      ],
    );
  }
}
