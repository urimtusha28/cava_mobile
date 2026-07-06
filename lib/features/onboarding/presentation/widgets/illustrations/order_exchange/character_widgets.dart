import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class CustomerCharacter extends StatelessWidget {
  const CustomerCharacter({
    super.key,
    required this.breathOffset,
    required this.armAngle,
    required this.headNod,
    required this.scale,
  });

  final double breathOffset;
  final double armAngle;
  final double headNod;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, breathOffset),
      child: SizedBox(
        width: 88 * scale,
        height: 150 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            _Body(scale: scale, isAssistant: false),
            Positioned(
              top: 8 * scale,
              child: Transform.rotate(
                angle: headNod,
                child: _Head(
                  scale: scale,
                  isFemale: false,
                  blinkAmount: 0,
                ),
              ),
            ),
            Positioned(
              right: -4 * scale,
              bottom: 52 * scale,
              child: Transform.rotate(
                angle: armAngle * math.pi / 180,
                alignment: Alignment.topCenter,
                child: _Arm(scale: scale, isLeft: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssistantCharacter extends StatelessWidget {
  const AssistantCharacter({
    super.key,
    required this.breathOffset,
    required this.armAngle,
    required this.blinkAmount,
    required this.apronSway,
    required this.scale,
  });

  final double breathOffset;
  final double armAngle;
  final double blinkAmount;
  final double apronSway;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, breathOffset),
      child: SizedBox(
        width: 92 * scale,
        height: 154 * scale,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            _Body(scale: scale, isAssistant: true),
            _Apron(scale: scale, sway: apronSway),
            Positioned(
              top: 6 * scale,
              child: _Head(
                scale: scale,
                isFemale: true,
                blinkAmount: blinkAmount,
              ),
            ),
            Positioned(
              left: -2 * scale,
              bottom: 54 * scale,
              child: Transform.rotate(
                angle: armAngle * math.pi / 180,
                alignment: Alignment.topCenter,
                child: _Arm(scale: scale, isLeft: true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.scale, required this.isAssistant});

  final double scale;
  final bool isAssistant;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      child: Container(
        width: 56 * scale,
        height: 72 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(18 * scale),
            bottom: Radius.circular(10 * scale),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isAssistant
                ? [const Color(0xFFF7F2EA), const Color(0xFFE8DFD3)]
                : [const Color(0xFFEDE8E2), const Color(0xFFD8D2CB)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: Offset(0, 3 * scale),
            ),
          ],
        ),
      ),
    );
  }
}

class _Apron extends StatelessWidget {
  const _Apron({required this.scale, required this.sway});

  final double scale;
  final double sway;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 2 * scale,
      child: Transform.rotate(
        angle: sway,
        child: Container(
          width: 50 * scale,
          height: 58 * scale,
          padding: EdgeInsets.only(top: 8 * scale),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(8 * scale),
              bottom: Radius.circular(12 * scale),
            ),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.burgundy, AppColors.burgundyDark],
            ),
          ),
          child: Column(
            children: [
              Text(
                'CAVA',
                style: TextStyle(
                  fontSize: 7 * scale,
                  color: AppColors.gold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Premium',
                style: TextStyle(
                  fontSize: 5.5 * scale,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({
    required this.scale,
    required this.isFemale,
    required this.blinkAmount,
  });

  final double scale;
  final bool isFemale;
  final double blinkAmount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46 * scale,
      height: 52 * scale,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (isFemale) ...[
            Positioned(
              top: 0,
              child: Container(
                width: 50 * scale,
                height: 34 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D2B22),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24 * scale),
                    bottom: Radius.circular(8 * scale),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -6 * scale,
              top: 14 * scale,
              child: Container(
                width: 16 * scale,
                height: 36 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D2B22),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
              ),
            ),
          ] else
            Positioned(
              top: 4 * scale,
              child: Container(
                width: 40 * scale,
                height: 18 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A3A30),
                  borderRadius: BorderRadius.circular(10 * scale),
                ),
              ),
            ),
          Container(
            width: 40 * scale,
            height: 40 * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFF2D8C8),
                  const Color(0xFFE5C4AE),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: Offset(0, 2 * scale),
                ),
              ],
            ),
          ),
          Positioned(
            top: 18 * scale,
            child: Row(
              children: [
                _Eye(scale: scale, blinkAmount: blinkAmount),
                SizedBox(width: 10 * scale),
                _Eye(scale: scale, blinkAmount: blinkAmount),
              ],
            ),
          ),
          Positioned(
            bottom: 10 * scale,
            child: Container(
              width: 12 * scale,
              height: 5 * scale,
              decoration: BoxDecoration(
                color: AppColors.burgundy.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye({required this.scale, required this.blinkAmount});

  final double scale;
  final double blinkAmount;

  @override
  Widget build(BuildContext context) {
    final openHeight = 5.0 * scale;
    final height = openHeight * (1 - blinkAmount) + 0.6 * scale * blinkAmount;

    return Container(
      width: 5 * scale,
      height: height.clamp(0.6 * scale, openHeight),
      decoration: BoxDecoration(
        color: const Color(0xFF3A2A22),
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}

class _Arm extends StatelessWidget {
  const _Arm({required this.scale, required this.isLeft});

  final double scale;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10 * scale,
      height: 34 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF2D8C8),
            const Color(0xFFE5C4AE),
          ],
        ),
      ),
    );
  }
}
