import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../utils/animation_utils.dart';
import 'character_widgets.dart';
import 'exchange_motion_effects.dart';
import 'handoff_timeline.dart';
import 'premium_wine_gift_bag.dart';
import 'wine_shop_background.dart';

/// Premium looping handoff scene for onboarding screen 1.
class AnimatedOrderExchangeIllustration extends StatefulWidget {
  const AnimatedOrderExchangeIllustration({
    super.key,
    required this.isActive,
  });

  final bool isActive;

  @override
  State<AnimatedOrderExchangeIllustration> createState() =>
      _AnimatedOrderExchangeIllustrationState();
}

class _AnimatedOrderExchangeIllustrationState
    extends State<AnimatedOrderExchangeIllustration>
    with TickerProviderStateMixin {
  static const _loopDuration = Duration(milliseconds: 4500);
  static const _idleDuration = Duration(milliseconds: 3200);

  late final AnimationController _loopController;
  late final AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _loopController = AnimationController(vsync: this, duration: _loopDuration);
    _idleController = AnimationController(vsync: this, duration: _idleDuration);
    _syncPlayback();
  }

  @override
  void didUpdateWidget(covariant AnimatedOrderExchangeIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) _syncPlayback();
  }

  void _syncPlayback() {
    if (widget.isActive) {
      _loopController.repeat();
      _idleController.repeat(reverse: true);
    } else {
      _loopController.stop();
      _idleController.stop();
    }
  }

  @override
  void dispose() {
    _loopController.dispose();
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sceneWidth = constraints.maxWidth;
          final sceneHeight = constraints.maxHeight;
          final scale = (sceneWidth / 340).clamp(0.85, 1.15);

          return AnimatedBuilder(
            animation: Listenable.merge([_loopController, _idleController]),
            builder: (context, child) {
              final t = safeUnit(_loopController.value);
              final idle = safeUnit(_idleController.value);
              final breath = math.sin(idle * math.pi * 2) * 1.8 * scale;
              final blink = _blinkAmount(idle);
              final apronSway = math.sin(idle * math.pi * 2 + 0.4) * 0.015;

              final bagX = HandoffTimeline.bagXFactor(t) * sceneWidth;
              final bagY =
                  sceneHeight * 0.42 + HandoffTimeline.bagBounceY(t, scale);
              final bagRot = HandoffTimeline.bagSwingRadians(t);
              final handleSway = math.sin(safeUnit(t) * math.pi * 2) * 0.03;

              final assistantX = sceneWidth * 0.72;
              final customerX = sceneWidth * 0.22;
              final groundY = sceneHeight * 0.78;
              final bagCenter = Offset(bagX, bagY);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(child: WineShopBackground()),
                  Positioned(
                    left: customerX - 44 * scale,
                    top: groundY - 132 * scale,
                    child: CustomerCharacter(
                      scale: scale,
                      breathOffset: breath,
                      armAngle: HandoffTimeline.customerArmAngle(t),
                      headNod: HandoffTimeline.customerHeadNod(t),
                    ),
                  ),
                  Positioned(
                    left: assistantX - 46 * scale,
                    top: groundY - 136 * scale,
                    child: AssistantCharacter(
                      scale: scale,
                      breathOffset: -breath * 0.6,
                      armAngle: HandoffTimeline.assistantArmAngle(t),
                      blinkAmount: blink,
                      apronSway: apronSway,
                    ),
                  ),
                  Positioned(
                    left: bagX - 32 * scale,
                    top: bagY - 44 * scale,
                    child: Transform.rotate(
                      angle: bagRot,
                      child: PremiumWineGiftBag(
                        scale: scale,
                        handleSway: handleSway,
                      ),
                    ),
                  ),
                  ExchangeMotionEffects(
                    glowOpacity: HandoffTimeline.glowOpacity(t),
                    checkOpacity: HandoffTimeline.checkOpacity(t),
                    bagCenter: bagCenter,
                    scale: scale,
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  double _blinkAmount(double idle) {
    if (idle >= 0.90 && idle <= 0.94) {
      return safeCurve(Curves.easeInOut, idle, 0.90, 0.94);
    }
    return 0;
  }
}
