import '../../domain/entities/quipu_payment_entities.dart';

abstract class QuipuPaymentDataSource {
  Future<QuipuInitiateResultEntity> initiatePayment({
    required String cavaOrderId,
    String? language,
  });

  Future<QuipuVerifyResultEntity> verifyPayment(String transactionId);
}
