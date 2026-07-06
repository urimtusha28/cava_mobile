import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class RatingWidget extends StatelessWidget {
  const RatingWidget({
    super.key,
    required this.rating,
    this.size = 12,
  });

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          rating >= i + 1 ? Icons.star_rounded : Icons.star_outline_rounded,
          size: size,
          color: rating >= i + 1 ? AppColors.gold : AppColors.border,
        );
      }),
    );
  }
}
