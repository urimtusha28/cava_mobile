import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/features/categories/data/datasources/category_mock_datasource.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_mock_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> setUpTestDependencies() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await resetDependencies();
  await configureTestDependencies(
    productDataSource: const ProductMockDataSource(),
    categoryDataSource: const CategoryMockDataSource(),
  );
}

Future<void> tearDownTestDependencies() async {
  await resetDependencies();
}
