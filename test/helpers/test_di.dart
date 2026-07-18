import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/features/account/data/datasources/orders_data_source.dart';
import 'package:cava_ecommerce/features/categories/data/datasources/category_mock_datasource.dart';
import 'package:cava_ecommerce/features/checkout/data/datasources/checkout_data_source.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_mock_datasource.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setUpTestDependencies({
  CheckoutDataSource? checkoutDataSource,
  OrdersDataSource? ordersDataSource,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await resetDependencies();
  await configureTestDependencies(
    productDataSource: const ProductMockDataSource(),
    categoryDataSource: const CategoryMockDataSource(),
    checkoutDataSource: checkoutDataSource,
    ordersDataSource: ordersDataSource,
    wishlistFirestore: FakeFirebaseFirestore(),
    cartFirestore: FakeFirebaseFirestore(),
  );
}

Future<void> tearDownTestDependencies() async {
  await resetDependencies();
}
