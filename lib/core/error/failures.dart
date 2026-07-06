/// Domain-level error representation.
///
/// Repositories and use cases return [Failure] via [Result] instead of throwing
/// exceptions into the presentation layer.
sealed class Failure {
  const Failure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

final class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

final class AuthFailure extends Failure {
  const AuthFailure({required super.message, super.code});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure({required super.message, super.code});
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

final class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.code});
}
