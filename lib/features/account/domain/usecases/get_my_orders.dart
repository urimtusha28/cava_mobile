import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../repositories/orders_repository.dart';
import '../entities/order_entity.dart';

class GetMyOrdersUseCase extends BaseUseCaseNoParams<List<OrderEntity>> {
  GetMyOrdersUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Result<List<OrderEntity>>> call() {
    return guard(_repository.getMyOrders);
  }
}
