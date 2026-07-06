import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../constants/app_radius.dart';
import '../constants/app_spacing.dart';
import '../router/app_routes.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key, this.cartCount = 2});

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.38;

    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.hero),
          bottomRight: Radius.circular(AppRadius.hero),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C0A12),
            Color(0xFF6B1D2A),
            Color(0xFF4A1520),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -30,
            bottom: -20,
            child: Icon(
              Icons.wine_bar,
              size: 200,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: AppSpacing.screen,
                  right: AppSpacing.screen,
                  top: 0,
                  child: _TopBar(cartCount: cartCount),
                ),
                Positioned(
                  left: AppSpacing.screen,
                  right: AppSpacing.screen,
                  bottom: AppSpacing.lg,
                  child: _HeroContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.cartCount});

  final int cartCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              child: const Icon(Icons.wine_bar, color: Colors.white, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CAVA PREMIUM',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Premium Collection',
                  style: AppTextStyles.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            _CircleIcon(icon: Icons.search, onTap: () {}),
            const SizedBox(width: AppSpacing.sm),
            _CircleIcon(
              icon: Icons.shopping_bag_outlined,
              badge: cartCount,
              onTap: () => context.push(AppRoutes.cart),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Discover Premium\nCollection', style: AppTextStyles.display),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Wine • Spirits • Tobacco • Accessories',
          style: AppTextStyles.displaySub,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: 180,
          child: ElevatedButton(
            onPressed: () => context.push(AppRoutes.category('wines')),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.burgundy,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            child: Text(
              'Explore Collection',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.burgundy,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({
    required this.icon,
    this.badge,
    this.onTap,
  });

  final IconData icon;
  final int? badge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          if (badge != null && badge! > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badge',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
