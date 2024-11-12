// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAqhMIRwoyLfMfa9jsJh2MFbTTI5U2TJmU',
    appId: '1:1065430829179:web:a5e920e3b0126227873ade',
    messagingSenderId: '1065430829179',
    projectId: 'deariediary-b53a4',
    authDomain: 'deariediary-b53a4.firebaseapp.com',
    storageBucket: 'deariediary-b53a4.firebasestorage.app',
    measurementId: 'G-V5CPPHYW1K',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCRNtS3oOcIVre54_Tyejwp9rRg8SXvvAg',
    appId: '1:1065430829179:android:4b7abeeada2cc3d1873ade',
    messagingSenderId: '1065430829179',
    projectId: 'deariediary-b53a4',
    storageBucket: 'deariediary-b53a4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCVedMFMvhLCjiH1sfyh-3zKp49Bu11MJY',
    appId: '1:1065430829179:ios:a82361bdc374badf873ade',
    messagingSenderId: '1065430829179',
    projectId: 'deariediary-b53a4',
    storageBucket: 'deariediary-b53a4.firebasestorage.app',
    iosBundleId: 'com.example.deariediary',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCVedMFMvhLCjiH1sfyh-3zKp49Bu11MJY',
    appId: '1:1065430829179:ios:a82361bdc374badf873ade',
    messagingSenderId: '1065430829179',
    projectId: 'deariediary-b53a4',
    storageBucket: 'deariediary-b53a4.firebasestorage.app',
    iosBundleId: 'com.example.deariediary',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAqhMIRwoyLfMfa9jsJh2MFbTTI5U2TJmU',
    appId: '1:1065430829179:web:86e818668fb776b2873ade',
    messagingSenderId: '1065430829179',
    projectId: 'deariediary-b53a4',
    authDomain: 'deariediary-b53a4.firebaseapp.com',
    storageBucket: 'deariediary-b53a4.firebasestorage.app',
    measurementId: 'G-BKYFNV5GKM',
  );
}
