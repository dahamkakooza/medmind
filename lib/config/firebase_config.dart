// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/foundation.dart';
//
// class FirebaseConfig {
//   static Future<void> initialize() async {
//     try {
//       await Firebase.initializeApp(
//         options: _getFirebaseOptions(),
//       );
//       if (kDebugMode) {
//         print('Firebase initialized successfully');
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Firebase initialization error: $e');
//       }
//       rethrow;
//     }
//   }
//
//   static FirebaseOptions _getFirebaseOptions() {
//     // TODO: Replace with your Firebase project configuration
//     // Get this from Firebase Console > Project Settings > Your apps
//     if (kIsWeb) {
//       return const FirebaseOptions(
//         apiKey: 'YOUR_WEB_API_KEY',
//         appId: 'YOUR_WEB_APP_ID',
//         messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
//         projectId: 'YOUR_PROJECT_ID',
//         authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
//         storageBucket: 'YOUR_PROJECT_ID.appspot.com',
//       );
//     } else if (defaultTargetPlatform == TargetPlatform.android) {
//       return const FirebaseOptions(
//         apiKey: 'YOUR_ANDROID_API_KEY',
//         appId: 'YOUR_ANDROID_APP_ID',
//         messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
//         projectId: 'YOUR_PROJECT_ID',
//         storageBucket: 'YOUR_PROJECT_ID.appspot.com',
//       );
//     } else if (defaultTargetPlatform == TargetPlatform.iOS) {
//       return const FirebaseOptions(
//         apiKey: 'YOUR_IOS_API_KEY',
//         appId: 'YOUR_IOS_APP_ID',
//         messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
//         projectId: 'YOUR_PROJECT_ID',
//         storageBucket: 'YOUR_PROJECT_ID.appspot.com',
//         iosBundleId: 'com.example.medmind',
//       );
//     }
//
//     throw UnsupportedError('Platform not supported');
//   }
// }
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: _getFirebaseOptions(),
      );
      if (kDebugMode) {
        print('✅ Firebase initialized successfully with project: medmind-ca71d');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Firebase initialization error: $e');
      }
      rethrow;
    }
  }

  static FirebaseOptions _getFirebaseOptions() {
    // REPLACE WITH YOUR ACTUAL FIREBASE CONFIG FROM google-services.json
    return const FirebaseOptions(
      apiKey: 'AIzaSyC_b2w_sJ7_JJRWcoxqcDv1g_hHj0nS8Ew', // From your json
      appId: '1:257346834376:android:7c186269d766fe4d9b7afd', // From your json
      messagingSenderId: '257346834376', // From project_number in json
      projectId: 'medmind-ca71d', // From your json
      storageBucket: 'medmind-ca71d.firebasestorage.app', // From your json
    );
  }
}