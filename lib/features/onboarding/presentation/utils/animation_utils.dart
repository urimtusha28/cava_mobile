import 'package:flutter/material.dart';

/// Clamps linear progress into [0, 1] before passing to curves or tweens.
double safeProgress(double value, double start, double end) {
  if (end <= start) return 0.0;
  final progress = (value - start) / (end - start);
  return progress.clamp(0.0, 1.0);
}

/// Applies a curve only after [safeProgress] normalization.
double safeCurve(Curve curve, double value, double start, double end) {
  return curve.transform(safeProgress(value, start, end));
}

/// Clamps any scalar animation input/output to [0, 1].
double safeUnit(double value) => value.clamp(0.0, 1.0);

/// Clamps UI scale values to a safe visible range.
double safeScaleValue(double value) => value.clamp(0.85, 1.15);
