import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';

class CavaSearchBar extends StatelessWidget {
  const CavaSearchBar({
    super.key,
    this.hint = 'Kërko produkte…',
    this.onTap,
    this.controller,
    this.onChanged,
  });

  final String hint;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final editable = controller != null;

    return GestureDetector(
      onTap: editable ? null : onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textSecondary, size: 22),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: editable
                  ? TextField(
                      controller: controller,
                      onChanged: onChanged,
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        hint,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
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
