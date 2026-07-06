import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/formatters.dart';

class PriceWidget extends StatelessWidget {
  const PriceWidget({
    super.key,
    required this.price,
    this.oldPrice,
    this.large = false,
  });

  final double price;
  final double? oldPrice;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (oldPrice != null) ...[
          Text(
            Formatters.currency(oldPrice!),
            style: AppTextStyles.bodySmall.copyWith(
              decoration: TextDecoration.lineThrough,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Text(
          Formatters.currency(price),
          style: large ? AppTextStyles.priceLarge : AppTextStyles.price,
        ),
      ],
    );
  }
}
