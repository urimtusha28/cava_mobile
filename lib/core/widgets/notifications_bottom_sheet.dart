import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_bottom_sheet.dart';

Future<void> showNotificationsBottomSheet(BuildContext context) {
  return showAppBottomSheet(
    context: context,
    title: 'Njoftimet',
    subtitle: '3 të reja sot',
    headerIcon: Icons.notifications_none_rounded,
    child: Column(
      children: [
        for (final item in _notifications)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: SheetActionCard(
              icon: item.icon,
              title: item.title,
              subtitle: item.body,
              highlighted: item.unread,
              trailing: item.unread
                  ? Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.burgundy,
                        shape: BoxShape.circle,
                      ),
                    )
                  : Text(item.time, style: AppTextStyles.caption),
            ),
          ),
      ],
    ),
  );
}

class _NotificationItem {
  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;
}

const _notifications = [
  _NotificationItem(
    icon: Icons.local_shipping_outlined,
    title: 'Porosia është në rrugëtim',
    body: 'Porosia #CP-2024-01568 do të arrijë brenda 1-2 ditëve.',
    time: '10:32',
    unread: true,
  ),
  _NotificationItem(
    icon: Icons.local_offer_outlined,
    title: 'Ofertë e re',
    body: 'Zbritje 15% për verërat italiane këtë javë.',
    time: 'Dje',
    unread: true,
  ),
  _NotificationItem(
    icon: Icons.shopping_bag_outlined,
    title: 'Kujtesë shporte',
    body: 'Keni produkte në shportë. Përfundoni blerjen!',
    time: 'Mar',
    unread: true,
  ),
  _NotificationItem(
    icon: Icons.check_circle_outline,
    title: 'Porosi e përfunduar',
    body: 'Faleminderit! Porosia #CP-2024-01311 u dorëzua me sukses.',
    time: '28 Shk',
  ),
];
