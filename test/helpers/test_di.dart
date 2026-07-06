import 'package:cava_ecommerce/core/di/injection.dart';

Future<void> setUpTestDependencies() async {
  await resetDependencies();
  configureDependencies();
}

Future<void> tearDownTestDependencies() async {
  await resetDependencies();
}
