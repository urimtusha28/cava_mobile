import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/account/domain/entities/order_entity.dart';
import 'package:cava_ecommerce/features/account/domain/repositories/orders_repository.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/get_my_orders.dart';
import 'package:cava_ecommerce/features/account/domain/usecases/is_logged_in.dart';
import 'package:cava_ecommerce/features/account/presentation/controllers/orders_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockIsLoggedInUseCase extends Mock implements IsLoggedInUseCase {}

class MockGetMyOrdersUseCase extends Mock implements GetMyOrdersUseCase {}

void main() {
  late MockIsLoggedInUseCase isLoggedIn;
  late MockGetMyOrdersUseCase getMyOrders;
  late OrdersController controller;

  setUp(() {
    isLoggedIn = MockIsLoggedInUseCase();
    getMyOrders = MockGetMyOrdersUseCase();
    controller = OrdersController(isLoggedIn, getMyOrders);
  });

  test('requires login when user is guest', () async {
    when(() => isLoggedIn()).thenAnswer((_) async => Success(false));

    await controller.load();

    expect(controller.requiresLogin, isTrue);
    expect(controller.orders, isEmpty);
  });

  test('loads orders for logged in user', () async {
    when(() => isLoggedIn()).thenAnswer((_) async => Success(true));
    when(() => getMyOrders()).thenAnswer(
      (_) async => Success(const [
        OrderEntity(
          id: 'o1',
          orderNumber: '#CP-1',
          status: 'delivered',
          paymentStatus: 'paid',
          total: 10,
          itemCount: 1,
        ),
      ]),
    );

    await controller.load();

    expect(controller.requiresLogin, isFalse);
    expect(controller.orders, hasLength(1));
  });
}
