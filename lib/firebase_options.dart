// Generated from android/app/google-services.json (project: buildmate24x7).
// Re-run `flutterfire configure --project=buildmate24x7` after adding platforms.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web — '
        'run flutterfire configure.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS — '
          'run flutterfire configure.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCwP73LKa7-l7VZ7sB7a9dIzReFAa1ihqg',
    appId: '1:384018735885:android:129b5b27b7c7ba6288c644',
    messagingSenderId: '384018735885',
    projectId: 'buildmate24x7',
    storageBucket: 'buildmate24x7.firebasestorage.app',
  );
}
