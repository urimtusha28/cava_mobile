import 'package:cava_ecommerce/features/checkout/data/local/checkout_selected_address_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CheckoutSelectedAddressStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = CheckoutSelectedAddressStorage();
  });

  test('persists and reads selected address id', () async {
    expect(await storage.readAddressId(), isNull);

    await storage.writeAddressId('addr-home');
    expect(await storage.readAddressId(), 'addr-home');
  });

  test('clear removes persisted id', () async {
    await storage.writeAddressId('addr-home');
    await storage.clear();

    expect(await storage.readAddressId(), isNull);
  });
}
