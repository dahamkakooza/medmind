import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medmind/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:medmind/core/errors/failures.dart';
import 'dart:math';

// Generate mocks
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  UserCredential,
  User,
  UserMetadata,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
])
import 'auth_verification_tests.mocks.dart';

/// Test data class for user registration
class UserTestData {
  final String email;
  final String password;
  final String displayName;

  UserTestData({
    required this.email,
    required this.password,
    required this.displayName,
  });

  static UserTestData generate() {
    final random = Random();
    final randomId = random.nextInt(999999);
    return UserTestData(
      email: 'test$randomId@medmind.test',
      password: 'TestPass${randomId}123!',
      displayName: 'Test User $randomId',
    );
  }
}

/// Authentication Verification Tests
/// These tests verify the authentication repository logic
/// **Feature: system-verification**
void main() {
  group('Authentication Verification Tests', () {
    late SharedPreferences mockPrefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
    });

    /// **Property 1: Registration creates both Auth and Firestore records**
    /// **Validates: Requirements 1.1**
    test(
      'Property 1: Registration creates both Auth and Firestore records',
      () async {
        // Test with multiple random inputs
        for (int i = 0; i < 50; i++) {
          // Create fresh mocks for each iteration
          final mockAuth = MockFirebaseAuth();
          final mockFirestore = MockFirebaseFirestore();
          final mockUserCredential = MockUserCredential();
          final mockUser = MockUser();
          final mockMetadata = MockUserMetadata();
          final mockCollection =
              MockCollectionReference<Map<String, dynamic>>();
          final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

          final repository = AuthRepositoryImpl(
            firebaseAuth: mockAuth,
            firestore: mockFirestore,
            sharedPreferences: mockPrefs,
          );

          final userData = UserTestData.generate();
          final testUid = 'test_uid_${userData.email}';

          // Setup mocks
          when(mockUser.uid).thenReturn(testUid);
          when(mockUser.email).thenReturn(userData.email);
          when(mockUser.displayName).thenReturn(userData.displayName);
          when(mockUser.emailVerified).thenReturn(false);
          when(mockUser.metadata).thenReturn(mockMetadata);
          when(mockMetadata.creationTime).thenReturn(DateTime.now());
          when(mockUser.updateDisplayName(any)).thenAnswer((_) async => {});
          when(mockUser.sendEmailVerification()).thenAnswer((_) async => {});

          when(mockUserCredential.user).thenReturn(mockUser);

          when(
            mockAuth.createUserWithEmailAndPassword(
              email: userData.email,
              password: userData.password,
            ),
          ).thenAnswer((_) async => mockUserCredential);

          when(mockFirestore.collection('users')).thenReturn(mockCollection);
          when(mockCollection.doc(testUid)).thenReturn(mockDocRef);
          when(mockDocRef.set(any, any)).thenAnswer((_) async => {});

          // Perform registration
          final signUpResult = await repository.signUpWithEmailAndPassword(
            email: userData.email,
            password: userData.password,
            displayName: userData.displayName,
          );

          // Verify registration succeeded
          expect(
            signUpResult.isRight(),
            true,
            reason: 'Registration should succeed for iteration $i',
          );

          // Verify Auth was called
          verify(
            mockAuth.createUserWithEmailAndPassword(
              email: userData.email,
              password: userData.password,
            ),
          ).called(1);

          // Verify display name was updated
          verify(mockUser.updateDisplayName(userData.displayName)).called(1);

          // Verify Firestore was called
          verify(mockFirestore.collection('users')).called(1);
          verify(mockCollection.doc(testUid)).called(1);
          verify(mockDocRef.set(any, any)).called(1);
        }
      },
    );

    /// **Property 2: Valid credentials grant access**
    /// **Validates: Requirements 1.2**
    test('Property 2: Valid credentials grant access', () async {
      // Test with multiple random inputs
      for (int i = 0; i < 50; i++) {
        final mockAuth = MockFirebaseAuth();
        final mockFirestore = MockFirebaseFirestore();
        final mockUserCredential = MockUserCredential();
        final mockUser = MockUser();
        final mockMetadata = MockUserMetadata();
        final mockCollection = MockCollectionReference<Map<String, dynamic>>();
        final mockDocRef = MockDocumentReference<Map<String, dynamic>>();

        final repository = AuthRepositoryImpl(
          firebaseAuth: mockAuth,
          firestore: mockFirestore,
          sharedPreferences: mockPrefs,
        );

        final userData = UserTestData.generate();
        final testUid = 'test_uid_${userData.email}';

        // Setup mocks
        when(mockUser.uid).thenReturn(testUid);
        when(mockUser.email).thenReturn(userData.email);
        when(mockUser.displayName).thenReturn(userData.displayName);
        when(mockUser.emailVerified).thenReturn(true);
        when(mockUser.metadata).thenReturn(mockMetadata);
        when(mockMetadata.creationTime).thenReturn(DateTime.now());

        when(mockUserCredential.user).thenReturn(mockUser);

        when(
          mockAuth.signInWithEmailAndPassword(
            email: userData.email,
            password: userData.password,
          ),
        ).thenAnswer((_) async => mockUserCredential);

        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.doc(testUid)).thenReturn(mockDocRef);
        when(mockDocRef.set(any, any)).thenAnswer((_) async => {});

        // Perform sign in
        final signInResult = await repository.signInWithEmailAndPassword(
          email: userData.email,
          password: userData.password,
        );

        // Should succeed
        expect(
          signInResult.isRight(),
          true,
          reason: 'Sign in should succeed for iteration $i',
        );

        final user = signInResult.getOrElse(() => throw Exception('No user'));

        // Verify user data
        expect(user.email, userData.email);
        expect(user.id, testUid);

        // Verify Auth was called
        verify(
          mockAuth.signInWithEmailAndPassword(
            email: userData.email,
            password: userData.password,
          ),
        ).called(1);
      }
    });

    /// **Property 3: Invalid credentials deny access**
    /// **Validates: Requirements 1.3**
    test('Property 3: Invalid credentials deny access', () async {
      // Test with multiple random inputs
      for (int i = 0; i < 50; i++) {
        final mockAuth = MockFirebaseAuth();
        final mockFirestore = MockFirebaseFirestore();

        final repository = AuthRepositoryImpl(
          firebaseAuth: mockAuth,
          firestore: mockFirestore,
          sharedPreferences: mockPrefs,
        );

        final userData = UserTestData.generate();

        // Setup mock to throw wrong password error
        when(
          mockAuth.signInWithEmailAndPassword(
            email: userData.email,
            password: 'WrongPassword123!',
          ),
        ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        // Try to sign in with wrong password
        final wrongPasswordResult = await repository.signInWithEmailAndPassword(
          email: userData.email,
          password: 'WrongPassword123!',
        );

        // Should fail
        expect(
          wrongPasswordResult.isLeft(),
          true,
          reason: 'Wrong password should fail for iteration $i',
        );

        // Verify it's an authentication failure
        final failure = wrongPasswordResult.fold((l) => l, (r) => null);

        expect(failure, isA<AuthenticationFailure>());

        // Setup mock for non-existent user
        when(
          mockAuth.signInWithEmailAndPassword(
            email: 'nonexistent${userData.email}',
            password: userData.password,
          ),
        ).thenThrow(FirebaseAuthException(code: 'user-not-found'));

        // Try with non-existent email
        final nonExistentResult = await repository.signInWithEmailAndPassword(
          email: 'nonexistent${userData.email}',
          password: userData.password,
        );

        // Should also fail
        expect(
          nonExistentResult.isLeft(),
          true,
          reason: 'Non-existent user should fail for iteration $i',
        );
      }
    });

    /// **Property 13: Authentication state triggers navigation**
    /// **Validates: Requirements 4.2**
    test('Property 13: Authentication state triggers navigation', () async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = MockFirebaseFirestore();
      final mockUser = MockUser();
      final mockMetadata = MockUserMetadata();

      final repository = AuthRepositoryImpl(
        firebaseAuth: mockAuth,
        firestore: mockFirestore,
        sharedPreferences: mockPrefs,
      );

      // Setup auth state stream
      when(
        mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.fromIterable([mockUser]));

      when(mockUser.uid).thenReturn('test_uid');
      when(mockUser.email).thenReturn('test@medmind.test');
      when(mockUser.displayName).thenReturn('Test User');
      when(mockUser.emailVerified).thenReturn(true);
      when(mockUser.metadata).thenReturn(mockMetadata);
      when(mockMetadata.creationTime).thenReturn(DateTime.now());

      bool authStateChanged = false;

      // Listen to auth state changes
      final subscription = repository.user.listen((user) {
        if (user.id.isNotEmpty) {
          authStateChanged = true;
        }
      });

      // Wait for stream to emit
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify state changed
      expect(authStateChanged, true);

      await subscription.cancel();
    });

    /// **Property 38: Authentication errors are specific**
    /// **Validates: Requirements 11.4**
    test('Property 38: Authentication errors are specific', () async {
      // Test with multiple random inputs
      for (int i = 0; i < 50; i++) {
        final mockAuth = MockFirebaseAuth();
        final mockFirestore = MockFirebaseFirestore();

        final repository = AuthRepositoryImpl(
          firebaseAuth: mockAuth,
          firestore: mockFirestore,
          sharedPreferences: mockPrefs,
        );

        final userData = UserTestData.generate();

        // Test wrong password error
        when(
          mockAuth.signInWithEmailAndPassword(
            email: userData.email,
            password: 'WrongPassword123!',
          ),
        ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        final wrongPasswordResult = await repository.signInWithEmailAndPassword(
          email: userData.email,
          password: 'WrongPassword123!',
        );

        expect(wrongPasswordResult.isLeft(), true);

        final wrongPasswordFailure = wrongPasswordResult.fold(
          (l) => l,
          (r) => null,
        );

        // Should contain specific message about wrong password
        expect(wrongPasswordFailure, isNotNull);
        expect(
          wrongPasswordFailure!.message.toLowerCase().contains('password'),
          true,
          reason: 'Error message should mention password for iteration $i',
        );

        // Test user not found error
        when(
          mockAuth.signInWithEmailAndPassword(
            email: 'nonexistent${userData.email}',
            password: userData.password,
          ),
        ).thenThrow(FirebaseAuthException(code: 'user-not-found'));

        final notFoundResult = await repository.signInWithEmailAndPassword(
          email: 'nonexistent${userData.email}',
          password: userData.password,
        );

        expect(notFoundResult.isLeft(), true);

        final notFoundFailure = notFoundResult.fold((l) => l, (r) => null);

        // Should contain specific message about user not found
        expect(notFoundFailure, isNotNull);
        expect(
          notFoundFailure!.message.toLowerCase().contains('user') ||
              notFoundFailure.message.toLowerCase().contains('found'),
          true,
          reason: 'Error message should mention user/found for iteration $i',
        );
      }
    });

    /// **Integration Test for Google Sign-In**
    /// **Validates: Requirements 1.4**
    test('Google Sign-In handles cancellation gracefully', () async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = MockFirebaseFirestore();

      final repository = AuthRepositoryImpl(
        firebaseAuth: mockAuth,
        firestore: mockFirestore,
        sharedPreferences: mockPrefs,
      );

      // Simulate Google Sign-In cancellation (GoogleSignIn returns null)
      final result = await repository.signInWithGoogle();

      // Should fail gracefully
      expect(result.isLeft(), true);

      result.fold((failure) {
        expect(failure, isA<AuthenticationFailure>());
        expect(failure.message, isNotEmpty);
      }, (user) => fail('Should not succeed without Google Sign-In setup'));
    });

    /// **Integration Test for Password Reset**
    /// **Validates: Requirements 1.5**
    test('Password reset email sending', () async {
      final mockAuth = MockFirebaseAuth();
      final mockFirestore = MockFirebaseFirestore();

      final repository = AuthRepositoryImpl(
        firebaseAuth: mockAuth,
        firestore: mockFirestore,
        sharedPreferences: mockPrefs,
      );

      const testEmail = 'passwordreset@medmind.test';

      // Setup mock for successful password reset
      when(
        mockAuth.sendPasswordResetEmail(email: testEmail),
      ).thenAnswer((_) async => {});

      // Send password reset email
      final result = await repository.sendPasswordResetEmail(testEmail);

      // Should succeed
      expect(result.isRight(), true);

      // Verify Auth was called
      verify(mockAuth.sendPasswordResetEmail(email: testEmail)).called(1);

      // Test with non-existent email
      const nonExistentEmail = 'nonexistent@medmind.test';
      when(
        mockAuth.sendPasswordResetEmail(email: nonExistentEmail),
      ).thenThrow(FirebaseAuthException(code: 'user-not-found'));

      final nonExistentResult = await repository.sendPasswordResetEmail(
        nonExistentEmail,
      );

      // Should fail with user not found
      expect(nonExistentResult.isLeft(), true);

      nonExistentResult.fold((failure) {
        expect(failure, isA<AuthenticationFailure>());
        expect(
          failure.message.toLowerCase().contains('user') ||
              failure.message.toLowerCase().contains('found'),
          true,
        );
      }, (_) => fail('Should fail for non-existent user'));
    });
  });
}
