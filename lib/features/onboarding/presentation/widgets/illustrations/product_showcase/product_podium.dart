import 'package:flutter/material.dart';

import '../../../../../../core/theme/app_colors.dart';

class ProductPodium extends StatelessWidget {
  const ProductPodium({
    super.key,
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height + 28,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(width * 0.18),
                  bottom: Radius.circular(6),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFFFFF), Color(0xFFF7F4EF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.burgundy.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: height - 4,
            child: Container(
              width: width * 0.88,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Positioned(
            bottom: height - 6,
            child: child,
          ),
        ],
      ),
    );
  }
}
