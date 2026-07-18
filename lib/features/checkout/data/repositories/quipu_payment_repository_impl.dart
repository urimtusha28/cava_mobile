import '../../domain/entities/quipu_payment_entities.dart';
import '../../domain/repositories/quipu_payment_repository.dart';
import '../datasources/quipu_payment_data_source.dart';

class QuipuPaymentRepositoryImpl implements QuipuPaymentRepository {
  QuipuPaymentRepositoryImpl(this._dataSource);

  final QuipuPaymentDataSource _dataSource;

  @override
  Future<QuipuInitiateResultEntity> initiatePayment({
    required String cavaOrderId,
    String? language,
  }) {
    return _dataSource.initiatePayment(
      cavaOrderId: cavaOrderId,
      language: language,
    );
  }

  @override
  Future<QuipuVerifyResultEntity> verifyPayment(String transactionId) {
    return _dataSource.verifyPayment(transactionId);
  }
}
