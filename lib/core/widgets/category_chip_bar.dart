import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../router/app_routes.dart';
import '../../features/categories/domain/entities/category_entity.dart';
import '../../features/categories/presentation/utils/category_badge_color_helper.dart';

class CategoryChipBar extends StatelessWidget {
  const CategoryChipBar({
    super.key,
    required this.categories,
    this.selectedId,
    this.onSelected,
    this.showAllProducts = false,
  });

  final List<CategoryEntity> categories;
  final String? selectedId;
  final ValueChanged<String>? onSelected;
  final bool showAllProducts;

  static const _allProductsId = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final itemCount = categories.length + (showAllProducts ? 1 : 0);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          if (showAllProducts && index == 0) {
            return _Chip(
              label: l10n.allProductsChip,
              selected: selectedId == _allProductsId,
              badgeColor: null,
              onTap: () => _handleTap(context, _allProductsId),
            );
          }

          final cat = categories[showAllProducts ? index - 1 : index];
          return _Chip(
            label: cat.label,
            selected: cat.id == selectedId,
            badgeColor: cat.badgeColor,
            onTap: () => _handleTap(context, cat.id),
          );
        },
      ),
    );
  }

  void _handleTap(BuildContext context, String id) {
    if (onSelected != null) {
      onSelected!(id);
      return;
    }
    context.push(AppRoutes.category(id));
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.badgeColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final String? badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fallback = Theme.of(context).colorScheme.primary;
    final accent = CategoryBadgeColorHelper.resolveBackground(
      badgeColor: badgeColor,
      fallback: fallback,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accent : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: selected ? accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected
                ? CategoryBadgeColorHelper.textColor(accent)
                : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
