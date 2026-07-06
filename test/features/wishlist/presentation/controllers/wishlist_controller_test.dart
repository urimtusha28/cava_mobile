import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/cart/domain/usecases/add_to_cart.dart';
import 'package:cava_ecommerce/features/wishlist/domain/usecases/get_wishlist_items.dart';
import 'package:cava_ecommerce/features/wishlist/domain/usecases/remove_from_wishlist.dart';
import 'package:cava_ecommerce/features/wishlist/presentation/controllers/wishlist_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockGetWishlistItemsUseCase extends Mock
    implements GetWishlistItemsUseCase {}

class MockRemoveFromWishlistUseCase extends Mock
    implements RemoveFromWishlistUseCase {}

class MockAddToCartUseCase extends Mock implements AddToCartUseCase {}

void main() {
  late WishlistController controller;
  late MockGetWishlistItemsUseCase getWishlistItems;
  late MockRemoveFromWishlistUseCase removeFromWishlist;
  late MockAddToCartUseCase addToCart;

  setUp(() {
    getWishlistItems = MockGetWishlistItemsUseCase();
    removeFromWishlist = MockRemoveFromWishlistUseCase();
    addToCart = MockAddToCartUseCase();
    controller = WishlistController(
      getWishlistItems,
      removeFromWishlist,
      addToCart,
    );
  });

  test('load populates items', () async {
    when(() => getWishlistItems())
        .thenAnswer((_) async => Success([testProductEntity]));

    await controller.load();

    expect(controller.items, hasLength(1));
    expect(controller.count, 1);
  });

  test('remove refreshes items', () async {
    when(() => removeFromWishlist('p1'))
        .thenAnswer((_) async => const Success(null));
    when(() => getWishlistItems()).thenAnswer((_) async => Success([]));

    await controller.remove('p1');

    verify(() => removeFromWishlist('p1')).called(1);
    expect(controller.items, isEmpty);
  });

  test('addToCart delegates to use case', () async {
    when(() => addToCart(testProductEntity))
        .thenAnswer((_) async => const Success(null));

    await controller.addToCart(testProductEntity);

    verify(() => addToCart(testProductEntity)).called(1);
  });
}
