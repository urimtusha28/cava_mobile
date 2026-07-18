import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/quipu_payment_entities.dart';
import '../repositories/quipu_payment_repository.dart';

class VerifyQuipuPaymentUseCase
    extends BaseUseCase<QuipuVerifyResultEntity, String> {
  VerifyQuipuPaymentUseCase(this._repository);

  final QuipuPaymentRepository _repository;

  @override
  Future<Result<QuipuVerifyResultEntity>> call(String transactionId) {
    return guard(() => _repository.verifyPayment(transactionId));
  }
}
