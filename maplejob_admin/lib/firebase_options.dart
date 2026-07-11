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
    apiKey: 'AIzaSyDEuOUIn0C5SSPgQHBvOaDgxqb48sqEe5A',
    appId: '1:9546364908:web:1240b77275b88bdd6372c9',
    messagingSenderId: '9546364908',
    projectId: 'maplejob-beb1d',
    authDomain: 'maplejob-beb1d.firebaseapp.com',
    storageBucket: 'maplejob-beb1d.firebasestorage.app',
    measurementId: 'G-G18WEYXZ09',
  );
}
