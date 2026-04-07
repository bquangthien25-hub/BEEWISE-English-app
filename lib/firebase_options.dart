import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'DÁN_API_KEY_CỦA_BẠN_VÀO_ĐÂY', // Lấy từ Project Settings -> General
    appId: '1:64879703963:android:8afc5ab3b462370babd33e',
    messagingSenderId: '64879703963',
    projectId: 'beeswise-d3eb1',
    storageBucket: 'beeswise-d3eb1.firebasestorage.app',
  );
}