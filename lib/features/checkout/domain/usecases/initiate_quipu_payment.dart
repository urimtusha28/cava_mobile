import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/quipu_payment_entities.dart';
import '../repositories/quipu_payment_repository.dart';

class InitiateQuipuPaymentParams {
  const InitiateQuipuPaymentParams({
    required this.cavaOrderId,
    this.language,
  });

  final String cavaOrderId;
  final String? language;
}

class InitiateQuipuPaymentUseCase
    extends BaseUseCase<QuipuInitiateResultEntity, InitiateQuipuPaymentParams> {
  InitiateQuipuPaymentUseCase(this._repository);

  final QuipuPaymentRepository _repository;

  @override
  Future<Result<QuipuInitiateResultEntity>> call(
    InitiateQuipuPaymentParams params,
  ) {
    return guard(
      () => _repository.initiatePayment(
        cavaOrderId: params.cavaOrderId,
        language: params.language,
      ),
    );
  }
}
