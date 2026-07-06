import 'package:firebase_core/firebase_core.dart';

import 'firebase_config.dart';

/// Firebase bootstrap helper — not invoked from UI in Phase 1.
abstract final class FirebaseInitializer {
  /// Initializes Firebase when [FirebaseConfig.enabled] is true.
  ///
  /// Requires generated `firebase_options.dart` from `flutterfire configure`.
  /// Returns `false` when Firebase is disabled so callers can keep mock mode.
  static Future<bool> initialize({
    FirebaseOptions? options,
  }) async {
    if (!FirebaseConfig.enabled) {
      return false;
    }

    if (Firebase.apps.isNotEmpty) {
      return true;
    }

    if (options == null) {
      throw StateError(
        'FirebaseConfig.enabled is true but no FirebaseOptions were provided. '
        'Run `flutterfire configure` and pass DefaultFirebaseOptions.currentPlatform.',
      );
    }

    await Firebase.initializeApp(options: options);
    return true;
  }
}
