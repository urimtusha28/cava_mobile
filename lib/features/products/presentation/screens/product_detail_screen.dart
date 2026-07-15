import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../../../core/widgets/cava_loading_overlay.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../../cart/domain/add_to_cart_result.dart';
import '../../../categories/presentation/utils/category_badge_color_helper.dart';
import '../../domain/entities/product_entity.dart';
import '../controllers/product_detail_controller.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late final ProductDetailController _controller;
  late final Future<void> _loadFuture;

  int _quantity = 1;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = createProductDetailController();
    _loadFuture = _controller.load(widget.productId);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadFuture,
      builder: (context, snapshot) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final product = _controller.product;
            final isLoading =
                _controller.isLoading || !_controller.isInitialized;

            if (product == null) {
              return Scaffold(
                backgroundColor: AppColors.background,
                appBar: CavaAppBar(
                  title: AppLocalizations.of(context).productTitle,
                  showBack: true,
                  backgroundColor: AppColors.background,
                ),
                body: isLoading
                    ? const CavaLoadingOverlay(
                        isLoading: true,
                        child: SizedBox.expand(),
                      )
                    : Center(child: Text(AppLocalizations.of(context).productNotFound)),
              );
            }

            return _buildProductContent(product);
          },
        );
      },
    );
  }

  Widget _buildProductContent(ProductEntity product) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CavaAppBar(
        title: product.brand,
        showBack: true,
        titleStyle: AppTextStyles.bodySmall,
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screen,
                AppSpacing.sm,
                AppSpacing.screen,
                AppSpacing.lg,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProductImage(
                      product: product,
                      badgeLabel: _controller.categoryBadgeLabel,
                      categoryBadgeColor:
                          _controller.productSubcategory?.badgeColor,
                      parentBadgeColor: _controller.category?.badgeColor,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      product.brand,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 22,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _ProductTags(product: product),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      Formatters.currency(product.price),
                      style: AppTextStyles.priceLarge.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context).productVatNote,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      AppLocalizations.of(context).productDescription,
                      style: AppTextStyles.body.copyWith(
                        color: const Color(0xFF8A7B6E),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      product.description.isNotEmpty
                          ? product.description
                          : AppLocalizations.of(context).productDescriptionPlaceholder,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    TabBar(
                      controller: _tabController,
                      labelColor: AppColors.textPrimary,
                      unselectedLabelColor: AppColors.textSecondary,
                      indicatorColor: AppColors.burgundy,
                      indicatorWeight: 2.5,
                      dividerColor: AppColors.detailTag,
                      labelStyle: AppTextStyles.body,
                      unselectedLabelStyle: AppTextStyles.body,
                      tabs: [
                        Tab(text: AppLocalizations.of(context).productTabDetails),
                        Tab(text: AppLocalizations.of(context).productTabSuggestions),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_tabController.index == 0)
                      _DetailsTab(product: product)
                    else
                      _SuggestionsTab(product: product),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _BottomActions(
              quantity: _quantity,
              maxQuantity: product.stock,
              enabled: product.inStock,
              onQuantityChanged: (q) {
                final max = product.stock;
                final capped = max > 0 ? q.clamp(1, max) : 1;
                setState(() => _quantity = capped);
              },
              onCartIconTap: () => _handleAddToCart(navigateToCart: false),
              onBuyNowTap: () => _handleAddToCart(navigateToCart: true),
            ),
          ],
        ),
    );
  }

  Future<void> _handleAddToCart({required bool navigateToCart}) async {
    final result = await _controller.addToCart(quantity: _quantity);
    if (!mounted) {
      return;
    }

    switch (result) {
      case AddToCartResult.success:
        if (navigateToCart) {
          context.go(AppRoutes.cart);
        } else {
          _showCartMessage(AppLocalizations.of(context).productAddedToCart);
        }
      case AddToCartResult.outOfStock:
        _showCartMessage(AppLocalizations.of(context).productOutOfStock);
      case AddToCartResult.insufficientStock:
        _showCartMessage(AppLocalizations.of(context).insufficientStock);
      case AddToCartResult.failure:
        _showCartMessage(AppLocalizations.of(context).addToCartFailed);
    }
  }

  void _showCartMessage(String message) {
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
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({
    required this.product,
    required this.badgeLabel,
    this.categoryBadgeColor,
    this.parentBadgeColor,
  });

  final ProductEntity product;
  final String badgeLabel;
  final String? categoryBadgeColor;
  final String? parentBadgeColor;

  /// Hero image height ratio. Was 0.34 — +~15% for vertical bottle photos.
  static const double _imageHeightRatio = 0.39;

  @override
  Widget build(BuildContext context) {
    final color = Color(product.placeholderColor ?? 0xFF6B1D2A);
    final imageUrl = ProductImageView.hasUrl(product.detailImageUrl)
        ? product.detailImageUrl
        : product.imageUrl;
    final imageHeight = MediaQuery.sizeOf(context).height * _imageHeightRatio;
    final placeholder = Center(
      child: Icon(
        Icons.wine_bar_outlined,
        size: 110,
        color: color.withValues(alpha: 0.35),
      ),
    );

    final fallback = Theme.of(context).colorScheme.primary;
    final outOfStock = !product.inStock;
    final badgeBackground = outOfStock
        ? AppColors.burgundy
        : CategoryBadgeColorHelper.resolveBackground(
            badgeColor: categoryBadgeColor,
            parentBadgeColor: parentBadgeColor,
            fallback: fallback,
          );
    final badgeTextColor = outOfStock
        ? Colors.white
        : CategoryBadgeColorHelper.textColor(badgeBackground);
    final resolvedBadgeLabel =
        outOfStock ? AppLocalizations.of(context).outOfStockBadge : badgeLabel;

    return Stack(
      children: [
        Container(
          height: imageHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(20),
          ),
          child: ProductImageView(
            imageUrl: imageUrl,
            width: double.infinity,
            height: imageHeight,
            borderRadius: BorderRadius.circular(20),
            placeholder: placeholder,
          ),
        ),
        if (resolvedBadgeLabel.isNotEmpty)
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badgeBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                resolvedBadgeLabel,
                style: AppTextStyles.caption.copyWith(
                  color: badgeTextColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProductTags extends StatelessWidget {
  const _ProductTags({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final code = product.id.split('-').last.replaceAll(RegExp(r'\D'), '');
    final l10n = AppLocalizations.of(context);
    final origin = product.country ?? l10n.notAvailable;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _TagChip(label: l10n.productCodeLabel(code)),
        _TagChip(label: '${l10n.productOriginLabel(origin)} ${_countryFlag(product.country)}'),
      ],
    );
  }

  String _countryFlag(String? country) {
    return switch (country) {
      'Italy' || 'Itali' => '🇮🇹',
      'North Macedonia' => '🇲🇰',
      'Canada' => '🇨🇦',
      'France' => '🇫🇷',
      'USA' => '🇺🇸',
      'Scotland' => '🏴󠁧󠁢󠁳󠁣󠁴󠁿',
      _ => '',
    };
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final na = l10n.notAvailable;
    final rows = <(String, String)>[
      (l10n.detailGrapeType, _value(product.type, na)),
      (l10n.detailRegion, _value(product.country, na)),
      (l10n.detailVintage, na),
      (l10n.detailTaste, _value(product.tastingNotes, na)),
      (l10n.detailAbv, product.alcoholPercentage != null
          ? '${product.alcoholPercentage}%'
          : na),
      (l10n.detailVolume, product.volume),
      (l10n.detailBody, na),
      (l10n.detailTannins, na),
      (l10n.detailAging, na),
    ];

    return Column(
      children: [
        for (final row in rows)
          _DetailRow(label: row.$1, value: row.$2),
      ],
    );
  }

  String _value(String? value, String fallback) =>
      value != null && value.isNotEmpty ? value : fallback;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.minHeight,
  });

  final String label;
  final String value;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Container(
              constraints: BoxConstraints(minHeight: minHeight ?? 40),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionsTab extends StatelessWidget {
  const _SuggestionsTab({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final na = l10n.notAvailable;
    final rows = <(String, String, double?)>[
      (l10n.suggestTemperature, _value(product.servingTemp, na), null),
      (l10n.suggestDecanting, na, null),
      (l10n.suggestFinish, na, null),
      (l10n.suggestAromas, _value(product.tastingNotes, na), 72),
      (l10n.suggestPairing, _value(product.foodPairing, na), 72),
    ];

    return Column(
      children: [
        for (final row in rows)
          _DetailRow(label: row.$1, value: row.$2, minHeight: row.$3),
      ],
    );
  }

  String _value(String? value, String fallback) =>
      value != null && value.isNotEmpty ? value : fallback;
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.quantity,
    required this.maxQuantity,
    required this.enabled,
    required this.onQuantityChanged,
    required this.onCartIconTap,
    required this.onBuyNowTap,
  });

  final int quantity;
  final int maxQuantity;
  final bool enabled;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onCartIconTap;
  final VoidCallback onBuyNowTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screen,
        AppSpacing.md,
        AppSpacing.screen,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _QuantityControl(
              quantity: quantity,
              maxQuantity: maxQuantity,
              enabled: enabled,
              onChanged: onQuantityChanged,
            ),
            const SizedBox(width: AppSpacing.sm),
            Opacity(
              opacity: enabled ? 1 : 0.45,
              child: Material(
                color: AppColors.burgundy,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: enabled ? onCartIconTap : null,
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox(
                    width: 60,
                    height: 52,
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Opacity(
                opacity: enabled ? 1 : 0.45,
                child: Material(
                  color: AppColors.burgundy,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: enabled ? onBuyNowTap : null,
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 52,
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).buyNow,
                          style: AppTextStyles.button.copyWith(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.maxQuantity,
    required this.enabled,
    required this.onChanged,
  });

  final int quantity;
  final int maxQuantity;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final canDecrease = enabled && quantity > 1;
    final canIncrease = enabled && quantity < maxQuantity;

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Container(
        height: 52,
        constraints: const BoxConstraints(minWidth: 118),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QuantityButton(
              icon: Icons.chevron_left,
              onTap: canDecrease ? () => onChanged(quantity - 1) : null,
            ),
            SizedBox(
              width: 36,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: AppTextStyles.body,
              ),
            ),
            _QuantityButton(
              icon: Icons.chevron_right,
              onTap: canIncrease ? () => onChanged(quantity + 1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 36,
        height: 36,
        child: Icon(
          icon,
          size: 22,
          color: onTap == null ? AppColors.textMuted : AppColors.textPrimary,
        ),
      ),
    );
  }
}
