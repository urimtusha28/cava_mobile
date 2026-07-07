import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../router/app_routes.dart';
import '../utils/formatters.dart';
import '../../features/products/domain/entities/product_entity.dart';
import 'product_image_view.dart';

class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    super.key,
    required this.product,
    this.compact = false,
  });

  final ProductEntity product;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = Color(product.placeholderColor ?? 0xFF6B1D2A);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.product(product.id)),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: compact ? 110 : 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg - 1),
                ),
              ),
              child: ProductImageView(
                imageUrl: product.imageUrl,
                width: double.infinity,
                height: compact ? 110 : 140,
                placeholder: Icon(
                  _iconFor(product.categoryId),
                  size: 48,
                  color: color.withValues(alpha: 0.35),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.type,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            Formatters.currency(product.price),
                            style: AppTextStyles.price.copyWith(fontSize: 15),
                          ),
                          if (product.oldPrice != null)
                            Text(
                              Formatters.currency(product.oldPrice!),
                              style: AppTextStyles.caption.copyWith(
                                decoration: TextDecoration.lineThrough,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String categoryId) {
    switch (categoryId) {
      case 'wines':
        return Icons.wine_bar_outlined;
      case 'spirits':
        return Icons.liquor_outlined;
      case 'liqueurs':
        return Icons.local_bar_outlined;
      case 'tobacco':
        return Icons.smoking_rooms_outlined;
      case 'accessories':
        return Icons.card_giftcard_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }
}
