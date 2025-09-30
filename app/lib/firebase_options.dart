// lib/firebase_options.dart

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      // case TargetPlatform.iOS:
      //   return ios;
      // case TargetPlatform.macOS:
      //   return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAQ6NaJr8mG3iROMVlKbZBK8CSRM8z0V_I',
    appId: '1:576890475561:android:715aa5566a6737d0063838',
    messagingSenderId: '576890475561',
    projectId: 'mob-app-12345',
    storageBucket: 'mob-app-12345.appspot.com',
  );

  // static const FirebaseOptions ios = FirebaseOptions(
  //   // apiKey: 'YOUR_IOS_API_KEY',
  //   // appId: 'YOUR_IOS_APP_ID',
  //   // messagingSenderId: 'YOUR_IOS_SENDER_ID',
  //   // projectId: 'YOUR_IOS_PROJECT_ID',
  //   // storageBucket: 'YOUR_IOS_PROJECT_ID.appspot.com',
  //   // iosClientId: 'YOUR_IOS_CLIENT_ID',
  //   // iosBundleId: 'YOUR_IOS_BUNDLE_ID',
  // );

  // static const FirebaseOptions macos = ios;
}
