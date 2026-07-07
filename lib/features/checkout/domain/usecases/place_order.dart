import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/place_order_result_entity.dart';
import '../repositories/checkout_repository.dart';

class PlaceOrderUseCase extends BaseUseCase<PlaceOrderResultEntity, PlaceOrderRequest> {
  PlaceOrderUseCase(this._repository);

  final CheckoutRepository _repository;

  @override
  Future<Result<PlaceOrderResultEntity>> call(PlaceOrderRequest params) {
    return guard(() => _repository.placeOrder(params));
  }
}
