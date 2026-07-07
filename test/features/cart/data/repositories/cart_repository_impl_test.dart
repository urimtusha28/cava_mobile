import 'package:cava_ecommerce/core/state/cart_state_notifier.dart';
import 'package:cava_ecommerce/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:cava_ecommerce/features/cart/domain/entities/cart_summary_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockCartDataSource dataSource;
  late CartRepositoryImpl repository;

  setUp(() {
    CartStateNotifier.reset();
    dataSource = MockCartDataSource();
    when(() => dataSource.getItemCount()).thenReturn(0);
    when(() => dataSource.loadPersistedCart()).thenAnswer((_) async {});
    repository = CartRepositoryImpl(dataSource);
  });

  tearDown(() => CartStateNotifier.reset());

  test('getSummary aggregates datasource values', () async {
    when(() => dataSource.getItems()).thenReturn([testCartItem]);
    when(() => dataSource.getItemCount()).thenReturn(2);
    when(() => dataSource.getSubtotal()).thenReturn(50.0);
    when(() => dataSource.getDiscount()).thenReturn(5.0);
    when(() => dataSource.getVat()).thenReturn(10.0);
    when(() => dataSource.getShipping()).thenReturn(2.0);
    when(() => dataSource.getTotal()).thenReturn(57.0);

    final summary = await repository.getSummary();

    expect(summary, isA<CartSummaryEntity>());
    expect(summary.itemCount, 2);
    expect(summary.total, 57.0);
  });

  test('addProduct with quantity persists and updates badge', () async {
    when(() => dataSource.getItemCount()).thenReturn(5);

    await repository.addProduct(testProductEntity, quantity: 3);

    verify(
      () => dataSource.addProduct(testProductEntity, quantity: 3),
    ).called(1);
    expect(CartStateNotifier.revision.value, 5);
  });
}
