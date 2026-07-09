import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cava_ecommerce/core/firebase/firebase_config.dart';
import 'package:cava_ecommerce/features/checkout/data/firebase/firebase_functions_gateway_impl.dart';

class _MockCallableAuthBridge extends Mock implements CallableAuthBridge {}

void main() {
  late _MockCallableAuthBridge auth;
  late List<String> invokeOrder;
  late Map<String, dynamic>? lastPayload;
  late FirebaseFunctionsGatewayImpl gateway;

  setUp(() {
    auth = _MockCallableAuthBridge();
    invokeOrder = <String>[];
    lastPayload = null;

    when(() => auth.uid).thenReturn('uid-1');
    when(() => auth.email).thenReturn('u@cava.test');
    when(() => auth.projectId).thenReturn('cavapremium-31036');
    when(() => auth.ensureFreshIdToken()).thenAnswer((_) async {
      invokeOrder.add('token');
      return true;
    });

    gateway = FirebaseFunctionsGatewayImpl(
      authBridge: auth,
      region: FirebaseConfig.functionsRegion,
      functionsProjectId: 'cavapremium-31036',
      invoker: (name, data) async {
        invokeOrder.add('call:$name');
        lastPayload = Map<String, dynamic>.from(data);
        return {'orderId': 'o1'};
      },
    );
  });

  test('logged in placeOrder refreshes ID token before callable', () async {
    final result = await gateway.call('placeOrder', {
      'customerType': 'user',
      'userId': 'uid-1',
    });

    expect(invokeOrder, ['token', 'call:placeOrder']);
    verify(() => auth.ensureFreshIdToken()).called(1);
    expect(result['orderId'], 'o1');
    expect(lastPayload?['userId'], 'uid-1');
    expect(gateway.functionsProjectId, 'cavapremium-31036');
    expect(gateway.region, 'us-central1');
    expect(auth.projectId, gateway.functionsProjectId);
  });

  test('guest path still calls ensureFreshIdToken then callable', () async {
    when(() => auth.uid).thenReturn(null);
    when(() => auth.email).thenReturn(null);
    when(() => auth.ensureFreshIdToken()).thenAnswer((_) async {
      invokeOrder.add('token');
      return false;
    });

    await gateway.call('placeOrder', {
      'customerType': 'guest',
      'userId': null,
    });

    expect(invokeOrder, ['token', 'call:placeOrder']);
    verify(() => auth.ensureFreshIdToken()).called(1);
  });

  test('functions gateway uses same project id as auth bridge', () {
    expect(auth.projectId, 'cavapremium-31036');
    expect(gateway.functionsProjectId, auth.projectId);
    expect(gateway.region, FirebaseConfig.functionsRegion);
  });
}
