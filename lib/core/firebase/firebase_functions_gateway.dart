/// Thin wrapper around Firebase callable functions for testability.
abstract class FirebaseFunctionsGateway {
  Future<Map<String, dynamic>> call(
    String functionName,
    Map<String, dynamic> data,
  );
}
