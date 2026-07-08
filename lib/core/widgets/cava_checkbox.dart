import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Branded checkbox matching the Cava reference design.
///
/// Unselected: white fill, burgundy border, empty inside.
/// Selected: white fill, burgundy border, small filled burgundy square centered.
/// Never uses a checkmark icon.
class CavaCheckbox extends StatelessWidget {
  const CavaCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 18,
    this.borderRadius = 3,
    this.borderWidth = 1.5,
    this.innerSize,
  });

  final bool value;
  final ValueChanged<bool?>? onChanged;
  final double size;
  final double borderRadius;
  final double borderWidth;

  /// Size of the inner filled square when selected. Defaults to ~50% of [size].
  final double? innerSize;

  bool get _enabled => onChanged != null;

  @override
  Widget build(BuildContext context) {
    final resolvedInner = innerSize ?? (size * 0.5);
    final borderColor = AppColors.burgundy.withValues(
      alpha: _enabled ? 1 : 0.4,
    );
    final fillColor = Colors.white.withValues(alpha: _enabled ? 1 : 0.6);

    return Semantics(
      checked: value,
      enabled: _enabled,
      button: true,
      child: GestureDetector(
        onTap: _enabled ? () => onChanged!(!value) : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
          ),
          child: value
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: resolvedInner,
                  height: resolvedInner,
                  decoration: BoxDecoration(
                    color: AppColors.burgundy.withValues(
                      alpha: _enabled ? 1 : 0.4,
                    ),
                    borderRadius: BorderRadius.circular(
                      borderRadius * 0.5,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
