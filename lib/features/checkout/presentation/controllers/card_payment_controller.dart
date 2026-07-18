import 'package:flutter/foundation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../cart/domain/usecases/clear_cart.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../data/local/pending_card_payment_storage.dart';
import '../../domain/entities/place_order_result_entity.dart';
import '../../domain/entities/quipu_payment_entities.dart';
import '../../domain/usecases/initiate_quipu_payment.dart';
import '../../domain/usecases/verify_quipu_payment.dart';

/// UI phases of the card (Quipu HPP) payment flow.
enum CardPaymentPhase {
  /// Nothing started yet.
  idle,

  /// Calling `initiateQuipuPayment` on the backend.
  initiating,

  /// Redirect URL obtained; the hosted payment page is (or was) open in the
  /// browser and the app is waiting for the customer to come back.
  awaitingPayment,

  /// Calling `verifyQuipuPayment` on the backend.
  verifying,

  /// Backend confirmed the payment (verified_paid). Terminal success.
  paid,

  /// Verification ran but the gateway does not report the order as paid yet.
  pending,

  /// Gateway reported a failed/declined payment.
  failed,

  /// Gateway reported a cancelled payment.
  cancelled,

  /// Gateway reported an expired payment session.
  expired,

  /// Initiation or verification errored (network/backend). Retryable.
  error,
}

class CardPaymentController extends BaseController {
  CardPaymentController(
    this._initiatePayment,
    this._verifyPayment,
    this._clearCart,
    this._cartController,
    this._pendingStorage,
  );

  final InitiateQuipuPaymentUseCase _initiatePayment;
  final VerifyQuipuPaymentUseCase _verifyPayment;
  final ClearCartUseCase _clearCart;
  final CartController _cartController;
  final PendingCardPaymentStorage _pendingStorage;

  CardPaymentPhase phase = CardPaymentPhase.idle;
  PlaceOrderResultEntity? order;
  String? redirectUrl;
  String? transactionId;
  String? gatewayStatus;
  String? failureCode;

  bool _busy = false;
  bool _cartCleared = false;

  bool get isBusy => _busy;

  bool get isTerminalSuccess => phase == CardPaymentPhase.paid;

  bool get canVerify =>
      transactionId != null &&
      !_busy &&
      phase != CardPaymentPhase.paid &&
      phase != CardPaymentPhase.initiating;

  bool get canReopenPaymentPage =>
      redirectUrl != null &&
      !_busy &&
      (phase == CardPaymentPhase.awaitingPayment ||
          phase == CardPaymentPhase.pending ||
          phase == CardPaymentPhase.error);

  /// Starts the payment for a freshly placed pending card order. Returns the
  /// HPP redirect URL to open, or null on failure. Idempotent against double
  /// taps: while busy or already initiated, it returns the existing URL without
  /// calling the backend again (the backend additionally reuses the in-flight
  /// transaction per order).
  Future<String?> start(PlaceOrderResultEntity placedOrder) async {
    if (_busy) {
      return redirectUrl;
    }
    if (order?.orderId == placedOrder.orderId && redirectUrl != null) {
      return redirectUrl;
    }

    _busy = true;
    order = placedOrder;
    failureCode = null;
    phase = CardPaymentPhase.initiating;
    notifyListeners();

    try {
      final result = await _initiatePayment(
        InitiateQuipuPaymentParams(cavaOrderId: placedOrder.orderId),
      );

      return result.fold(
        onSuccess: (data) {
          redirectUrl = data.redirectUrl;
          transactionId = data.transactionId;
          phase = CardPaymentPhase.awaitingPayment;
          // Best-effort persistence for resume-after-restart; failure to
          // persist must not block the payment.
          _pendingStorage
              .write(
                PendingCardPayment(
                  orderId: placedOrder.orderId,
                  transactionId: data.transactionId,
                  orderNumber: placedOrder.orderNumber,
                  total: placedOrder.total,
                  createdAtMillis: DateTime.now().millisecondsSinceEpoch,
                ),
              )
              .catchError((Object e) => debugPrint('[Quipu] persist: $e'));
          return data.redirectUrl;
        },
        onFailure: (failure) {
          debugPrint(
            '[Quipu] initiate failure code=${failure.code} '
            'message=${failure.message}',
          );
          failureCode = failure.code;
          phase = CardPaymentPhase.error;
          return null;
        },
      );
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Restores an in-flight payment persisted before an app restart.
  Future<bool> restorePending() async {
    final pending = await _pendingStorage.read();
    if (pending == null) {
      return false;
    }
    order ??= PlaceOrderResultEntity(
      orderId: pending.orderId,
      orderNumber: pending.orderNumber,
      total: pending.total ?? 0,
      paymentMethod: 'stripe',
    );
    transactionId = pending.transactionId;
    if (phase == CardPaymentPhase.idle) {
      phase = CardPaymentPhase.awaitingPayment;
    }
    notifyListeners();
    return true;
  }

  /// Server-authoritative verification. The redirect/return is never trusted:
  /// only `verifiedPaid` from the backend promotes the flow to success, and
  /// only then is the cart cleared.
  Future<void> verifyNow() async {
    final txId = transactionId;
    if (txId == null || _busy || phase == CardPaymentPhase.paid) {
      return;
    }

    _busy = true;
    failureCode = null;
    phase = CardPaymentPhase.verifying;
    notifyListeners();

    try {
      final result = await _verifyPayment(txId);
      result.fold(
        onSuccess: (data) {
          gatewayStatus = data.gatewayStatus;
          switch (data.status) {
            case CardPaymentStatus.paid:
              phase = CardPaymentPhase.paid;
            case CardPaymentStatus.cancelled:
              phase = CardPaymentPhase.cancelled;
            case CardPaymentStatus.expired:
              phase = CardPaymentPhase.expired;
            case CardPaymentStatus.failed:
              phase = CardPaymentPhase.failed;
            case CardPaymentStatus.pending:
              phase = CardPaymentPhase.pending;
          }
        },
        onFailure: (failure) {
          debugPrint(
            '[Quipu] verify failure code=${failure.code} '
            'message=${failure.message}',
          );
          failureCode = failure.code;
          phase = CardPaymentPhase.error;
        },
      );

      if (phase == CardPaymentPhase.paid) {
        await _onVerifiedPaid();
      }
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Called by the screen when the app returns to the foreground while a
  /// payment is awaiting completion in the browser.
  Future<void> onAppResumed() async {
    if (phase == CardPaymentPhase.awaitingPayment && !_busy) {
      await verifyNow();
    }
  }

  /// The customer abandoned the flow (back navigation). The order remains
  /// PENDING on the server and the cart is intentionally kept.
  Future<void> abandon() async {
    // Keep pending storage so a later app start can still verify — the
    // webhook-equivalent (server verify + web return page) may still settle it.
  }

  Future<void> _onVerifiedPaid() async {
    await _pendingStorage.clear();
    if (_cartCleared) {
      return;
    }
    _cartCleared = true;
    // Payment is confirmed by the backend — only now clear the cart.
    await unwrapFutureResult(_clearCart(), fallback: null);
    await _cartController.load();
  }
}

CardPaymentController createCardPaymentController() {
  configureDependencies();
  return sl<CardPaymentController>();
}
