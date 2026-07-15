import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/products/domain/filtering/product_filter_options.dart';
import '../../features/products/domain/filtering/product_filter_state.dart';
import '../../features/products/domain/filtering/product_sort_option.dart';

Future<ProductFilterState?> showProductFilterSheet({
  required BuildContext context,
  required ProductFilterState initial,
  required ProductFilterOptions options,
}) {
  return showModalBottomSheet<ProductFilterState>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ProductFilterBottomSheet(
      initial: initial,
      options: options,
    ),
  );
}

class ProductFilterBottomSheet extends StatefulWidget {
  const ProductFilterBottomSheet({
    super.key,
    required this.initial,
    required this.options,
  });

  final ProductFilterState initial;
  final ProductFilterOptions options;

  @override
  State<ProductFilterBottomSheet> createState() =>
      _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  late ProductFilterState _draft;
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    final min = widget.options.minPrice;
    final max = widget.options.maxPrice <= min
        ? min + 1
        : widget.options.maxPrice;
    _priceRange = RangeValues(
      (_draft.minPrice ?? min).clamp(min, max),
      (_draft.maxPrice ?? max).clamp(min, max),
    );
  }

  Set<String> _toggleSet(Set<String> current, String value) {
    final next = Set<String>.from(current);
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(maxHeight: maxHeight),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.lg,
                    AppSpacing.screen,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Text(l10n.filterSortTitle, style: AppTextStyles.h3),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, size: 22),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      0,
                      AppSpacing.screen,
                      AppSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionTitle(l10n.filterSectionSort),
                        ...ProductSortOption.values.map(
                          (option) => InkWell(
                            onTap: () {
                              setState(() {
                                _draft = _draft.copyWith(sortOption: option);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    _draft.sortOption == option
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    size: 20,
                                    color: _draft.sortOption == option
                                        ? AppColors.burgundy
                                        : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      option.labelOf(l10n),
                                      style: AppTextStyles.bodySmall,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _sectionTitle(l10n.filterSectionPrice),
                        RangeSlider(
                          values: _priceRange,
                          min: widget.options.minPrice,
                          max: widget.options.maxPrice <= widget.options.minPrice
                              ? widget.options.minPrice + 1
                              : widget.options.maxPrice,
                          activeColor: AppColors.burgundy,
                          labels: RangeLabels(
                            '€${_priceRange.start.toStringAsFixed(0)}',
                            '€${_priceRange.end.toStringAsFixed(0)}',
                          ),
                          onChanged: (values) {
                            setState(() {
                              _priceRange = values;
                              _draft = _draft.copyWith(
                                minPrice: values.start,
                                maxPrice: values.end,
                              );
                            });
                          },
                        ),
                        Text(
                          '€${_priceRange.start.toStringAsFixed(0)} – €${_priceRange.end.toStringAsFixed(0)}',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            l10n.filterInStockOnly,
                            style: AppTextStyles.bodySmall,
                          ),
                          value: _draft.inStockOnly,
                          activeThumbColor: AppColors.burgundy,
                          onChanged: (value) {
                            setState(() {
                              _draft = _draft.copyWith(inStockOnly: value);
                            });
                          },
                        ),
                        if (widget.options.brands.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.md),
                          _sectionTitle(l10n.filterSectionBrand),
                          _chipWrap(
                            values: widget.options.brands,
                            selected: _draft.brands,
                            onToggle: (v) => setState(() {
                              _draft = _draft.copyWith(
                                brands: _toggleSet(_draft.brands, v),
                              );
                            }),
                          ),
                        ],
                        if (widget.options.countries.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          _sectionTitle(l10n.filterSectionOrigin),
                          _chipWrap(
                            values: widget.options.countries,
                            selected: _draft.countries,
                            onToggle: (v) => setState(() {
                              _draft = _draft.copyWith(
                                countries: _toggleSet(_draft.countries, v),
                              );
                            }),
                          ),
                        ],
                        if (widget.options.categories.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          _sectionTitle(l10n.filterSectionCategory),
                          _chipWrap(
                            values: widget.options.categories,
                            selected: _draft.categories,
                            onToggle: (v) => setState(() {
                              _draft = _draft.copyWith(
                                categories: _toggleSet(_draft.categories, v),
                              );
                            }),
                          ),
                        ],
                        if (widget.options.subcategories.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          _sectionTitle(l10n.filterSectionSubcategory),
                          _chipWrap(
                            values: widget.options.subcategories,
                            selected: _draft.subcategories,
                            onToggle: (v) => setState(() {
                              _draft = _draft.copyWith(
                                subcategories:
                                    _toggleSet(_draft.subcategories, v),
                              );
                            }),
                          ),
                        ],
                        if (widget.options.volumes.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.lg),
                          _sectionTitle(l10n.filterSectionVolume),
                          _chipWrap(
                            values: widget.options.volumes,
                            selected: _draft.volumes,
                            onToggle: (v) => setState(() {
                              _draft = _draft.copyWith(
                                volumes: _toggleSet(_draft.volumes, v),
                              );
                            }),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.screen,
                    AppSpacing.sm,
                    AppSpacing.screen,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _draft = ProductFilterState.empty;
                              final min = widget.options.minPrice;
                              final max = widget.options.maxPrice <= min
                                  ? min + 1
                                  : widget.options.maxPrice;
                              _priceRange = RangeValues(min, max);
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: Text(l10n.clear),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () =>
                              Navigator.of(context).pop(_draft),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.burgundy,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: Text(l10n.apply),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _chipWrap({
    required List<String> values,
    required Set<String> selected,
    required ValueChanged<String> onToggle,
  }) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final value in values)
          FilterChip(
            label: Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: selected.contains(value)
                    ? Colors.white
                    : AppColors.textPrimary,
              ),
            ),
            selected: selected.contains(value),
            onSelected: (_) => onToggle(value),
            selectedColor: AppColors.burgundy,
            backgroundColor: AppColors.surfaceMuted,
            checkmarkColor: Colors.white,
            side: BorderSide(
              color: selected.contains(value)
                  ? AppColors.burgundy
                  : AppColors.border,
            ),
          ),
      ],
    );
  }
}
