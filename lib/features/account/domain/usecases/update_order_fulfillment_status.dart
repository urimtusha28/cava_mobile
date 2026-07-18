import '../../../../core/result/result.dart';
import '../../../../core/usecase/base_usecase.dart';
import '../entities/order_entity.dart';
import '../entities/order_fulfillment_status.dart';
import '../repositories/orders_repository.dart';

class UpdateOrderFulfillmentStatusParams {
  const UpdateOrderFulfillmentStatusParams({
    required this.orderId,
    required this.newStatus,
    this.adminUid,
  });

  final String orderId;
  final FulfillmentStatusDetail newStatus;
  final String? adminUid;
}

class UpdateOrderFulfillmentStatusUseCase
    extends BaseUseCase<OrderEntity?, UpdateOrderFulfillmentStatusParams> {
  UpdateOrderFulfillmentStatusUseCase(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Result<OrderEntity?>> call(UpdateOrderFulfillmentStatusParams params) {
    return guard(() async {
      await _repository.updateOrderFulfillmentStatus(
        params.orderId,
        params.newStatus,
        adminUid: params.adminUid,
      );
      return _repository.getOrderByIdForAdmin(params.orderId);
    });
  }
}
