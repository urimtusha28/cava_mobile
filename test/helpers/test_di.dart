import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_mock_datasource.dart';

Future<void> setUpTestDependencies() async {
  await resetDependencies();
  await configureTestDependencies(
    productDataSource: const ProductMockDataSource(),
  );
}

Future<void> tearDownTestDependencies() async {
  await resetDependencies();
}
