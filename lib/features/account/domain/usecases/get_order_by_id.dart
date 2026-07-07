import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderByIdParams {
  const GetOrderByIdParams({required this.orderId});

  final String orderId;
}

class GetOrderByIdUseCase extends BaseUseCase<OrderEntity?, GetOrderByIdParams> {
  GetOrderByIdUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Result<OrderEntity?>> call(GetOrderByIdParams params) {
    return guard(() => _repository.getOrderById(params.orderId));
  }
}
