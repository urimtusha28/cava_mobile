import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/core/result/result.dart';
import 'package:cava_ecommerce/features/products/domain/usecases/get_product_by_id.dart';
import 'package:cava_ecommerce/features/products/presentation/controllers/product_detail_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';

class MockGetProductById extends Mock implements GetProductById {}

void main() {
  late MockGetProductById getProductById;
  late ProductDetailController controller;

  setUp(() {
    getProductById = MockGetProductById();
    controller = ProductDetailController(getProductById);
  });

  test('load sets product on success', () async {
    when(() => getProductById('p1'))
        .thenAnswer((_) async => Success(testProductEntity));

    await controller.load('p1');

    expect(controller.isInitialized, isTrue);
    expect(controller.product?.id, 'p1');
    expect(controller.isLoading, isFalse);
  });

  test('load keeps null product on failure', () async {
    when(() => getProductById('missing')).thenAnswer(
      (_) async => const Error(
        UnknownFailure(message: 'not found', code: '404'),
      ),
    );

    await controller.load('missing');

    expect(controller.product, isNull);
    expect(controller.isInitialized, isTrue);
  });

  test('load sets errorMessage when use case throws', () async {
    when(() => getProductById('p1')).thenThrow(Exception('network'));

    await controller.load('p1');

    expect(controller.errorMessage, isNotNull);
  });

  test('notifyListeners fires on load', () async {
    when(() => getProductById('p1'))
        .thenAnswer((_) async => Success(testProductEntity));

    var notifications = 0;
    controller.addListener(() => notifications++);

    await controller.load('p1');

    expect(notifications, greaterThan(0));
  });
}
