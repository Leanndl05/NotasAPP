import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDqZdEud6HzpWsLo25N3jW0m1C1-NeitX4',
    appId: '1:134179825695:web:a3c356aa4d0bffcaf44d2a',
    messagingSenderId: '134179825695',
    projectId: 'notasapp-f0e31',
    authDomain: 'notasapp-f0e31.firebaseapp.com',
    storageBucket: 'notasapp-f0e31.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDqZdEud6HzpWsLo25N3jW0m1C1-NeitX4',
    appId: '1:134179825695:android:0078787edcbf0f4ef44d2a',
    messagingSenderId: '134179825695',
    projectId: 'notasapp-f0e31',
    storageBucket: 'notasapp-f0e31.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDqZdEud6HzpWsLo25N3jW0m1C1-NeitX4',
    appId: '1:134179825695:ios:0078787edcbf0f4ef44d2a',
    messagingSenderId: '134179825695',
    projectId: 'notasapp-f0e31',
    storageBucket: 'notasapp-f0e31.firebasestorage.app',
    iosBundleId: 'com.company.NotasAPP',
  );
}
