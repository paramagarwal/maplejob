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
    apiKey: 'AIzaSyDjMU7-Q4RfRfs17OiZrZoDRwKOi4bxDHI',
    appId: '1:9546364908:android:831db018aedea84e6372c9',
    messagingSenderId: '9546364908',
    projectId: 'maplejob-beb1d',
    storageBucket: 'maplejob-beb1d.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB_EitNMCjRFA8feMJscOh3jedKnbbTHos',
    appId: '1:9546364908:ios:32dea5eb110fd6046372c9',
    messagingSenderId: '9546364908',
    projectId: 'maplejob-beb1d',
    storageBucket: 'maplejob-beb1d.firebasestorage.app',
    iosBundleId: 'com.maplehubrealty.maplejob.maplejobApp',
  );
}
