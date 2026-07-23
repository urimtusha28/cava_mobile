import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../router/app_routes.dart';
import '../../features/products/domain/entities/product_entity.dart';
import 'price_widget.dart';
import 'product_image_view.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final ProductEntity product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(product.placeholderColor ?? 0xFF6B1D2A);

    return GestureDetector(
      onTap: onTap ?? () => context.push(AppRoutes.product(product.id)),
      child: Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        padding: const EdgeInsets.all(AppSpacing.card),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: ProductImageView(
                  imageUrl: product.imageUrl,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  placeholder: Center(
                    child: ProductImagePlaceholder(
                      size: 64,
                      color: color.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.brand.toUpperCase(), style: AppTextStyles.brand),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: AppTextStyles.h3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  if (product.country != null)
                    Text(product.country!, style: AppTextStyles.caption),
                  if (product.alcoholPercentage != null)
                    Text(
                      '${product.alcoholPercentage}% • ${product.volume}',
                      style: AppTextStyles.caption,
                    ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PriceWidget(price: product.price, oldPrice: product.oldPrice),
                      Row(
                        children: [
                          Text(
                            'View',
                            style: AppTextStyles.caption.copyWith(
                            ),
                          ),
                          const Icon(Icons.arrow_forward, size: 14),
                        ],
                      ),
                    ],
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
