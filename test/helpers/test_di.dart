import 'package:cava_ecommerce/core/di/injection.dart';
import 'package:cava_ecommerce/features/categories/data/datasources/category_mock_datasource.dart';
import 'package:cava_ecommerce/features/products/data/datasources/product_mock_datasource.dart';

Future<void> setUpTestDependencies() async {
  await resetDependencies();
  await configureTestDependencies(
    productDataSource: const ProductMockDataSource(),
    categoryDataSource: const CategoryMockDataSource(),
  );
}

Future<void> tearDownTestDependencies() async {
  await resetDependencies();
}
