import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';

/// Owner-only bottom navigation (separate from customer [BottomNavigation]).
class OwnerBottomNavigation extends StatelessWidget {
  const OwnerBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  static const _items = [
    (icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    (icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Porositë'),
    (icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Analitika'),
    (icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Produktet'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profili'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        0,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: _OwnerNavItem(
                  icon: currentIndex == i
                      ? _items[i].activeIcon
                      : _items[i].icon,
                  label: _items[i].label,
                  selected: currentIndex == i,
                  onTap: () => _navigate(context, i),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.ownerDashboard);
      case 1:
        context.go(AppRoutes.ownerOrders);
      case 2:
        context.go(AppRoutes.ownerAnalytics);
      case 3:
        context.go(AppRoutes.ownerProducts);
      case 4:
        context.go(AppRoutes.ownerProfile);
    }
  }
}

class _OwnerNavItem extends StatelessWidget {
  const _OwnerNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.burgundy : AppColors.textMuted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: selected ? AppColors.burgundy : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected ? Colors.white : color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.navLabel.copyWith(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

int ownerNavIndexForLocation(String location) {
  if (location.startsWith(AppRoutes.ownerOrders)) return 1;
  if (location.startsWith(AppRoutes.ownerAnalytics)) return 2;
  if (location.startsWith(AppRoutes.ownerProducts)) return 3;
  if (location.startsWith(AppRoutes.ownerProfile)) return 4;
  return 0;
}
