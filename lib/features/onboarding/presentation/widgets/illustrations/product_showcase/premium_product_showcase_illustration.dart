import 'package:flutter/material.dart';

import '../../../utils/animation_utils.dart';
import '../../../../../../core/theme/app_colors.dart';
import 'product_podium.dart';
import 'showcase_floating_label.dart';
import 'showcase_product_art.dart';

class PremiumProductShowcaseIllustration extends StatefulWidget {
  const PremiumProductShowcaseIllustration({
    super.key,
    required this.isActive,
  });

  final bool isActive;

  @override
  State<PremiumProductShowcaseIllustration> createState() =>
      _PremiumProductShowcaseIllustrationState();
}

class _PremiumProductShowcaseIllustrationState
    extends State<PremiumProductShowcaseIllustration>
    with SingleTickerProviderStateMixin {
  static const _items = [
    _ShowcaseSlot(
      type: ShowcaseProductType.spirit,
      label: 'Spirits',
      xFactor: 0.13,
      podiumW: 58,
      podiumH: 36,
      labelTop: 8,
      productStart: 0.08,
      productEnd: 0.36,
      labelStart: 0.38,
      labelEnd: 0.60,
    ),
    _ShowcaseSlot(
      type: ShowcaseProductType.wine,
      label: 'Verë',
      xFactor: 0.36,
      podiumW: 72,
      podiumH: 44,
      labelTop: 0,
      isHero: true,
      productStart: 0.20,
      productEnd: 0.48,
      labelStart: 0.50,
      labelEnd: 0.72,
    ),
    _ShowcaseSlot(
      type: ShowcaseProductType.tobacco,
      label: 'Duhan',
      xFactor: 0.60,
      podiumW: 62,
      podiumH: 34,
      labelTop: 12,
      productStart: 0.32,
      productEnd: 0.60,
      labelStart: 0.62,
      labelEnd: 0.84,
    ),
    _ShowcaseSlot(
      type: ShowcaseProductType.accessory,
      label: 'Aksesorë',
      xFactor: 0.84,
      podiumW: 50,
      podiumH: 30,
      labelTop: 16,
      productStart: 0.44,
      productEnd: 0.72,
      labelStart: 0.74,
      labelEnd: 0.96,
    ),
  ];

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.isActive) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant PremiumProductShowcaseIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0);
    } else if (!widget.isActive) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _productProgress(_ShowcaseSlot slot) {
    return safeCurve(
      Curves.easeOutCubic,
      safeUnit(_controller.value),
      slot.productStart,
      slot.productEnd,
    );
  }

  double _labelProgress(_ShowcaseSlot slot) {
    return safeCurve(
      Curves.easeOutCubic,
      safeUnit(_controller.value),
      slot.labelStart,
      slot.labelEnd,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;
          final scale = (w / 340).clamp(0.85, 1.12);

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _ShowcaseBackground(),
                    for (var i = 0; i < _items.length; i++)
                      _buildSlot(_items[i], w, h, scale),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSlot(_ShowcaseSlot slot, double w, double h, double scale) {
    final progress = _productProgress(slot);
    final labelProgress = _labelProgress(slot);
    final heroScale = slot.isHero ? 0.96 + 0.04 * progress : 1.0;
    final slideY = (1 - progress) * 18 * scale;
    final left = w * slot.xFactor - (slot.podiumW * scale) / 2;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: left,
          top: h * 0.52 - slideY,
          child: Opacity(
            opacity: safeUnit(progress),
            child: Transform.scale(
              scale: heroScale,
              child: _ProductGlow(type: slot.type, scale: scale),
            ),
          ),
        ),
        Positioned(
          left: left,
          top: h * 0.52 - slideY,
          child: Opacity(
            opacity: safeUnit(progress),
            child: Transform.scale(
              scale: heroScale,
              child: ProductPodium(
                width: slot.podiumW * scale,
                height: slot.podiumH * scale,
                child: ShowcaseProductArt(
                  type: slot.type,
                  scale: scale * (slot.isHero ? 1.08 : 1),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: left + (slot.podiumW * scale * 0.12),
          top: h * 0.52 - slideY - 42 * scale - slot.labelTop,
          child: ShowcaseFloatingLabel(
            label: slot.label,
            opacity: safeUnit(labelProgress),
            scale: 0.94 + labelProgress * 0.06,
            dotProgress: safeUnit(labelProgress),
          ),
        ),
      ],
    );
  }
}

class _ShowcaseSlot {
  const _ShowcaseSlot({
    required this.type,
    required this.label,
    required this.xFactor,
    required this.podiumW,
    required this.podiumH,
    required this.labelTop,
    required this.productStart,
    required this.productEnd,
    required this.labelStart,
    required this.labelEnd,
    this.isHero = false,
  });

  final ShowcaseProductType type;
  final String label;
  final double xFactor;
  final double podiumW;
  final double podiumH;
  final double labelTop;
  final double productStart;
  final double productEnd;
  final double labelStart;
  final double labelEnd;
  final bool isHero;
}

class _ShowcaseBackground extends StatelessWidget {
  const _ShowcaseBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFAF6F0),
                Color(0xFFF3EBE1),
                Color(0xFFEDE4D8),
              ],
            ),
          ),
        ),
        Positioned(
          top: -30,
          left: -20,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withValues(alpha: 0.05),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: -30,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.burgundy.withValues(alpha: 0.04),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductGlow extends StatelessWidget {
  const _ProductGlow({required this.type, required this.scale});

  final ShowcaseProductType type;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = switch (type) {
      ShowcaseProductType.wine => 90.0,
      ShowcaseProductType.spirit => 72.0,
      ShowcaseProductType.tobacco => 68.0,
      ShowcaseProductType.accessory => 52.0,
    };

    return Container(
      width: size * scale,
      height: size * scale * 0.7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.gold.withValues(alpha: 0.12),
            AppColors.gold.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
