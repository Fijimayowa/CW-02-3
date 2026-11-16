import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Placeholder options for emulator-only use.
/// Replace by running `flutterfire configure` if you connect to real Firebase.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Run on an Android or iOS emulator.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'fake-api-key',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'madproject-8bb90',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'fake-api-key',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'madproject-8bb90',
    iosBundleId: 'com.example.myApp',
  );
}
