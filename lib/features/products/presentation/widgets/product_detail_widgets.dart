import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_radius.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/price_widget.dart';
import '../../../../core/widgets/info_card.dart';
import '../../../../core/widgets/product_image_view.dart';
import '../../domain/entities/product_entity.dart';

class ProductHeroImage extends StatelessWidget {
  const ProductHeroImage({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final color = Color(product.placeholderColor ?? 0xFF6B1D2A);
    final height = MediaQuery.sizeOf(context).height * 0.36;
    final imageUrl = ProductImageView.hasUrl(product.detailImageUrl)
        ? product.detailImageUrl
        : product.imageUrl;
    final placeholder = Center(
      child: Icon(
        Icons.wine_bar_outlined,
        size: 120,
        color: color.withValues(alpha: 0.35),
      ),
    );

    return Container(
      height: height,
      width: double.infinity,
      color: AppColors.surfaceMuted,
      child: ProductImageView(
        imageUrl: imageUrl,
        width: double.infinity,
        height: height,
        placeholder: placeholder,
      ),
    );
  }
}

class ProductHeaderInfo extends StatelessWidget {
  const ProductHeaderInfo({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(product.brand.toUpperCase(), style: AppTextStyles.brand),
        const SizedBox(height: AppSpacing.sm),
        Text(
          product.name,
          style: AppTextStyles.h1,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        _MetaRow(l10n.metaCountry, product.country ?? l10n.emDash),
        _MetaRow(l10n.metaBottle, product.volume),
        if (product.alcoholPercentage != null)
          _MetaRow(l10n.metaAlcohol, '${product.alcoholPercentage}%'),
        const SizedBox(height: AppSpacing.lg),
        PriceWidget(
          price: product.price,
          oldPrice: product.oldPrice,
          large: true,
        ),
      ],
    );
  }
}

class ProductInfoCardsRow extends StatelessWidget {
  const ProductInfoCardsRow({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cards = [
      (Icons.eco_outlined, l10n.infoVariety, product.type),
      (Icons.public, l10n.metaCountry, product.country ?? l10n.emDash),
      (Icons.local_bar, l10n.infoServing, product.servingTemp ?? l10n.emDash),
      (Icons.percent, l10n.metaAlcohol, product.alcoholPercentage != null ? '${product.alcoholPercentage}%' : l10n.emDash),
    ];

    return Row(
      children: cards.map((c) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: c == cards.last ? 0 : AppSpacing.sm,
            ),
            child: InfoCard(icon: c.$1, label: c.$2, value: c.$3),
          ),
        );
      }).toList(),
    );
  }
}

class ProductDetailSections extends StatelessWidget {
  const ProductDetailSections({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _ExpandableSection(title: l10n.sectionDescription, content: product.description),
        if (product.foodPairing != null)
          _ExpandableSection(title: l10n.sectionFoodPairing, content: product.foodPairing!),
        if (product.tastingNotes != null)
          _ExpandableSection(title: l10n.sectionTastingNotes, content: product.tastingNotes!),
        if (product.winery != null)
          _ExpandableSection(title: l10n.sectionWinery, content: product.winery!),
      ],
    );
  }
}

class ProductBottomCta extends StatelessWidget {
  const ProductBottomCta({
    super.key,
    required this.price,
    this.onPressed,
  });

  final double price;
  final VoidCallback? onPressed;

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
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: onPressed ?? () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            child: Row(
              children: [
                Text(AppLocalizations.of(context).addToCartCta, style: AppTextStyles.button),
                const Spacer(),
                Text(Formatters.currency(price), style: AppTextStyles.button),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text('$label: $value', style: AppTextStyles.bodySmall),
    );
  }
}

class _ExpandableSection extends StatefulWidget {
  const _ExpandableSection({required this.title, required this.content});

  final String title;
  final String content;

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.title, style: AppTextStyles.h3),
            trailing: Icon(
              _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Text(widget.content, style: AppTextStyles.bodySmall),
            ),
        ],
      ),
    );
  }
}
