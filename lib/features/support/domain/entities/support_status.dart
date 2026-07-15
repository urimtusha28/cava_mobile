import 'package:cava_ecommerce/l10n/app_localizations.dart';

enum SupportStatus {
  open,
  pending,
  resolved,
  closed;

  static SupportStatus fromString(String? raw) {
    return switch ((raw ?? '').trim().toLowerCase()) {
      'open' => SupportStatus.open,
      'pending' => SupportStatus.pending,
      'resolved' => SupportStatus.resolved,
      'closed' => SupportStatus.closed,
      _ => SupportStatus.open,
    };
  }

  String get firestoreValue => name;

  String labelOf(AppLocalizations l10n) => switch (this) {
        SupportStatus.open => l10n.supportStatusOpen,
        SupportStatus.pending => l10n.supportStatusPending,
        SupportStatus.resolved => l10n.supportStatusResolved,
        SupportStatus.closed => l10n.supportStatusClosed,
      };
}
