import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../../features/categories/domain/entities/subcategory_entity.dart';
import '../../features/categories/presentation/utils/category_badge_color_helper.dart';

class SubcategoryChipBar extends StatelessWidget {
  const SubcategoryChipBar({
    super.key,
    required this.subcategories,
    required this.selectedId,
    required this.onSelected,
    this.parentBadgeColor,
  });

  final List<SubcategoryEntity> subcategories;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final String? parentBadgeColor;

  String _displayLabel(SubcategoryEntity sub, AppLocalizations l10n) {
    if (sub.id != 'all') return sub.label;
    // Synthetic "all" chips only — keep data labels like "All Wines".
    if (sub.label.isEmpty || sub.label == 'All Products') {
      return l10n.allProductsChip;
    }
    if (sub.label == 'All') return l10n.allChip;
    return sub.label;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
        itemCount: subcategories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final sub = subcategories[index];
          final selected = sub.id == selectedId;
          final fallback = Theme.of(context).colorScheme.primary;
          final accent = CategoryBadgeColorHelper.resolveBackground(
            badgeColor: sub.badgeColor,
            parentBadgeColor: parentBadgeColor,
            fallback: fallback,
          );

          return GestureDetector(
            onTap: () => onSelected(sub.id),
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
                _displayLabel(sub, l10n),
                style: AppTextStyles.bodySmall.copyWith(
                  color: selected
                      ? CategoryBadgeColorHelper.textColor(accent)
                      : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
