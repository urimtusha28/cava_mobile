import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../utils/animation_utils.dart';

/// Maps the 4.5s loop progress [0, 1] to handoff animation values.
abstract final class HandoffTimeline {
  static const double holdEnd = 0.56;
  static const double receiveEnd = 0.72;
  static const double bounceEnd = 0.84;

  static double _t(double t) => safeUnit(t);

  static double handoffExtend(double t) {
    return safeCurve(Curves.easeInOutCubic, _t(t), 0.15, 0.45);
  }

  static double receiveTransfer(double t) {
    return safeCurve(Curves.easeInOutCubic, _t(t), holdEnd, receiveEnd);
  }

  static double bouncePhase(double t) {
    return safeCurve(Curves.easeInOutCubic, _t(t), receiveEnd, bounceEnd);
  }

  static double bagXFactor(double t) {
    final normalized = _t(t);
    final extend = handoffExtend(normalized);
    final receive = receiveTransfer(normalized);
    const assistantX = 0.68;
    const centerX = 0.50;
    const customerX = 0.32;
    if (receive > 0) {
      return centerX + (customerX - centerX) * receive;
    }
    return assistantX + (centerX - assistantX) * extend;
  }

  static double bagSwingRadians(double t) {
    final normalized = _t(t);
    final extend = handoffExtend(normalized);
    final receive = receiveTransfer(normalized);
    final bounce = bouncePhase(normalized);
    final moveSwing = math.sin(safeUnit(extend) * math.pi) * 0.035;
    final receiveSwing = math.sin(safeUnit(receive) * math.pi) * 0.02;
    final bounceRot = math.sin(safeUnit(bounce) * math.pi) * 0.03;
    return moveSwing + receiveSwing + bounceRot;
  }

  static double bagBounceY(double t, double scale) {
    final bounce = bouncePhase(_t(t));
    if (bounce <= 0) return 0;
    return -math.sin(safeUnit(bounce) * math.pi) * 3.5 * scale;
  }

  static double assistantArmAngle(double t) {
    final extend = handoffExtend(_t(t));
    return -18 - extend * 28;
  }

  static double customerArmAngle(double t) {
    final normalized = _t(t);
    final extend = handoffExtend(normalized);
    final receive = receiveTransfer(normalized);
    return 14 + extend * 24 + receive * 8;
  }

  static double customerHeadNod(double t) {
    final receive = receiveTransfer(_t(t));
    return math.sin(safeUnit(receive) * math.pi) * 0.05;
  }

  static double glowOpacity(double t) {
    final normalized = _t(t);
    if (normalized < 0.30 || normalized > 0.62) return 0;
    if (normalized < 0.42) {
      return safeCurve(Curves.easeOut, normalized, 0.30, 0.42) * 0.45;
    }
    return (1 - safeCurve(Curves.easeIn, normalized, 0.42, 0.62)) * 0.45;
  }

  static double checkOpacity(double t) {
    final normalized = _t(t);
    if (normalized < 0.48 || normalized > 0.60) return 0;
    if (normalized < 0.52) {
      return safeCurve(Curves.easeOut, normalized, 0.48, 0.52);
    }
    return 1 - safeCurve(Curves.easeIn, normalized, 0.52, 0.60);
  }
}
