import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../cart/presentation/cart_query.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../wishlist_query.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  void _removeProduct(String productId) => WishlistQuery.remove(productId);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: WishlistQuery.revision,
      builder: (context, _, child) {
        final products = WishlistQuery.getItems();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: const CavaAppBar(title: 'Wishlist'),
          body: products.isEmpty
              ? Center(
                  child: Text('Wishlist është bosh', style: AppTextStyles.bodySmall),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screen),
                  itemCount: products.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, index) {
                    final product = products[index];
                    return _WishlistItemCard(
                      product: product,
                      onRemove: () => _removeProduct(product.id),
                      onAddToCart: () => CartQuery.addProduct(product),
                      onTap: () => context.push(AppRoutes.product(product.id)),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _WishlistItemCard extends StatelessWidget {
  const _WishlistItemCard({
    required this.product,
    required this.onRemove,
    required this.onAddToCart,
    required this.onTap,
  });

  final ProductEntity product;
  final VoidCallback onRemove;
  final VoidCallback onAddToCart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = Color(product.placeholderColor ?? 0xFF6B1D2A);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 56,
                  height: 72,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    Icons.wine_bar_outlined,
                    color: color.withValues(alpha: 0.45),
                    size: 32,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.brand, style: AppTextStyles.caption),
                      const SizedBox(height: 2),
                      Text(
                        product.name,
                        style: AppTextStyles.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.type,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.currency(product.price),
                            style: AppTextStyles.price.copyWith(fontSize: 15),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: onAddToCart,
                            child: Text(
                              'Shto në shportë',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.burgundy,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
