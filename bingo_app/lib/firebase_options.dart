// Gerado pelo FlutterFire CLI para o flavor PROD (com.nightstudios.bingo).
// Para regenerar: flutterfire configure --project=bingo-lucca-app --platforms=android,ios
//   --android-package-name=com.nightstudios.bingo --ios-bundle-id=com.nightstudios.bingo
//   --android-out=android/app/src/prod/google-services.json --out=lib/firebase_options.dart
// O flavor DEV fica em firebase_options_dev.dart.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
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
    apiKey: 'AIzaSyAn_riKabzAxrrH09-zpuGrkDb5sBJ_aN8',
    appId: '1:726195608166:android:3d761008a74eb1d88f2ba7',
    messagingSenderId: '726195608166',
    projectId: 'nightstudios-bingo',
    storageBucket: 'nightstudios-bingo.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCCIEu-JvA0RMl-13QqLSgKI-pvNCNpLqY',
    appId: '1:726195608166:ios:a3a1207aa579d5c28f2ba7',
    messagingSenderId: '726195608166',
    projectId: 'nightstudios-bingo',
    storageBucket: 'nightstudios-bingo.firebasestorage.app',
    iosBundleId: 'com.nightstudios.bingo',
  );
}
