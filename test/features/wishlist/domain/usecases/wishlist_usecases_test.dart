import 'package:cava_ecommerce/features/wishlist/domain/usecases/get_wishlist_count.dart';
import 'package:cava_ecommerce/features/wishlist/domain/usecases/get_wishlist_items.dart';
import 'package:cava_ecommerce/features/wishlist/domain/usecases/is_in_wishlist.dart';
import 'package:cava_ecommerce/features/wishlist/domain/usecases/remove_from_wishlist.dart';
import 'package:cava_ecommerce/features/wishlist/domain/usecases/toggle_wishlist.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockWishlistRepository repository;

  setUp(() {
    repository = MockWishlistRepository();
  });

  test('GetWishlistItemsUseCase returns items', () async {
    when(() => repository.getItems())
        .thenAnswer((_) async => [testProductEntity]);
    final result = await GetWishlistItemsUseCase(repository)();
    expect(result.dataOrNull, hasLength(1));
  });

  test('ToggleWishlistUseCase toggles product', () async {
    when(() => repository.toggle(testProductEntity))
        .thenAnswer((_) => Future<void>.value());
    final result = await ToggleWishlistUseCase(repository)(testProductEntity);
    expect(result.isSuccess, isTrue);
  });

  test('RemoveFromWishlistUseCase removes product', () async {
    when(() => repository.remove('p1')).thenAnswer((_) => Future<void>.value());
    final result = await RemoveFromWishlistUseCase(repository)('p1');
    expect(result.isSuccess, isTrue);
  });

  test('IsInWishlistUseCase checks membership', () async {
    when(() => repository.isInWishlist('p1')).thenAnswer((_) async => true);
    final result = await IsInWishlistUseCase(repository)('p1');
    expect(result.dataOrNull, isTrue);
  });

  test('GetWishlistCountUseCase returns count', () async {
    when(() => repository.getCount()).thenAnswer((_) async => 2);
    final result = await GetWishlistCountUseCase(repository)();
    expect(result.dataOrNull, 2);
  });
}
