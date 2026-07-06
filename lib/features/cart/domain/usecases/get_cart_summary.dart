import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/cart_summary_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartSummaryUseCase extends BaseUseCaseNoParams<CartSummaryEntity> {
  GetCartSummaryUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<Result<CartSummaryEntity>> call() {
    return guard(_repository.getSummary);
  }
}
