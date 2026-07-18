import 'package:cava_ecommerce/features/checkout/domain/entities/quipu_payment_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuipuInitiateResultEntity', () {
    test('fromMap parses fields and validates required values', () {
      final entity = QuipuInitiateResultEntity.fromMap(const {
        'redirectUrl': 'https://hpp.example/pay?id=q1&password=p',
        'quipuOrderId': 'q1',
        'status': 'redirect_issued',
        'transactionId': 'tx-1',
      });

      expect(entity.redirectUrl, contains('https://hpp.example/pay'));
      expect(entity.quipuOrderId, 'q1');
      expect(entity.transactionId, 'tx-1');
      expect(entity.isValid, isTrue);
    });

    test('isValid is false without redirectUrl or transactionId', () {
      expect(
        QuipuInitiateResultEntity.fromMap(const {'quipuOrderId': 'q1'}).isValid,
        isFalse,
      );
      expect(
        QuipuInitiateResultEntity.fromMap(const {
          'redirectUrl': 'https://hpp.example',
        }).isValid,
        isFalse,
      );
    });
  });

  group('QuipuVerifyResultEntity.status', () {
    QuipuVerifyResultEntity build({
      bool verifiedPaid = false,
      String? gatewayStatus,
    }) {
      return QuipuVerifyResultEntity(
        transactionId: 'tx-1',
        cavaOrderId: 'order-1',
        gatewayStatus: gatewayStatus,
        verifiedPaid: verifiedPaid,
      );
    }

    test('verifiedPaid always wins as paid', () {
      expect(
        build(verifiedPaid: true, gatewayStatus: 'paid').status,
        CardPaymentStatus.paid,
      );
    });

    test('never paid without verifiedPaid, even if gateway says paid', () {
      // Redirect/success text alone must never be treated as final proof.
      expect(build(gatewayStatus: 'paid').status, CardPaymentStatus.pending);
    });

    test('cancelled statuses map to cancelled', () {
      expect(
        build(gatewayStatus: 'cancelled').status,
        CardPaymentStatus.cancelled,
      );
      expect(
        build(gatewayStatus: 'CANCELED_BY_USER').status,
        CardPaymentStatus.cancelled,
      );
    });

    test('expired statuses map to expired', () {
      expect(build(gatewayStatus: 'expired').status, CardPaymentStatus.expired);
      expect(build(gatewayStatus: 'timeout').status, CardPaymentStatus.expired);
    });

    test('failed statuses map to failed', () {
      expect(build(gatewayStatus: 'failed').status, CardPaymentStatus.failed);
      expect(build(gatewayStatus: 'declined').status, CardPaymentStatus.failed);
      expect(build(gatewayStatus: 'rejected').status, CardPaymentStatus.failed);
    });

    test('unknown or missing status stays pending (conservative)', () {
      expect(build(gatewayStatus: null).status, CardPaymentStatus.pending);
      expect(build(gatewayStatus: 'created').status, CardPaymentStatus.pending);
      expect(
        build(gatewayStatus: 'weird_new_status').status,
        CardPaymentStatus.pending,
      );
    });
  });

  group('PendingCardPayment', () {
    test('round-trips through map', () {
      const payment = PendingCardPayment(
        orderId: 'order-1',
        transactionId: 'tx-1',
        orderNumber: 'CP-1001',
        total: 57.5,
        createdAtMillis: 1234,
      );

      final restored = PendingCardPayment.fromMap(payment.toMap());

      expect(restored, isNotNull);
      expect(restored!.orderId, 'order-1');
      expect(restored.transactionId, 'tx-1');
      expect(restored.orderNumber, 'CP-1001');
      expect(restored.total, 57.5);
      expect(restored.createdAtMillis, 1234);
    });

    test('fromMap returns null without required ids', () {
      expect(PendingCardPayment.fromMap(const {'orderId': 'o'}), isNull);
      expect(PendingCardPayment.fromMap(const {'transactionId': 't'}), isNull);
    });
  });
}
