import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../router/app_routes.dart';
import '../utils/formatters.dart';
import '../../features/products/domain/entities/product_entity.dart';
import 'product_image_view.dart';
import 'product_wishlist_toggle.dart';

class ProductGridCard extends StatelessWidget {
  const ProductGridCard({
    super.key,
    required this.product,
    this.compact = false,
  });

  /// Compact image area (Home horizontal cards).
  static const double imageHeightCompact = 143;

  /// Grid image area (All Products, Category).
  static const double imageHeight = 185;

  /// Text block below compact image (padding included in SizedBox).
  static const double contentAreaHeightCompact = 125;

  /// Extra total card height — parent constraint only, not image.
  static const double cardHeightBump = 19;

  /// Compact text area inside card (grows with [cardHeightBump], not image).
  static const double compactContentHeight =
      contentAreaHeightCompact + cardHeightBump;

  /// [Border.all] on card — 1px top + 1px bottom inside height budget.
  static const double cardVerticalBorder = 2;

  /// Home horizontal row — must include border (grid cells are taller, so OK there).
  static const double homeRowHeight =
      imageHeightCompact + compactContentHeight + cardVerticalBorder;

  /// Grid cell aspect ratio — lower = taller card (more room below fixed image).
  static const double gridChildAspectRatio = 0.529;

  final ProductEntity product;
  final bool compact;

  double get _imageHeight => compact ? imageHeightCompact : imageHeight;

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
              height: _imageHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.06),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg - 1),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg - 1),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (product.inStock)
                      _productImage(color)
                    else
                      ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                        child: _productImage(color),
                      ),
                    if (!product.inStock) ...[
                      Container(color: Colors.black.withValues(alpha: 0.28)),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppLocalizations.of(context).outOfStockBadge,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (compact)
              SizedBox(
                height: compactContentHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: _buildContent(),
                ),
              )
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: _buildContent(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _productImage(Color color) {
    return ProductImageView(
      imageUrl: product.imageUrl,
      width: double.infinity,
      height: _imageHeight,
      placeholder: ProductImagePlaceholder(
        size: 48,
        color: color.withValues(alpha: 0.35),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          product.type,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ProductWishlistToggle(product: product),
            const Spacer(),
            Column(
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
          ],
        ),
      ],
    );
  }
}
