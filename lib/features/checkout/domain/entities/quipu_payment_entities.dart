/// Card payment states surfaced to the UI after Quipu verification.
///
/// `paid` is set ONLY when the backend (`verifyQuipuPayment`) confirms the
/// payment against Quipu's server (server-authoritative). All other states are
/// derived from the gateway status string and are never treated as final
/// success.
enum CardPaymentStatus { paid, pending, failed, cancelled, expired }

/// Result of the `initiateQuipuPayment` callable: the hosted payment page
/// redirect URL plus the server-side transaction id used for verification.
class QuipuInitiateResultEntity {
  const QuipuInitiateResultEntity({
    required this.redirectUrl,
    required this.quipuOrderId,
    required this.status,
    required this.transactionId,
  });

  final String redirectUrl;
  final String quipuOrderId;
  final String status;
  final String transactionId;

  factory QuipuInitiateResultEntity.fromMap(Map<String, dynamic> map) {
    return QuipuInitiateResultEntity(
      redirectUrl: (map['redirectUrl'] ?? '').toString(),
      quipuOrderId: (map['quipuOrderId'] ?? '').toString(),
      status: (map['status'] ?? '').toString(),
      transactionId: (map['transactionId'] ?? '').toString(),
    );
  }

  bool get isValid => redirectUrl.isNotEmpty && transactionId.isNotEmpty;
}

/// Result of the `verifyQuipuPayment` callable.
///
/// `verifiedPaid` mirrors the backend flag and is the single source of truth
/// for success — the HPP redirect alone is never trusted.
class QuipuVerifyResultEntity {
  const QuipuVerifyResultEntity({
    required this.transactionId,
    required this.cavaOrderId,
    required this.gatewayStatus,
    required this.verifiedPaid,
  });

  final String transactionId;
  final String cavaOrderId;
  final String? gatewayStatus;
  final bool verifiedPaid;

  factory QuipuVerifyResultEntity.fromMap(Map<String, dynamic> map) {
    final rawStatus = map['gatewayStatus'];
    return QuipuVerifyResultEntity(
      transactionId: (map['transactionId'] ?? '').toString(),
      cavaOrderId: (map['cavaOrderId'] ?? '').toString(),
      gatewayStatus: rawStatus?.toString(),
      verifiedPaid: map['verifiedPaid'] == true,
    );
  }

  /// Maps the backend outcome to a UI state. Conservative: anything not
  /// explicitly recognized stays `pending` so the order is never shown as
  /// failed/expired without evidence from the gateway status.
  CardPaymentStatus get status {
    if (verifiedPaid) {
      return CardPaymentStatus.paid;
    }
    final s = (gatewayStatus ?? '').toLowerCase();
    if (s.contains('cancel') || s.contains('abort') || s.contains('void')) {
      return CardPaymentStatus.cancelled;
    }
    if (s.contains('expire') || s.contains('timeout')) {
      return CardPaymentStatus.expired;
    }
    if (s.contains('fail') ||
        s.contains('decline') ||
        s.contains('reject') ||
        s.contains('error')) {
      return CardPaymentStatus.failed;
    }
    return CardPaymentStatus.pending;
  }
}

/// Locally persisted in-flight card payment (order placed, HPP opened, not yet
/// verified). Lets the app resume verification after being backgrounded or
/// restarted, and prevents starting a duplicate payment for the same order.
class PendingCardPayment {
  const PendingCardPayment({
    required this.orderId,
    required this.transactionId,
    this.orderNumber,
    this.total,
    this.createdAtMillis,
  });

  final String orderId;
  final String transactionId;
  final String? orderNumber;
  final double? total;
  final int? createdAtMillis;

  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'transactionId': transactionId,
    if (orderNumber != null) 'orderNumber': orderNumber,
    if (total != null) 'total': total,
    if (createdAtMillis != null) 'createdAtMillis': createdAtMillis,
  };

  static PendingCardPayment? fromMap(Map<String, dynamic> map) {
    final orderId = (map['orderId'] ?? '').toString();
    final transactionId = (map['transactionId'] ?? '').toString();
    if (orderId.isEmpty || transactionId.isEmpty) {
      return null;
    }
    final rawTotal = map['total'];
    final rawCreatedAt = map['createdAtMillis'];
    return PendingCardPayment(
      orderId: orderId,
      transactionId: transactionId,
      orderNumber: map['orderNumber']?.toString(),
      total: rawTotal is num
          ? rawTotal.toDouble()
          : double.tryParse('$rawTotal'),
      createdAtMillis: rawCreatedAt is num ? rawCreatedAt.toInt() : null,
    );
  }
}
