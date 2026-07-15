/// Types of in-app notifications.
enum NotificationType {
  orderPlaced,
  orderConfirmed,
  orderProcessing,
  orderShipped,
  orderDelivered,
  orderCancelled,
  paymentUpdated,
  promotion,
  cartReminder,
  supportReply,
  general;

  static NotificationType fromString(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return NotificationType.general;
    }
    final normalized = raw.trim().toLowerCase().replaceAll('-', '_');
    return switch (normalized) {
      'orderplaced' || 'order_placed' => NotificationType.orderPlaced,
      'orderconfirmed' || 'order_confirmed' => NotificationType.orderConfirmed,
      'orderprocessing' || 'order_processing' => NotificationType.orderProcessing,
      'ordershipped' || 'order_shipped' => NotificationType.orderShipped,
      'orderdelivered' || 'order_delivered' => NotificationType.orderDelivered,
      'ordercancelled' || 'order_cancelled' => NotificationType.orderCancelled,
      'paymentupdated' || 'payment_updated' => NotificationType.paymentUpdated,
      'promotion' => NotificationType.promotion,
      'cartreminder' || 'cart_reminder' => NotificationType.cartReminder,
      'supportreply' || 'support_reply' => NotificationType.supportReply,
      'general' => NotificationType.general,
      _ => NotificationType.general,
    };
  }

  String get firestoreValue => switch (this) {
        NotificationType.orderPlaced => 'order_placed',
        NotificationType.orderConfirmed => 'order_confirmed',
        NotificationType.orderProcessing => 'order_processing',
        NotificationType.orderShipped => 'order_shipped',
        NotificationType.orderDelivered => 'order_delivered',
        NotificationType.orderCancelled => 'order_cancelled',
        NotificationType.paymentUpdated => 'payment_updated',
        NotificationType.promotion => 'promotion',
        NotificationType.cartReminder => 'cart_reminder',
        NotificationType.supportReply => 'support_reply',
        NotificationType.general => 'general',
      };
}
