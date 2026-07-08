import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shared Cart / Checkout footer CTA ("Vazhdo", "Bli").
///
/// Width is locked to the wider reference label so both buttons match visually.
class FooterActionButton extends StatelessWidget {
  const FooterActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.enabled = true,
  });

  /// Reference label used to size all footer CTAs (Cart "Vazhdo").
  static const String referenceLabel = 'Vazhdo';

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool enabled;

  static double _minWidthForReference(BuildContext context) {
    final painter = TextPainter(
      text: TextSpan(text: referenceLabel, style: AppTextStyles.button),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    // Same horizontal padding as Cart "Vazhdo" (28 + 28).
    return painter.width + 56;
  }

  @override
  Widget build(BuildContext context) {
    final minWidth = _minWidthForReference(context);
    final canTap = enabled && !isLoading && onTap != null;

    return Material(
      color: canTap || isLoading
          ? AppColors.burgundy
          : AppColors.textMuted,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: canTap ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: minWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(label, style: AppTextStyles.button),
            ),
          ),
        ),
      ),
    );
  }
}
