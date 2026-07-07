import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (!kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for mobile - '
        'this is the web admin dashboard.',
      );
    }
    return web;
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA_PLACEHOLDER_WEB_API_KEY_MAPLEJOB',
    appId: '1:123456789012:web:a1b2c3d4e5f6g7h8',
    messagingSenderId: '123456789012',
    projectId: 'maplejob-recruitment',
    authDomain: 'maplejob-recruitment.firebaseapp.com',
    storageBucket: 'maplejob-recruitment.appspot.com',
    measurementId: 'G-MAPLEJOBWEB',
  );
}
