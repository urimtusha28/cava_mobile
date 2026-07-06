import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/cava_app_bar.dart';
import '../../presentation/product_detail_query.dart';
import '../../domain/entities/product_entity.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
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
    final product = ProductDetailQuery.byId(widget.productId);

    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CavaAppBar(
          title: 'Produkti',
          showBack: true,
          backgroundColor: AppColors.background,
        ),
        body: const Center(child: Text('Produkti nuk u gjet')),
      );
    }

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
                    _ProductImage(product: product),
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
                      'TVSH llogaritet në arkë',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Përshkrimi',
                      style: AppTextStyles.body.copyWith(
                        color: const Color(0xFF8A7B6E),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      product.description.isNotEmpty
                          ? product.description
                          : 'Është duke u përpunuar përshkrimi, ju kërkojmë ndjesë.',
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
                      tabs: const [
                        Tab(text: 'Detajet'),
                        Tab(text: 'Sugjerimet'),
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
              onQuantityChanged: (q) => setState(() => _quantity = q),
            ),
          ],
        ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final color = Color(product.placeholderColor ?? 0xFF6B1D2A);

    return Stack(
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.34,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.wine_bar_outlined,
            size: 110,
            color: color.withValues(alpha: 0.35),
          ),
        ),
        Positioned(
          top: 14,
          left: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.burgundy,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              product.categoryName,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
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
    final origin = product.country ?? 'N/A';

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _TagChip(label: 'Kodi: $code'),
        _TagChip(label: 'Origjina: $origin ${_countryFlag(product.country)}'),
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
    final rows = <(String, String)>[
      ('Lloji i rrushit:', _value(product.type)),
      ('Rajoni:', _value(product.country)),
      ('Vintage:', 'N/A'),
      ('Shija:', _value(product.tastingNotes)),
      ('ABV:', product.alcoholPercentage != null
          ? '${product.alcoholPercentage}%'
          : 'N/A'),
      ('Volume:', product.volume),
      ('Trupi:', 'N/A'),
      ('Taninet:', 'N/A'),
      ('Vjetrimi:', 'N/A'),
    ];

    return Column(
      children: [
        for (final row in rows)
          _DetailRow(label: row.$1, value: row.$2),
      ],
    );
  }

  String _value(String? value) =>
      value != null && value.isNotEmpty ? value : 'N/A';
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Padding(
              padding: EdgeInsets.only(top: minHeight != null ? 10 : 0),
              child: Text(
                label,
                textAlign: TextAlign.right,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
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
              alignment: Alignment.topLeft,
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
    final rows = <(String, String, double?)>[
      ('Temperatura:', _value(product.servingTemp), null),
      ('Dekantimi:', 'N/A', null),
      ('Përfundimi:', 'N/A', null),
      ('Aromat:', _value(product.tastingNotes), 72),
      ('Kombinimi:', _value(product.foodPairing), 72),
    ];

    return Column(
      children: [
        for (final row in rows)
          _DetailRow(label: row.$1, value: row.$2, minHeight: row.$3),
      ],
    );
  }

  String _value(String? value) =>
      value != null && value.isNotEmpty ? value : 'N/A';
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.quantity,
    required this.onQuantityChanged,
  });

  final int quantity;
  final ValueChanged<int> onQuantityChanged;

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
              onChanged: onQuantityChanged,
            ),
            const SizedBox(width: AppSpacing.sm),
            Material(
              color: AppColors.burgundy,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => context.push(AppRoutes.cart),
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 60,
                  height: 52,
                  child: Icon(Icons.shopping_cart_outlined, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Material(
                color: AppColors.burgundy,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => context.push(AppRoutes.cart),
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 52,
                    child: Center(
                      child: Text(
                        'Bli tani',
                        style: AppTextStyles.button.copyWith(fontSize: 16),
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
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
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
            onTap: () => onChanged(quantity + 1),
          ),
        ],
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
