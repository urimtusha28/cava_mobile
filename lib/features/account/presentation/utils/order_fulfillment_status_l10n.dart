import 'package:cava_ecommerce/l10n/app_localizations.dart';

import '../../domain/entities/order_fulfillment_status.dart';

abstract final class OrderFulfillmentStatusL10n {
  static String labelOfRaw(AppLocalizations l10n, String raw) {
    final normalized = raw.trim().toLowerCase();
    return switch (normalized) {
      'received' => l10n.orderFulfillmentReceived,
      'confirmed' => l10n.orderFulfillmentConfirmed,
      'prepared' => l10n.orderFulfillmentPrepared,
      'shipped' => l10n.orderFulfillmentShipped,
      'in_transit' => l10n.orderFulfillmentInTransit,
      'delivered' => l10n.orderFulfillmentDelivered,
      'returned' => l10n.orderFulfillmentReturned,
      'canceled' || 'cancelled' => l10n.orderFulfillmentCanceled,
      'fulfilled' || 'completed' => l10n.orderFulfillmentDelivered,
      'open' => l10n.orderFulfillmentReceived,
      _ => raw.isEmpty ? l10n.emDash : raw,
    };
  }

  static String labelOf(AppLocalizations l10n, FulfillmentStatusDetail status) =>
      labelOfRaw(l10n, status.rawValue);
}
