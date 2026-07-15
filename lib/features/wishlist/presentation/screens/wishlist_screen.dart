import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/state/wishlist_state_notifier.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../cart/domain/add_to_cart_result.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../controllers/wishlist_controller.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  late final WishlistController _controller;
  late final Future<void> _loadFuture;

  @override
  void initState() {
    super.initState();
    _controller = createWishlistController();
    _loadFuture = _controller.load();
  }

  void _removeProduct(String productId) => _controller.remove(productId);

  Future<void> _addToCart(ProductEntity product) async {
    final result = await _controller.addToCart(product);
    if (!mounted) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final message = switch (result) {
      AddToCartResult.success => l10n.productAddedToCart,
      AddToCartResult.outOfStock => l10n.productOutOfStock,
      AddToCartResult.insufficientStock => l10n.insufficientStock,
      AddToCartResult.failure => l10n.addToCartFailed,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.burgundy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        return ValueListenableBuilder<int>(
          valueListenable: WishlistStateNotifier.revision,
          builder: (context, _, child) {
            return ListenableBuilder(
              listenable: _controller,
              builder: (context, _) {
                final products = _controller.items;

                return Scaffold(
                  backgroundColor: AppColors.background,
                  appBar: CavaAppBar(title: l10n.wishlistTitle),
                  body: products.isEmpty
                      ? _WishlistEmptyState(
                          message: l10n.wishlistEmpty,
                          buttonLabel: l10n.viewProducts,
                          onViewProducts: () =>
                              context.push(AppRoutes.category('all')),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.screen),
                          itemCount: products.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.md),
                          itemBuilder: (_, index) {
                            final product = products[index];
                            return _WishlistItemCard(
                              product: product,
                              onRemove: () => _removeProduct(product.id),
                              onAddToCart: () => _addToCart(product),
                              onTap: () =>
                                  context.push(AppRoutes.product(product.id)),
                            );
                          },
                        ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _WishlistEmptyState extends StatelessWidget {
  const _WishlistEmptyState({
    required this.message,
    required this.buttonLabel,
    required this.onViewProducts,
  });

  final String message;
  final String buttonLabel;
  final VoidCallback onViewProducts;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screen),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: AppTextStyles.emptyState,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Material(
              color: AppColors.burgundy,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onViewProducts,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Text(buttonLabel, style: AppTextStyles.button),
                ),
              ),
            ),
          ],
        ),
      ),
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
    final l10n = AppLocalizations.of(context);
    final color = Color(product.placeholderColor ?? 0xFF6B1D2A);
    final placeholder = Icon(
      Icons.wine_bar_outlined,
      color: color.withValues(alpha: 0.45),
      size: 32,
    );

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
                  clipBehavior: Clip.antiAlias,
                  child: ProductImageView(
                    imageUrl: product.imageUrl,
                    width: 56,
                    height: 72,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    placeholder: Center(child: placeholder),
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
                              l10n.addToCart,
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
