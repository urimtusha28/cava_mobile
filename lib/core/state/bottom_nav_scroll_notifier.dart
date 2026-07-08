import 'package:flutter/foundation.dart';

/// Tracks how compact the shell bottom navigation should appear.
///
/// [compactness] is `0` (full size) … `1` (max subtle shrink).
abstract final class BottomNavScrollNotifier {
  static final ValueNotifier<double> compactness = ValueNotifier(0);

  /// Accumulates deltas until this magnitude is reached (avoids jitter).
  static const double scrollThresholdPx = 8;

  /// How many pixels of net scroll move compactness from 0 → 1.
  static const double pixelsToFullCompact = 120;

  static double _accumulatedDelta = 0;

  static void reportScrollDelta(double dy) {
    if (dy == 0) {
      return;
    }

    _accumulatedDelta += dy;
    if (_accumulatedDelta.abs() < scrollThresholdPx) {
      return;
    }

    final next =
        (compactness.value + (_accumulatedDelta / pixelsToFullCompact))
            .clamp(0.0, 1.0);
    _accumulatedDelta = 0;
    if (next != compactness.value) {
      compactness.value = next;
    }
  }

  /// Restores the bar to full size (e.g. when switching tabs).
  static void expand() {
    _accumulatedDelta = 0;
    if (compactness.value != 0) {
      compactness.value = 0;
    }
  }

  /// Resets state — call from [resetDependencies] in tests.
  static void reset() {
    _accumulatedDelta = 0;
    compactness.value = 0;
  }
}
