import '../../../../core/error/failures.dart';

abstract final class PlaceOrderExceptionMapper {
  static const defaultMessage = 'Porosia nuk u krijua. Provo përsëri.';

  static String toUserMessage(Failure failure) {
    final code = failure.code?.toUpperCase();
    return switch (code) {
      'OUT_OF_STOCK' => 'Një produkt nuk është më në stok.',
      'INSUFFICIENT_STOCK' =>
          'Një produkt nuk është më në dispozicion ose nuk ka stok të mjaftueshëm.',
      'PRICE_MISMATCH' => 'Çmimi i një produkti ka ndryshuar. Rifresko shportën.',
      'TERMS_REQUIRED' => 'Duhet të pranosh kushtet.',
      'UNAUTHENTICATED' => 'Kyçu për të vazhduar.',
      'GUEST_INFO_REQUIRED' => 'Plotëso të dhënat për dorëzim.',
      'AUTH_USER_MISMATCH' =>
          'Sesioni i llogarisë nuk përputhet. Dil dhe kyçu përsëri.',
      'INVALID_PAYMENT_METHOD' =>
          'Metoda e pagesës nuk është e vlefshme. Zgjidh para në dorë ose bankë.',
      'INVALID_CUSTOMER' => 'Të dhënat e dorëzimit nuk janë të vlefshme.',
      'INVALID_ITEMS' => 'Shporta nuk është e vlefshme. Rifresko dhe provo përsëri.',
      'PERMISSION_DENIED' => defaultMessage,
      'RATE_LIMITED' => 'Provo përsëri më vonë.',
      _ => failure.message.trim().isNotEmpty ? failure.message : defaultMessage,
    };
  }

  static String? extractErrorCode(Object error) {
    final message = error.toString();
    for (final code in [
      'OUT_OF_STOCK',
      'INSUFFICIENT_STOCK',
      'PRICE_MISMATCH',
      'TERMS_REQUIRED',
      'AUTH_USER_MISMATCH',
      'INVALID_PAYMENT_METHOD',
      'INVALID_CUSTOMER',
      'INVALID_ITEMS',
      'UNAUTHENTICATED',
      'RATE_LIMITED',
    ]) {
      if (message.toUpperCase().contains(code)) {
        return code;
      }
    }
    return null;
  }
}
