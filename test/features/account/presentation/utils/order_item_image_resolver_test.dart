import 'package:cava_ecommerce/features/account/domain/entities/order_item_entity.dart';
import 'package:cava_ecommerce/features/account/presentation/utils/order_item_image_resolver.dart';
import 'package:cava_ecommerce/features/products/domain/entities/product_entity.dart';
import 'package:cava_ecommerce/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repository;
  late OrderItemImageResolver resolver;

  setUp(() {
    repository = MockProductRepository();
    resolver = OrderItemImageResolver(repository);
  });

  test('returns item imageUrl when present', () async {
    const item = OrderItemEntity(
      name: 'Verë',
      quantity: 1,
      price: 8.5,
      lineTotal: 8.5,
      imageUrl: 'https://example.com/wine.jpg',
    );

    final imageUrl = await resolver.resolve(item);

    expect(imageUrl, 'https://example.com/wine.jpg');
    verifyNever(() => repository.getById(any()));
  });

  test('falls back to product repository image when item image missing', () async {
    when(() => repository.getById('p1')).thenAnswer(
      (_) async => const ProductEntity(
        id: 'p1',
        name: 'Stone Castle Merlot',
        brand: 'Stone Castle',
        categoryId: 'wines',
        categoryName: 'Wines',
        price: 8.5,
        description: 'Test wine',
        volume: '750ml',
        type: 'Red',
        rating: 4.5,
        reviewCount: 10,
        stock: 50,
        isFeatured: false,
        imageUrl: 'https://example.com/product.jpg',
      ),
    );

    const item = OrderItemEntity(
      name: 'Stone Castle Merlot',
      quantity: 1,
      price: 8.5,
      lineTotal: 8.5,
      productId: 'p1',
    );

    final imageUrl = await resolver.resolve(item);

    expect(imageUrl, 'https://example.com/product.jpg');
    verify(() => repository.getById('p1')).called(1);
  });

  test('returns null when no image sources exist', () async {
    when(() => repository.getById('missing')).thenAnswer((_) async => null);

    const item = OrderItemEntity(
      name: 'Produkt',
      quantity: 1,
      price: 1,
      lineTotal: 1,
      productId: 'missing',
    );

    final imageUrl = await resolver.resolve(item);

    expect(imageUrl, isNull);
  });
}
