import '../result/result.dart';

T unwrapResult<T>(Result<T> result, {required T fallback}) {
  return result.fold(
    onSuccess: (data) => data,
    onFailure: (_) => fallback,
  );
}

Future<T> unwrapFutureResult<T>(
  Future<Result<T>> future, {
  required T fallback,
}) async {
  return unwrapResult(await future, fallback: fallback);
}
