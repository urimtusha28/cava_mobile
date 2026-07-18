import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

/// Premium loading overlay — AppBar logo + burgundy ring below.
class CavaLoadingOverlay extends StatelessWidget {
  const CavaLoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
  });

  final bool isLoading;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: AppColors.background.withValues(alpha: 0.72),
                child: const Center(
                  child: CavaPremiumLoader(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Same mark as [CavaAppBar] logo, with an indeterminate ring filling below.
/// Public so the splash screen shows the identical brand loader; [color]
/// defaults to burgundy (overlay on light surfaces) and can be overridden for
/// dark backgrounds (e.g. the splash gradient).
class CavaPremiumLoader extends StatelessWidget {
  const CavaPremiumLoader({super.key, this.color = AppColors.burgundy});

  final Color color;

  static const double logoSize = 56;
  static const double ringSize = 32;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          AppAssets.logo,
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: ringSize,
          height: ringSize,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: color,
            backgroundColor: color.withValues(alpha: 0.14),
          ),
        ),
      ],
    );
  }
}
