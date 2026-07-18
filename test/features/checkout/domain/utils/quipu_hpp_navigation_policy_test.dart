import 'package:cava_ecommerce/features/checkout/domain/utils/quipu_hpp_navigation_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuipuHppNavigationPolicy.decide', () {
    test('allows the Quipu HPP url inside the WebView', () {
      final decision = QuipuHppNavigationPolicy.decide(
        'https://3dss2test.quipu.de:8000/hpp?id=q1&password=p',
      );
      expect(decision.action, HppNavigationAction.allow);
    });

    test('allows http/https 3D Secure (ACS) redirects', () {
      expect(
        QuipuHppNavigationPolicy.decide(
          'https://acs.bank.example/3ds2/auth',
        ).action,
        HppNavigationAction.allow,
      );
      expect(
        QuipuHppNavigationPolicy.decide(
          'https://3ds-challenge.issuer.example/challenge?tx=abc',
        ).action,
        HppNavigationAction.allow,
      );
    });

    test('allows about:blank used by 3DS iframes', () {
      expect(
        QuipuHppNavigationPolicy.decide('about:blank').action,
        HppNavigationAction.allow,
      );
    });

    test('intercepts the payment return URL and extracts transactionId', () {
      final decision = QuipuHppNavigationPolicy.decide(
        'https://cava-premium.com/payment/return?transactionId=tx-123',
      );

      expect(decision.action, HppNavigationAction.interceptReturn);
      expect(decision.transactionId, 'tx-123');
    });

    test('intercepts the return URL on any host (localhost/emulator)', () {
      final decision = QuipuHppNavigationPolicy.decide(
        'http://localhost:5173/payment/return?transactionId=tx-9&x=1',
      );

      expect(decision.action, HppNavigationAction.interceptReturn);
      expect(decision.transactionId, 'tx-9');
    });

    test('intercepts the return URL with trailing slash and extra params', () {
      final decision = QuipuHppNavigationPolicy.decide(
        'https://cava-premium.com/payment/return/?foo=bar&transactionId=tx-5#f',
      );

      expect(decision.action, HppNavigationAction.interceptReturn);
      expect(decision.transactionId, 'tx-5');
    });

    test('return URL without transactionId still intercepts with null id', () {
      final decision = QuipuHppNavigationPolicy.decide(
        'https://cava-premium.com/payment/return',
      );

      expect(decision.action, HppNavigationAction.interceptReturn);
      expect(decision.transactionId, isNull);
    });

    test('does not intercept other paths on the same host', () {
      expect(
        QuipuHppNavigationPolicy.decide(
          'https://cava-premium.com/products',
        ).action,
        HppNavigationAction.allow,
      );
      expect(
        QuipuHppNavigationPolicy.decide(
          'https://cava-premium.com/payment/returned',
        ).action,
        HppNavigationAction.allow,
      );
    });

    test('sends bank-app and non-web schemes to the external fallback', () {
      for (final url in [
        'bankid://auth?token=abc',
        'intent://pay/#Intent;scheme=bankapp;end',
        'mailto:support@cava-premium.com',
        'tel:+38344111222',
        'raiffeisenpay://3ds/complete',
      ]) {
        expect(
          QuipuHppNavigationPolicy.decide(url).action,
          HppNavigationAction.openExternal,
          reason: url,
        );
      }
    });

    test('unparseable or scheme-less input falls back to external', () {
      expect(
        QuipuHppNavigationPolicy.decide('::not a url::').action,
        HppNavigationAction.openExternal,
      );
      expect(
        QuipuHppNavigationPolicy.decide('/payment/return').action,
        HppNavigationAction.openExternal,
      );
    });

    test('rejects oversized transactionId values', () {
      final longId = 'x' * 200;
      final decision = QuipuHppNavigationPolicy.decide(
        'https://cava-premium.com/payment/return?transactionId=$longId',
      );

      expect(decision.action, HppNavigationAction.interceptReturn);
      expect(decision.transactionId, isNull);
    });
  });
}
