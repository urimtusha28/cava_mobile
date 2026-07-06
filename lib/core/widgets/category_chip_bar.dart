import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../router/app_routes.dart';
import '../../features/categories/domain/entities/category_entity.dart';

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
              label: 'All Products',
              selected: selectedId == _allProductsId,
              onTap: () => _handleTap(context, _allProductsId),
            );
          }

          final cat = categories[showAllProducts ? index - 1 : index];
          return _Chip(
            label: cat.label,
            selected: cat.id == selectedId,
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
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
