import '../../../../core/di/injection.dart';
import '../../../../core/presentation/base_controller.dart';
import '../../../../core/presentation/result_extensions.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/usecases/get_my_orders.dart';
import '../../domain/usecases/is_logged_in.dart';

class OrdersController extends BaseController {
  OrdersController(this._isLoggedIn, this._getMyOrders);

  final IsLoggedInUseCase _isLoggedIn;
  final GetMyOrdersUseCase _getMyOrders;

  List<OrderEntity> orders = const [];
  bool requiresLogin = false;

  Future<void> load() {
    return runLoad(() async {
      final loggedIn = await unwrapFutureResult(
        _isLoggedIn(),
        fallback: false,
      );
      requiresLogin = !loggedIn;
      if (!loggedIn) {
        orders = const [];
        return;
      }

      orders = await unwrapFutureResult(
        _getMyOrders(),
        fallback: const [],
      );
    });
  }
}

OrdersController createOrdersController() {
  configureDependencies();
  return sl<OrdersController>();
}
