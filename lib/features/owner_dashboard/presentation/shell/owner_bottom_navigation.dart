import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../support/presentation/controllers/admin_support_unread_notifier.dart';

/// Owner-only bottom navigation (separate from customer [BottomNavigation]).
class OwnerBottomNavigation extends StatelessWidget {
  const OwnerBottomNavigation({
    super.key,
    required this.currentIndex,
  });

  final int currentIndex;

  static const _itemIcons = [
    (icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard),
    (icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long),
    (icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart),
    (icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2),
    (icon: Icons.support_agent_rounded, activeIcon: Icons.support_agent_rounded),
    (icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.ownerNavDashboard,
      l10n.ownerNavOrders,
      l10n.ownerNavAnalytics,
      l10n.ownerNavProducts,
      l10n.ownerNavSupport,
      l10n.ownerNavProfile,
    ];
    ensureAdminSupportBadgeListening();
    final badgeNotifier = sl.isRegistered<AdminSupportUnreadNotifier>()
        ? sl<AdminSupportUnreadNotifier>()
        : null;

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
            for (var i = 0; i < _itemIcons.length; i++)
              Expanded(
                child: badgeNotifier != null && i == 4
                    ? ListenableBuilder(
                        listenable: badgeNotifier,
                        builder: (context, _) {
                          return _OwnerNavItem(
                            icon: currentIndex == i
                                ? _itemIcons[i].activeIcon
                                : _itemIcons[i].icon,
                            label: labels[i],
                            selected: currentIndex == i,
                            badgeCount: badgeNotifier.unreadCount,
                            onTap: () => _navigate(context, i),
                          );
                        },
                      )
                    : _OwnerNavItem(
                        icon: currentIndex == i
                            ? _itemIcons[i].activeIcon
                            : _itemIcons[i].icon,
                        label: labels[i],
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
        context.go(AppRoutes.ownerSupport);
      case 5:
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
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

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
              child: Badge(
                isLabelVisible: badgeCount > 0,
                backgroundColor: AppColors.burgundy,
                label: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: selected ? Colors.white : color,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.navLabel.copyWith(
                color: color,
                fontSize: 9,
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
  if (location.startsWith(AppRoutes.ownerSupport)) return 4;
  if (location.startsWith(AppRoutes.ownerProfile)) return 5;
  return 0;
}
