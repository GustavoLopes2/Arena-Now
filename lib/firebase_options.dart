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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBJmWb11FA1zhP1m2LcVQiNXjvwePEoBY8',
    appId: '1:762842763865:android:339f68b587c5487b959748',
    messagingSenderId: '762842763865',
    projectId: 'arenanow-561e7',
    storageBucket: 'arenanow-561e7.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJmWb11FA1zhP1m2LcVQiNXjvwePEoBY8',
    appId: '1:762842763865:ios:9e2ad94625719341959748',
    messagingSenderId: '762842763865',
    projectId: 'arenanow-561e7',
    storageBucket: 'arenanow-561e7.appspot.com',
    iosBundleId: 'com.example.arenanow',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBcEIfqMlcm3EqwmkEgm2sjb4CqvjspcuI",
    appId: "1:762842763865:web:5f513097e8837969959748",
    messagingSenderId: "762842763865",
    projectId: 'arenanow-561e7',
    authDomain: "arenanow-561e7.firebaseapp.com",
    storageBucket: "arenanow-561e7.firebasestorage.app",
  );
}
