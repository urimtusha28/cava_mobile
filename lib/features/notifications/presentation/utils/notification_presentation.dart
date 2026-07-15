import 'package:flutter/material.dart';

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

  /// Albanian short relative date: "10:32", "Dje", "28 Shk".
  static String formatRelativeDate(DateTime date, {DateTime? now}) {
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
      return 'Dje';
    }
    if (diffDays < 7 && diffDays > 1) {
      return _weekdayShort(local.weekday);
    }
    return '${local.day} ${_monthShort(local.month)}';
  }

  static bool isToday(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final local = date.toLocal();
    return local.year == current.year &&
        local.month == current.month &&
        local.day == current.day;
  }

  static String _weekdayShort(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Hën',
      DateTime.tuesday => 'Mar',
      DateTime.wednesday => 'Mër',
      DateTime.thursday => 'Enj',
      DateTime.friday => 'Pre',
      DateTime.saturday => 'Sht',
      DateTime.sunday => 'Die',
      _ => '',
    };
  }

  static String _monthShort(int month) {
    return switch (month) {
      1 => 'Jan',
      2 => 'Shk',
      3 => 'Mar',
      4 => 'Pri',
      5 => 'Maj',
      6 => 'Qer',
      7 => 'Kor',
      8 => 'Gus',
      9 => 'Sht',
      10 => 'Tet',
      11 => 'Nën',
      12 => 'Dhj',
      _ => '',
    };
  }
}
