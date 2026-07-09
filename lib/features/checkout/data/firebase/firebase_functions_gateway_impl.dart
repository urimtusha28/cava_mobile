import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/firebase/firebase_config.dart';
import '../../../../core/firebase/firebase_functions_gateway.dart';

/// Abstraction over [FirebaseAuth] so callable transport can force-refresh
/// the ID token without coupling tests to the Firebase SDK.
abstract class CallableAuthBridge {
  String? get uid;
  String? get email;
  String get projectId;

  /// Returns `true` when a non-empty ID token was obtained.
  /// Returns `false` when there is no signed-in user (guest call path).
  Future<bool> ensureFreshIdToken();
}

class FirebaseCallableAuthBridge implements CallableAuthBridge {
  FirebaseCallableAuthBridge([FirebaseAuth? auth])
      : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  String? get uid => _auth.currentUser?.uid;

  @override
  String? get email => _auth.currentUser?.email;

  @override
  String get projectId => _auth.app.options.projectId;

  @override
  Future<bool> ensureFreshIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }
    final token = await user.getIdToken(true);
    return token != null && token.trim().isNotEmpty;
  }
}

typedef FunctionsInvoker = Future<Map<String, dynamic>> Function(
  String functionName,
  Map<String, dynamic> data,
);

class FirebaseFunctionsGatewayImpl implements FirebaseFunctionsGateway {
  FirebaseFunctionsGatewayImpl({
    required CallableAuthBridge authBridge,
    required FunctionsInvoker invoker,
    required String region,
    required String functionsProjectId,
  })  : _authBridge = authBridge,
        _invoker = invoker,
        _region = region,
        _functionsProjectId = functionsProjectId;

  /// Production wiring: same [FirebaseApp] as Auth, explicit region,
  /// and forced ID-token refresh before every callable.
  factory FirebaseFunctionsGatewayImpl.createDefault({
    CallableAuthBridge? authBridge,
    String? region,
  }) {
    final resolvedRegion = region ?? FirebaseConfig.functionsRegion;
    final app = Firebase.app();
    final functions = FirebaseFunctions.instanceFor(
      app: app,
      region: resolvedRegion,
    );
    return FirebaseFunctionsGatewayImpl(
      authBridge: authBridge ?? FirebaseCallableAuthBridge(),
      region: resolvedRegion,
      functionsProjectId: app.options.projectId,
      invoker: (name, data) async {
        final result = await functions.httpsCallable(name).call(data);
        final raw = result.data;
        if (raw is Map) {
          return Map<String, dynamic>.from(raw);
        }
        return const {};
      },
    );
  }

  final CallableAuthBridge _authBridge;
  final FunctionsInvoker _invoker;
  final String _region;
  final String _functionsProjectId;

  String get region => _region;
  String get functionsProjectId => _functionsProjectId;

  @override
  Future<Map<String, dynamic>> call(
    String functionName,
    Map<String, dynamic> data,
  ) async {
    final tokenReady = await _authBridge.ensureFreshIdToken();

    if (kDebugMode) {
      debugPrint(
        '[CallableAuth] name=$functionName '
        'uid=${_authBridge.uid} '
        'token=${tokenReady ? 'yes' : 'no'} '
        'authProject=${_authBridge.projectId} '
        'functionsProject=$_functionsProjectId '
        'region=$_region',
      );
    }

    return _invoker(functionName, data);
  }
}
