import 'package:cava_ecommerce/features/checkout/domain/entities/place_order_result_entity.dart';
import 'package:cava_ecommerce/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:cava_ecommerce/features/checkout/domain/usecases/place_order.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks.dart';

void main() {
  late MockCheckoutRepository repository;
  late PlaceOrderUseCase useCase;

  setUp(() {
    repository = MockCheckoutRepository();
    useCase = PlaceOrderUseCase(repository);
    registerFallbackValue(
      const PlaceOrderRequest(paymentMethod: 'cash', termsAccepted: true),
    );
  });

  test('returns order on success', () async {
    when(() => repository.placeOrder(any())).thenAnswer(
      (_) async => const PlaceOrderResultEntity(
        orderId: 'order-1',
        orderNumber: 'CP-1001',
        total: 57,
        paymentMethod: 'cash',
      ),
    );

    final result = await useCase(
      const PlaceOrderRequest(paymentMethod: 'cash', termsAccepted: true),
    );

    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.orderId, 'order-1');
  });
}
