import '../error/failures.dart';

/// Either-like result wrapper for use cases and repositories.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Error<T>() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Error<T>(:final failure) => failure,
      };

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      Error<T>(:final failure) => onFailure(failure),
    };
  }
}

final class Success<T> extends Result<T> {
  const Success(this.data);

  final T data;
}

final class Error<T> extends Result<T> {
  const Error(this.failure);

  final Failure failure;
}

/// Executes [action] and wraps the outcome in [Result].
Future<Result<T>> guard<T>(Future<T> Function() action) async {
  try {
    final data = await action();
    return Success(data);
  } on Failure catch (failure) {
    return Error(failure);
  } catch (error) {
    return Error(
      UnknownFailure(message: error.toString(), code: 'unknown'),
    );
  }
}

/// Synchronous variant of [guard].
Result<T> guardSync<T>(T Function() action) {
  try {
    return Success(action());
  } on Failure catch (failure) {
    return Error(failure);
  } catch (error) {
    return Error(
      UnknownFailure(message: error.toString(), code: 'unknown'),
    );
  }
}
