import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_spacing.dart';
import '../theme/app_text_styles.dart';

class CheckoutScreenHeader extends StatelessWidget {
  const CheckoutScreenHeader({
    super.key,
    required this.scriptTitle,
    required this.boldTitle,
    this.showBack = false,
    this.showClose = false,
    this.onBack,
    this.onClose,
  });

  final String scriptTitle;
  final String boldTitle;
  final bool showBack;
  final bool showClose;
  final VoidCallback? onBack;
  final VoidCallback? onClose;

  static const double _sideWidth = 40;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.sm,
        AppSpacing.screen,
        AppSpacing.md,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$scriptTitle $boldTitle',
            style: AppTextStyles.h2,
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeaderSideButton(
                visible: showBack,
                icon: Icons.arrow_back_ios_new,
                iconSize: 20,
                onPressed: onBack ?? () => context.pop(),
              ),
              _HeaderSideButton(
                visible: showClose,
                icon: Icons.close,
                iconSize: 22,
                onPressed: onClose ?? () => context.pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderSideButton extends StatelessWidget {
  const _HeaderSideButton({
    required this.visible,
    required this.icon,
    required this.iconSize,
    required this.onPressed,
  });

  final bool visible;
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: CheckoutScreenHeader._sideWidth,
      height: CheckoutScreenHeader._sideWidth,
      child: visible
          ? IconButton(
              onPressed: onPressed,
              icon: Icon(icon, size: iconSize),
              padding: EdgeInsets.zero,
            )
          : null,
    );
  }
}
