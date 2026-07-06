import 'failures.dart';

/// Data-layer exception used before mapping to [Failure].
class AppException implements Exception {
  const AppException({
    required this.message,
    this.code,
    this.cause,
  });

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() {
    final buffer = StringBuffer('AppException(message: $message');
    if (code != null) {
      buffer.write(', code: $code');
    }
    if (cause != null) {
      buffer.write(', cause: $cause');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

/// Maps data-layer exceptions to domain [Failure] instances.
Failure mapExceptionToFailure(Object error, [StackTrace? stackTrace]) {
  if (error is AppException) {
    return _mapAppException(error);
  }

  return UnknownFailure(
    message: error.toString(),
    code: 'unknown',
  );
}

Failure _mapAppException(AppException exception) {
  final code = exception.code?.toLowerCase();

  return switch (code) {
    'network' || 'network-request-failed' => NetworkFailure(
        message: exception.message,
        code: exception.code,
      ),
    'auth' ||
    'unauthenticated' ||
    'permission-denied' =>
      AuthFailure(message: exception.message, code: exception.code),
    'not-found' => NotFoundFailure(
        message: exception.message,
        code: exception.code,
      ),
    'cache' => CacheFailure(message: exception.message, code: exception.code),
    'validation' => ValidationFailure(
        message: exception.message,
        code: exception.code,
      ),
    'server' || 'unavailable' => ServerFailure(
        message: exception.message,
        code: exception.code,
      ),
    _ => UnknownFailure(message: exception.message, code: exception.code),
  };
}
