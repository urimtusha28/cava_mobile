import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_radius.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailing,
    this.icon,
    this.pill = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final String? trailing;
  final IconData? icon;
  final bool pill;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final radius = pill ? AppRadius.pill : AppRadius.md;

    if (outlined) {
      return SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.burgundy),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: Text(
            label,
            style: AppTextStyles.button.copyWith(color: AppColors.burgundy),
          ),
        ),
      );
    }

    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label, style: AppTextStyles.button),
            if (trailing != null) ...[
              const Spacer(),
              Text(trailing!, style: AppTextStyles.button),
            ],
          ],
        ),
      ),
    );
  }
}
