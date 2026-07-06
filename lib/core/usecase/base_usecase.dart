import '../result/result.dart';

/// Marker for use cases that do not require input parameters.
final class NoParams {
  const NoParams();
}

/// Base contract for use cases with parameters.
abstract class BaseUseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Base contract for use cases without parameters.
abstract class BaseUseCaseNoParams<T> {
  Future<Result<T>> call();
}

/// Base contract for synchronous use cases with parameters.
abstract class SyncUseCase<T, Params> {
  Result<T> call(Params params);
}

/// Base contract for synchronous use cases without parameters.
abstract class SyncUseCaseNoParams<T> {
  Result<T> call();
}
