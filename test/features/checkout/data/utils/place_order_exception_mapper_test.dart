import 'package:cava_ecommerce/core/error/failures.dart';
import 'package:cava_ecommerce/features/checkout/data/utils/place_order_exception_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps known place order error codes', () {
    expect(
      PlaceOrderExceptionMapper.toUserMessage(
        const ServerFailure(message: 'x', code: 'OUT_OF_STOCK'),
      ),
      'Një produkt nuk është më në stok.',
    );
    expect(
      PlaceOrderExceptionMapper.toUserMessage(
        const ServerFailure(message: 'x', code: 'PRICE_MISMATCH'),
      ),
      'Çmimi i një produkti ka ndryshuar. Rifresko shportën.',
    );
    expect(
      PlaceOrderExceptionMapper.toUserMessage(
        const ValidationFailure(message: 'x', code: 'TERMS_REQUIRED'),
      ),
      'Duhet të pranosh kushtet.',
    );
    expect(
      PlaceOrderExceptionMapper.toUserMessage(
        const AuthFailure(message: 'x', code: 'UNAUTHENTICATED'),
      ),
      'Kyçu për të vazhduar.',
    );
    expect(
      PlaceOrderExceptionMapper.toUserMessage(
        const ValidationFailure(message: 'x', code: 'GUEST_INFO_REQUIRED'),
      ),
      'Plotëso të dhënat për dorëzim.',
    );
    expect(
      PlaceOrderExceptionMapper.toUserMessage(
        const ServerFailure(message: 'x', code: 'AUTH_USER_MISMATCH'),
      ),
      'Sesioni i llogarisë nuk përputhet. Dil dhe kyçu përsëri.',
    );
    expect(
      PlaceOrderExceptionMapper.toUserMessage(
        const ServerFailure(message: 'x', code: 'INVALID_PAYMENT_METHOD'),
      ),
      contains('pagesës'),
    );
    expect(
      PlaceOrderExceptionMapper.toUserMessage(
        const ServerFailure(message: 'x', code: 'RATE_LIMITED'),
      ),
      'Provo përsëri më vonë.',
    );
  });

  test('uses default message for unknown errors', () {
    expect(
      PlaceOrderExceptionMapper.toUserMessage(
        const UnknownFailure(message: '', code: 'UNKNOWN'),
      ),
      PlaceOrderExceptionMapper.defaultMessage,
    );
  });
}
