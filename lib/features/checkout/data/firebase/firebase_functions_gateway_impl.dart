import 'package:cloud_functions/cloud_functions.dart';

import '../../../../core/firebase/firebase_functions_gateway.dart';

class FirebaseFunctionsGatewayImpl implements FirebaseFunctionsGateway {
  FirebaseFunctionsGatewayImpl(this._functions);

  final FirebaseFunctions _functions;

  @override
  Future<Map<String, dynamic>> call(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    final result = await _functions.httpsCallable(functionName).call(data);
    final raw = result.data;
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return const {};
  }
}
