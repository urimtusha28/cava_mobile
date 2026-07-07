import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../../account/domain/usecases/get_order_by_id.dart';
import '../../domain/entities/place_order_result_entity.dart';

class OrderSuccessController extends BaseController {
  OrderSuccessController(this._getOrderById);

  final GetOrderByIdUseCase _getOrderById;

  PlaceOrderResultEntity? result;

  Future<void> load(PlaceOrderResultEntity? initialResult) async {
    await runLoad(() async {
      result = initialResult;
      if (_hasCompleteResult(result)) {
        return;
      }

      final orderId = initialResult?.orderId;
      if (orderId == null || orderId.isEmpty) {
        return;
      }

      final order = await unwrapFutureResult(
        _getOrderById(GetOrderByIdParams(orderId: orderId)),
        fallback: null,
      );

      if (order == null) {
        return;
      }

      result = PlaceOrderResultEntity(
        orderId: order.id,
        orderNumber: order.orderNumber,
        total: order.total,
        paymentMethod: initialResult?.paymentMethod ?? 'cash',
      );
    });
  }

  bool _hasCompleteResult(PlaceOrderResultEntity? value) {
    if (value == null) {
      return false;
    }
    return value.total > 0 &&
        (value.orderNumber?.trim().isNotEmpty ?? false);
  }
}

OrderSuccessController createOrderSuccessController() {
  configureDependencies();
  return sl<OrderSuccessController>();
}

String paymentMethodLabel(String method) {
  return switch (method) {
    'cash' => 'Para në dorë',
    'card' => 'Kartë',
    'bank' => 'Transfer bankar',
    _ => method,
  };
}
