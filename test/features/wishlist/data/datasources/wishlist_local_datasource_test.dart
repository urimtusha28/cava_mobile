import 'package:cava_ecommerce/features/wishlist/data/datasources/wishlist_local_datasource.dart';
import 'package:cava_ecommerce/features/wishlist/data/local/local_wishlist_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  const dataSource = WishlistLocalDataSource();

  setUp(LocalWishlistStore.clear);

  test('starts empty without mock seed products', () {
    expect(dataSource.getItems(), isEmpty);
    expect(dataSource.getCount(), 0);
  });

  test('stores real ProductEntity from catalog', () {
    dataSource.add(testProductEntity);

    expect(dataSource.getItems(), [testProductEntity]);
    expect(dataSource.isInWishlist('p1'), isTrue);
    expect(dataSource.getCount(), 1);
  });

  test('remove deletes product from local wishlist', () {
    dataSource.add(testProductEntity);

    dataSource.remove('p1');

    expect(dataSource.getItems(), isEmpty);
    expect(dataSource.isInWishlist('p1'), isFalse);
  });
}
