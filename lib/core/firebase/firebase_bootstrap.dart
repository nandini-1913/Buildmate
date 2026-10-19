import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';
import '../../services/auth_service.dart';

/// Initializes Firebase once; never blocks app launch on failure.
class FirebaseBootstrap {
  static bool _initialized = false;

  static bool get isReady => _initialized;

  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
        PhoneAuthService.instance.attachApiClient();
        return;
      }
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      PhoneAuthService.instance.attachApiClient();
      if (kDebugMode) {
        debugPrint('Firebase initialized for buildmate24x7');
      }
    } catch (e, st) {
      _initialized = false;
      debugPrint('Firebase init failed (app will run without auth): $e');
      debugPrint('$st');
    }
  }
}
