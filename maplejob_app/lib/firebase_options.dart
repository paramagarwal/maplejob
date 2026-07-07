import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'this is the mobile applicant app.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSy012345678901234567890123456789012',
    appId: '1:123456789012:android:a1b2c3d4e5f6g7h8',
    messagingSenderId: '123456789012',
    projectId: 'maplejob-recruitment',
    storageBucket: 'maplejob-recruitment.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSy012345678901234567890123456789013',
    appId: '1:123456789012:ios:a1b2c3d4e5f6g7h8',
    messagingSenderId: '123456789012',
    projectId: 'maplejob-recruitment',
    storageBucket: 'maplejob-recruitment.appspot.com',
    iosBundleId: 'com.maplehubrealty.maplejob.maplejobApp',
  );
}
