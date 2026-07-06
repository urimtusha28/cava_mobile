import 'package:cava_ecommerce/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/clear_cart.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/get_cart_count.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/get_cart_items.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/get_cart_summary.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/update_cart_quantity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockCartRepository repository;

  setUp(() {
    repository = MockCartRepository();
  });

  test('GetCartSummaryUseCase returns summary', () async {
    const summary = CartSummaryEntity(
      items: [],
      itemCount: 1,
      subtotal: 10,
      discount: 0,
      vat: 2,
      shipping: 1,
      total: 13,
    );
    when(() => repository.getSummary()).thenAnswer((_) async => summary);
    final result = await GetCartSummaryUseCase(repository)();
    expect(result.dataOrNull?.total, 13);
  });

  test('GetCartItemsUseCase returns items', () async {
    when(() => repository.getItems())
        .thenAnswer((_) async => [testCartItem]);
    final result = await GetCartItemsUseCase(repository)();
    expect(result.dataOrNull, hasLength(1));
  });

  test('AddToCartUseCase delegates to repository', () async {
    when(() => repository.addProduct(testProductEntity))
        .thenAnswer((_) => Future<void>.value());
    final result = await AddToCartUseCase(repository)(testProductEntity);
    expect(result.isSuccess, isTrue);
  });

  test('RemoveFromCartUseCase delegates to repository', () async {
    when(() => repository.removeAt(0)).thenAnswer((_) => Future<void>.value());
    final result = await RemoveFromCartUseCase(repository)(0);
    expect(result.isSuccess, isTrue);
  });

  test('UpdateCartQuantityUseCase delegates to repository', () async {
    when(() => repository.updateQuantity(0, 2)).thenAnswer((_) => Future<void>.value());
    final result = await UpdateCartQuantityUseCase(repository)(
      const UpdateCartQuantityParams(index: 0, quantity: 2),
    );
    expect(result.isSuccess, isTrue);
  });

  test('ClearCartUseCase delegates to repository', () async {
    when(() => repository.clear()).thenAnswer((_) => Future<void>.value());
    final result = await ClearCartUseCase(repository)();
    expect(result.isSuccess, isTrue);
  });

  test('GetCartCountUseCase returns count', () async {
    when(() => repository.getItemCount()).thenAnswer((_) async => 4);
    final result = await GetCartCountUseCase(repository)();
    expect(result.dataOrNull, 4);
  });
}
