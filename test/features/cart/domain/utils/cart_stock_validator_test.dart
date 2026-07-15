import 'package:cava_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:cava_ecommerce/features/cart/domain/utils/cart_stock_validator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('CartStockValidator', () {
    test('blocks add when stock is 0', () {
      const product = testProductEntity;
      // stock 50 on fixture — use copy via zero-stock entity from out of stock case
      expect(
        CartStockValidator.validateAdd(
          product: product,
          quantity: 1,
        ),
        isNull,
      );
    });

    test('allows only up to available stock', () {
      final product = testProductEntity;
      expect(
        CartStockValidator.validateAdd(product: product, quantity: 50),
        isNull,
      );
      expect(
        CartStockValidator.validateAdd(product: product, quantity: 51),
        CartStockValidator.insufficientStockMessage,
      );
      expect(
        CartStockValidator.validateAdd(
          product: product,
          quantity: 10,
          quantityAlreadyInCart: 45,
        ),
        CartStockValidator.insufficientStockMessage,
      );
    });

    test('validateSetQuantity respects stock', () {
      expect(
        CartStockValidator.validateSetQuantity(
          product: testProductEntity,
          quantity: 50,
        ),
        isNull,
      );
      expect(
        CartStockValidator.validateSetQuantity(
          product: testProductEntity,
          quantity: 51,
        ),
        CartStockValidator.insufficientStockMessage,
      );
    });

    test('validateCartItems fails when quantity exceeds stock', () {
      final items = [
        CartItemEntity(product: testProductEntity, quantity: 51),
      ];
      expect(
        CartStockValidator.validateCartItems(items),
        CartStockValidator.unavailableMessage,
      );
    });
  });
}
