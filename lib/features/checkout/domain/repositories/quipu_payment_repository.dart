import '../entities/quipu_payment_entities.dart';

/// Backend-driven Quipu HPP payment. The mobile app never touches card data or
/// Quipu secrets: it only asks the backend for a redirect URL and later asks
/// the backend to verify the real payment status against Quipu.
abstract class QuipuPaymentRepository {
  /// Creates (or reuses, idempotently on the server) a Quipu payment session
  /// for an existing pending Cava order and returns the HPP redirect URL.
  Future<QuipuInitiateResultEntity> initiatePayment({
    required String cavaOrderId,
    String? language,
  });

  /// Server-authoritative verification of a transaction. Only the backend can
  /// promote the order to paid.
  Future<QuipuVerifyResultEntity> verifyPayment(String transactionId);
}
