import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../../features/categories/domain/entities/subcategory_entity.dart';

class SubcategoryChipBar extends StatelessWidget {
  const SubcategoryChipBar({
    super.key,
    required this.subcategories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<SubcategoryEntity> subcategories;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
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

          return GestureDetector(
            onTap: () => onSelected(sub.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.burgundy : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: selected ? AppColors.burgundy : AppColors.border,
                ),
              ),
              child: Text(
                sub.label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
