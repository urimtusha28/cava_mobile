import 'package:flutter/foundation.dart';

/// Notifies listeners when wishlist contents or count change.
abstract final class WishlistStateNotifier {
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static void update(int itemCount) {
    revision.value = itemCount;
  }

  /// Resets badge state — call from [resetDependencies] in tests.
  static void reset() {
    revision.value = 0;
  }
}
