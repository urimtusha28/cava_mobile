import 'package:cava_ecommerce/l10n/app_localizations.dart';

/// Maps raw fulfillment status codes (from Firestore) to localized labels.
abstract final class OwnerOrderStatusL10n {
  static String labelOf(AppLocalizations l10n, String raw) {
    return switch (raw) {
      'received' => l10n.ownerFulfillmentReceived,
      'confirmed' => l10n.ownerFulfillmentConfirmed,
      'prepared' => l10n.ownerFulfillmentPrepared,
      'shipped' => l10n.ownerFulfillmentShipped,
      'in_transit' => l10n.ownerFulfillmentInTransit,
      'delivered' || 'Fulfilled' => l10n.ownerFulfillmentDelivered,
      'returned' => l10n.ownerFulfillmentReturned,
      'canceled' => l10n.ownerFulfillmentCanceled,
      'Unfulfilled' => l10n.ownerFulfillmentUnfulfilled,
      _ => raw.isEmpty ? l10n.emDash : raw,
    };
  }
}
