import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

class GetOrderByIdForAdminParams {
  const GetOrderByIdForAdminParams({required this.orderId});

  final String orderId;
}

class GetOrderByIdForAdminUseCase
    extends BaseUseCase<OrderEntity?, GetOrderByIdForAdminParams> {
  GetOrderByIdForAdminUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Result<OrderEntity?>> call(GetOrderByIdForAdminParams params) {
    return guard(() => _repository.getOrderByIdForAdmin(params.orderId));
  }
}
