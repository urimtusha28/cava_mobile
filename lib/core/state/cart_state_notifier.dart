import 'package:flutter/foundation.dart';

/// Notifies listeners when cart contents or count change.
abstract final class CartStateNotifier {
  static final ValueNotifier<int> revision = ValueNotifier(0);

  static void update(int itemCount) {
    revision.value = itemCount;
  }
}
