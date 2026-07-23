import 'package:flutter/material.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Compact filter icon with optional badge for active filter count.
class ProductFilterButton extends StatelessWidget {
  const ProductFilterButton({
    super.key,
    required this.activeCount,
    required this.onPressed,
  });

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color =
        activeCount > 0 ? AppColors.burgundy : AppColors.textPrimary;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          tooltip: 'Filtro & Sorto',
          icon: Image.asset(
            AppAssets.filter,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
            color: color,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
        if (activeCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.burgundy,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 16),
              child: Text(
                '$activeCount',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
