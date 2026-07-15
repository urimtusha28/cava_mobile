import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../domain/entities/notification_type.dart';

abstract final class NotificationPresentation {
  static IconData iconForType(NotificationType type) {
    return switch (type) {
      NotificationType.orderPlaced ||
      NotificationType.orderConfirmed ||
      NotificationType.orderProcessing =>
        Icons.shopping_bag_outlined,
      NotificationType.orderShipped => Icons.local_shipping_outlined,
      NotificationType.orderDelivered => Icons.check_circle_outline,
      NotificationType.orderCancelled => Icons.cancel_outlined,
      NotificationType.paymentUpdated => Icons.payments_outlined,
      NotificationType.promotion => Icons.local_offer_outlined,
      NotificationType.cartReminder => Icons.shopping_cart_outlined,
      NotificationType.supportReply => Icons.support_agent_rounded,
      NotificationType.general => Icons.notifications_none_rounded,
    };
  }

  /// Short relative date: "10:32", yesterday, weekday, or "28 Feb".
  static String formatRelativeDate(
    DateTime date,
    AppLocalizations l10n, {
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    final local = date.toLocal();
    final today = DateTime(current.year, current.month, current.day);
    final target = DateTime(local.year, local.month, local.day);
    final diffDays = today.difference(target).inDays;

    if (diffDays == 0) {
      final h = local.hour.toString().padLeft(2, '0');
      final m = local.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    if (diffDays == 1) {
      return l10n.relativeYesterday;
    }
    if (diffDays < 7 && diffDays > 1) {
      return _weekdayShort(l10n, local.weekday);
    }
    return '${local.day} ${_monthShort(l10n, local.month)}';
  }

  static bool isToday(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final local = date.toLocal();
    return local.year == current.year &&
        local.month == current.month &&
        local.day == current.day;
  }

  static String _weekdayShort(AppLocalizations l10n, int weekday) {
    return switch (weekday) {
      DateTime.monday => l10n.weekdayMon,
      DateTime.tuesday => l10n.weekdayTue,
      DateTime.wednesday => l10n.weekdayWed,
      DateTime.thursday => l10n.weekdayThu,
      DateTime.friday => l10n.weekdayFri,
      DateTime.saturday => l10n.weekdaySat,
      DateTime.sunday => l10n.weekdaySun,
      _ => '',
    };
  }

  static String _monthShort(AppLocalizations l10n, int month) {
    return switch (month) {
      1 => l10n.monthJan,
      2 => l10n.monthFeb,
      3 => l10n.monthMar,
      4 => l10n.monthApr,
      5 => l10n.monthMay,
      6 => l10n.monthJun,
      7 => l10n.monthJul,
      8 => l10n.monthAug,
      9 => l10n.monthSep,
      10 => l10n.monthOct,
      11 => l10n.monthNov,
      12 => l10n.monthDec,
      _ => '',
    };
  }
}
