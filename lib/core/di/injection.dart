import 'package:get_it/get_it.dart';

/// Global service locator.
///
/// Phase 2 will register repositories, datasources, and use cases here.
/// Not wired to [main] yet — existing UI continues using mock data directly.
final GetIt sl = GetIt.instance;

bool _dependenciesConfigured = false;

/// Registers application dependencies.
///
/// Call from `main()` only after Firebase and local storage are ready.
/// Intentionally not invoked in Phase 1 to avoid changing runtime behavior.
Future<void> configureDependencies() async {
  if (_dependenciesConfigured) {
    return;
  }

  // Phase 2 examples:
  // sl.registerLazySingleton<ProductRemoteDataSource>(...);
  // sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(...));
  // sl.registerFactory(() => GetProductByIdUseCase(sl()));
  _dependenciesConfigured = true;
}

/// Resets registrations — useful for tests in Phase 2+.
Future<void> resetDependencies() async {
  await sl.reset();
}
