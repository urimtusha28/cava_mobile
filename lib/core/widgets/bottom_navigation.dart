import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_assets.dart';
import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../features/cart/data/mock/mock_cart.dart';
import '../../features/wishlist/data/mock/mock_wishlist.dart';
import '../router/app_routes.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  late final NotchBottomBarController _controller;

  static const _items = [
    (asset: AppAssets.navHome, label: 'Home'),
    (asset: AppAssets.navWishlist, label: 'Wishlist'),
    (asset: AppAssets.navShopping, label: 'Shporta'),
    (asset: AppAssets.navProfile, label: 'Profili'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = NotchBottomBarController(index: widget.currentIndex);
  }

  @override
  void didUpdateWidget(BottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex &&
        _controller.index != widget.currentIndex) {
      _controller.jumpTo(widget.currentIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = AppSpacing.sm;
    const bottomPadding = AppSpacing.lg;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final barWidth = screenWidth - horizontalPadding * 2;

    return ValueListenableBuilder<int>(
      valueListenable: MockCart.revision,
      builder: (context, _, child) {
        return ValueListenableBuilder<int>(
          valueListenable: MockWishlist.revision,
          builder: (context, _, child) {
            final wishlistCount = MockWishlist.count;
            final cartCount = MockCart.itemCount;

            return SafeArea(
              minimum: const EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                bottomPadding,
              ),
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(barWidth, MediaQuery.sizeOf(context).height),
                ),
                child: AnimatedNotchBottomBar(
                  notchBottomBarController: _controller,
                  color: AppColors.surface,
                  showLabel: true,
                  textOverflow: TextOverflow.ellipsis,
                  maxLine: 1,
                  showShadow: true,
                  shadowElevation: 2,
                  kBottomRadius: 24,
                  notchColor: AppColors.burgundy,
                  removeMargins: false,
                  bottomBarWidth: barWidth,
                  durationInMilliSeconds: 300,
                  itemLabelStyle: AppTextStyles.navLabel,
                  elevation: 0,
                  kIconSize: 24,
                  bottomBarItems: [
                    for (var i = 0; i < _items.length; i++)
                      BottomBarItem(
                        inActiveItem: _NavIcon(
                          asset: _items[i].asset,
                          color: AppColors.textMuted,
                          badgeCount: switch (i) {
                            1 => wishlistCount,
                            2 => cartCount,
                            _ => null,
                          },
                        ),
                        activeItem: _NavIcon(
                          asset: _items[i].asset,
                          color: Colors.white,
                          badgeCount: switch (i) {
                            1 => wishlistCount,
                            2 => cartCount,
                            _ => null,
                          },
                          onBurgundy: true,
                        ),
                        itemLabel: _items[i].label,
                      ),
                  ],
                  onTap: widget.onTap,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.asset,
    required this.color,
    this.badgeCount,
    this.onBurgundy = false,
  });

  final String asset;
  final Color color;
  final int? badgeCount;
  final bool onBurgundy;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Image.asset(
      asset,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      color: color,
      colorBlendMode: BlendMode.srcIn,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => Icon(
        Icons.image_not_supported_outlined,
        color: color,
        size: 24,
      ),
    );

    if (badgeCount == null || badgeCount! <= 0) return iconWidget;

    return Badge(
      label: Text(
        '$badgeCount',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
      ),
      backgroundColor: onBurgundy ? Colors.white : AppColors.burgundy,
      textColor: onBurgundy ? AppColors.burgundy : Colors.white,
      smallSize: 16,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      offset: const Offset(6, -4),
      child: iconWidget,
    );
  }
}

int bottomNavIndexForLocation(String location) {
  if (location.startsWith('/wishlist')) return 1;
  if (location.startsWith('/category')) return 0;
  if (location.startsWith('/cart')) return 2;
  if (location.startsWith('/profile')) return 3;
  return 0;
}

void navigateToBottomNavTab(BuildContext context, int index) {
  switch (index) {
    case 0:
      context.go(AppRoutes.home);
    case 1:
      context.go(AppRoutes.wishlist);
    case 2:
      context.go(AppRoutes.cart);
    case 3:
      context.go(AppRoutes.profile);
  }
}
