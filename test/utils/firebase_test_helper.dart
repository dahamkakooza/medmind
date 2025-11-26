library firebase_test_helper;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Firebase emulator configuration
class FirebaseEmulatorConfig {
  static const String authHost = 'localhost';
  static const int authPort = 9099;

  static const String firestoreHost = 'localhost';
  static const int firestorePort = 8080;

  static const String storageHost = 'localhost';
  static const int storagePort = 9199;
}

/// Firebase test helper for managing emulator connections
class FirebaseTestHelper {
  static bool _initialized = false;

  /// Initialize Firebase for testing with emulators
  ///
  /// This should be called once before running integration tests
  static Future<void> initializeFirebaseForTesting() async {
    if (_initialized) {
      return;
    }

    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-sender-id',
          projectId: 'test-project',
          storageBucket: 'test-bucket',
        ),
      );
      _initialized = true;
    } catch (e) {
      // Firebase already initialized - this is okay
      _initialized = true;
      if (kDebugMode) {
        print('Firebase already initialized: $e');
      }
    }
  }

  /// Connect to Firebase emulators
  ///
  /// Call this in setUp() for integration tests that need Firebase
  static Future<void> connectToEmulators() async {
    await initializeFirebaseForTesting();

    // Connect Auth to emulator
    try {
      await FirebaseAuth.instance.useAuthEmulator(
        FirebaseEmulatorConfig.authHost,
        FirebaseEmulatorConfig.authPort,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Auth emulator already connected: $e');
      }
    }

    // Connect Firestore to emulator
    try {
      FirebaseFirestore.instance.useFirestoreEmulator(
        FirebaseEmulatorConfig.firestoreHost,
        FirebaseEmulatorConfig.firestorePort,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Firestore emulator already connected: $e');
      }
    }

    // Connect Storage to emulator
    try {
      await FirebaseStorage.instance.useStorageEmulator(
        FirebaseEmulatorConfig.storageHost,
        FirebaseEmulatorConfig.storagePort,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Storage emulator already connected: $e');
      }
    }
  }

  /// Clear all Firestore data
  ///
  /// Useful for cleaning up between tests
  static Future<void> clearFirestoreData() async {
    final firestore = FirebaseFirestore.instance;

    // Clear common collections
    final collections = ['users', 'medications', 'adherence_logs', 'profiles'];

    for (final collection in collections) {
      final snapshot = await firestore.collection(collection).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  }

  /// Clear all Auth users
  ///
  /// Note: This requires the Auth emulator REST API
  static Future<void> clearAuthUsers() async {
    // In a real implementation, you would call the emulator REST API
    // For now, we'll just sign out the current user
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }

  /// Create a test user in Auth emulator
  static Future<UserCredential> createTestUser({
    required String email,
    required String password,
  }) async {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in a test user
  static Future<UserCredential> signInTestUser({
    required String email,
    required String password,
  }) async {
    return await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Get current authenticated user
  static User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }

  /// Create a test document in Firestore
  static Future<DocumentReference> createTestDocument({
    required String collection,
    required Map<String, dynamic> data,
    String? documentId,
  }) async {
    final firestore = FirebaseFirestore.instance;

    if (documentId != null) {
      final docRef = firestore.collection(collection).doc(documentId);
      await docRef.set(data);
      return docRef;
    } else {
      return await firestore.collection(collection).add(data);
    }
  }

  /// Get a test document from Firestore
  static Future<DocumentSnapshot> getTestDocument({
    required String collection,
    required String documentId,
  }) async {
    return await FirebaseFirestore.instance
        .collection(collection)
        .doc(documentId)
        .get();
  }

  /// Clean up all test data
  ///
  /// Call this in tearDown() for integration tests
  static Future<void> cleanup() async {
    await clearFirestoreData();
    await clearAuthUsers();
  }
}

/// Test user credentials for consistent testing
class TestUserCredentials {
  static const String email = 'test@medmind.com';
  static const String password = 'testPassword123';
  static const String displayName = 'Test User';

  static const String email2 = 'test2@medmind.com';
  static const String password2 = 'testPassword456';
  static const String displayName2 = 'Test User 2';
}
