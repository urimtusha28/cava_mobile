import 'package:cava_ecommerce/core/state/wishlist_state_notifier.dart';
import 'package:cava_ecommerce/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockWishlistDataSource dataSource;
  late WishlistRepositoryImpl repository;

  setUp(() {
    WishlistStateNotifier.reset();
    dataSource = MockWishlistDataSource();
    when(() => dataSource.getCount()).thenReturn(0);
    repository = WishlistRepositoryImpl(dataSource);
  });

  tearDown(() => WishlistStateNotifier.reset());

  test('getItems returns datasource items', () async {
    when(() => dataSource.getItems()).thenReturn([testProductEntity]);
    final items = await repository.getItems();
    expect(items, hasLength(1));
  });

  test('toggle removes when already in wishlist', () async {
    when(() => dataSource.isInWishlist('p1')).thenReturn(true);
    when(() => dataSource.getCount()).thenReturn(0);

    await repository.toggle(testProductEntity);

    verify(() => dataSource.remove('p1')).called(1);
  });

  test('toggle adds when not in wishlist', () async {
    when(() => dataSource.isInWishlist('p1')).thenReturn(false);
    when(() => dataSource.getCount()).thenReturn(1);

    await repository.toggle(testProductEntity);

    verify(() => dataSource.add(testProductEntity)).called(1);
  });
}
