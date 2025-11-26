import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/firebase_test_helper.dart';
import '../../utils/property_test_framework.dart';
import '../../utils/mock_data_generators.dart';

/// **Feature: system-verification, Property 21: Users can only access their own data**
/// **Validates: Requirements 6.1, 6.2**
///
/// **Feature: system-verification, Property 22: Unauthenticated requests are denied**
/// **Validates: Requirements 6.3**
///
/// **Feature: system-verification, Property 23: Invalid data is rejected by security rules**
/// **Validates: Requirements 6.4**
void main() {
  // Initialize Flutter bindings for Firebase
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Firebase Security Rules Verification', () {
    bool emulatorsAvailable = false;

    setUpAll(() async {
      try {
        await FirebaseTestHelper.connectToEmulators();
        emulatorsAvailable = true;
      } catch (e) {
        // ignore: avoid_print
        print(
          '⚠️  Firebase emulators not available. Skipping security rules tests.',
        );
        // ignore: avoid_print
        print(
          '   To run these tests, start Firebase emulators with: firebase emulators:start',
        );
        emulatorsAvailable = false;
      }
    });

    tearDown(() async {
      if (emulatorsAvailable) {
        try {
          await FirebaseTestHelper.cleanup();
        } catch (e) {
          // Ignore cleanup errors if emulators aren't available
        }
      }
    });

    group('Property 21: Users can only access their own data', () {
      propertyTest<String>(
        'Authenticated users can read and write their own data',
        skip: !emulatorsAvailable ? 'Firebase emulators not available' : null,
        generator: () {
          // Generate a unique email for each test iteration
          return randomEmail();
        },
        property: (email) async {
          final medication = MockDataGenerators.generateMedication();

          // Create test user
          final userCredential = await FirebaseTestHelper.createTestUser(
            email: email,
            password: 'testPassword123',
          );
          final userId = userCredential.user!.uid;

          final firestore = FirebaseFirestore.instance;

          try {
            // Test: User can write their own user document
            await firestore.collection('users').doc(userId).set({
              'email': email,
              'displayName': 'Test User',
              'createdAt': FieldValue.serverTimestamp(),
            });

            // Test: User can read their own user document
            final userDoc = await firestore
                .collection('users')
                .doc(userId)
                .get();
            if (!userDoc.exists) return false;

            // Test: User can create their own medication
            final medicationRef = await firestore
                .collection('medications')
                .add({
                  'userId': userId,
                  'name': medication.name,
                  'dosage': medication.dosage,
                  'form': medication.form.toString(),
                  'frequency': medication.frequency.toString(),
                  'isActive': medication.isActive,
                  'createdAt': FieldValue.serverTimestamp(),
                });

            // Test: User can read their own medication
            final medicationDoc = await medicationRef.get();
            if (!medicationDoc.exists) return false;
            if (medicationDoc.data()!['userId'] != userId) return false;

            // Test: User can update their own medication
            await medicationRef.update({'name': 'Updated Medication'});
            final updatedDoc = await medicationRef.get();
            if (updatedDoc.data()!['name'] != 'Updated Medication') {
              return false;
            }

            // Test: User can delete their own medication
            await medicationRef.delete();
            final deletedDoc = await medicationRef.get();
            if (deletedDoc.exists) return false;

            return true;
          } catch (e) {
            // Any security rule violation should fail the test
            return false;
          }
        },
        config: const PropertyTestConfig(iterations: 20),
      );

      propertyTest<Map<String, String>>(
        'Users cannot access other users\' data',
        skip: !emulatorsAvailable ? 'Firebase emulators not available' : null,
        generator: () {
          // Generate two unique emails for each test iteration
          return {'email1': randomEmail(), 'email2': randomEmail()};
        },
        property: (emails) async {
          final email1 = emails['email1']!;
          final email2 = emails['email2']!;
          final medication = MockDataGenerators.generateMedication();

          // Create two test users
          await FirebaseTestHelper.createTestUser(
            email: email1,
            password: 'testPassword123',
          );

          final user2Credential = await FirebaseTestHelper.createTestUser(
            email: email2,
            password: 'testPassword456',
          );
          final user2Id = user2Credential.user!.uid;

          final firestore = FirebaseFirestore.instance;

          // User 2 creates their own medication
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email2,
            password: 'testPassword456',
          );
          final medicationRef = await firestore.collection('medications').add({
            'userId': user2Id,
            'name': medication.name,
            'dosage': medication.dosage,
            'form': medication.form.toString(),
            'frequency': medication.frequency.toString(),
            'isActive': medication.isActive,
            'createdAt': FieldValue.serverTimestamp(),
          });
          final medicationId = medicationRef.id;

          // User 2 creates their user document
          await firestore.collection('users').doc(user2Id).set({
            'email': email2,
            'displayName': 'User 2',
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Switch to User 1
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email1,
            password: 'testPassword123',
          );

          try {
            // Test: User 1 should NOT be able to read User 2's user document
            await firestore.collection('users').doc(user2Id).get();
            // If we get here without exception, security rules failed
            return false;
          } catch (e) {
            // Expected: permission denied
            if (!e.toString().contains('permission-denied') &&
                !e.toString().contains('PERMISSION_DENIED')) {
              return false;
            }
          }

          try {
            // Test: User 1 should NOT be able to read User 2's medication
            await firestore.collection('medications').doc(medicationId).get();
            // If we get here without exception, security rules failed
            return false;
          } catch (e) {
            // Expected: permission denied
            if (!e.toString().contains('permission-denied') &&
                !e.toString().contains('PERMISSION_DENIED')) {
              return false;
            }
          }

          try {
            // Test: User 1 should NOT be able to update User 2's medication
            await firestore.collection('medications').doc(medicationId).update({
              'name': 'Hacked Medication',
            });
            // If we get here without exception, security rules failed
            return false;
          } catch (e) {
            // Expected: permission denied
            if (!e.toString().contains('permission-denied') &&
                !e.toString().contains('PERMISSION_DENIED')) {
              return false;
            }
          }

          try {
            // Test: User 1 should NOT be able to delete User 2's medication
            await firestore
                .collection('medications')
                .doc(medicationId)
                .delete();
            // If we get here without exception, security rules failed
            return false;
          } catch (e) {
            // Expected: permission denied
            if (!e.toString().contains('permission-denied') &&
                !e.toString().contains('PERMISSION_DENIED')) {
              return false;
            }
          }

          // All access attempts were properly denied
          return true;
        },
        config: const PropertyTestConfig(iterations: 20),
      );
    });

    group('Property 22: Unauthenticated requests are denied', () {
      propertyTest<String>(
        'Unauthenticated users cannot access protected data',
        skip: !emulatorsAvailable ? 'Firebase emulators not available' : null,
        generator: () {
          return randomEmail();
        },
        property: (email) async {
          final medication = MockDataGenerators.generateMedication();

          // Create a user and their data while authenticated
          final userCredential = await FirebaseTestHelper.createTestUser(
            email: email,
            password: 'testPassword123',
          );
          final userId = userCredential.user!.uid;

          final firestore = FirebaseFirestore.instance;

          // Create user document and medication while authenticated
          await firestore.collection('users').doc(userId).set({
            'email': email,
            'displayName': 'Test User',
            'createdAt': FieldValue.serverTimestamp(),
          });

          final medicationRef = await firestore.collection('medications').add({
            'userId': userId,
            'name': medication.name,
            'dosage': medication.dosage,
            'form': medication.form.toString(),
            'frequency': medication.frequency.toString(),
            'isActive': medication.isActive,
            'createdAt': FieldValue.serverTimestamp(),
          });
          final medicationId = medicationRef.id;

          // Sign out to become unauthenticated
          await FirebaseAuth.instance.signOut();

          // Test: Unauthenticated user should NOT be able to read user documents
          try {
            await firestore.collection('users').doc(userId).get();
            return false; // Should have thrown exception
          } catch (e) {
            if (!e.toString().contains('permission-denied') &&
                !e.toString().contains('PERMISSION_DENIED')) {
              return false;
            }
          }

          // Test: Unauthenticated user should NOT be able to read medications
          try {
            await firestore.collection('medications').doc(medicationId).get();
            return false; // Should have thrown exception
          } catch (e) {
            if (!e.toString().contains('permission-denied') &&
                !e.toString().contains('PERMISSION_DENIED')) {
              return false;
            }
          }

          // Test: Unauthenticated user should NOT be able to create medications
          try {
            await firestore.collection('medications').add({
              'userId': userId,
              'name': 'Hacked Med',
              'dosage': '100mg',
              'form': 'tablet',
              'frequency': 'daily',
              'isActive': true,
              'createdAt': FieldValue.serverTimestamp(),
            });
            return false; // Should have thrown exception
          } catch (e) {
            if (!e.toString().contains('permission-denied') &&
                !e.toString().contains('PERMISSION_DENIED')) {
              return false;
            }
          }

          // Test: Unauthenticated user should NOT be able to update medications
          try {
            await firestore.collection('medications').doc(medicationId).update({
              'name': 'Hacked',
            });
            return false; // Should have thrown exception
          } catch (e) {
            if (!e.toString().contains('permission-denied') &&
                !e.toString().contains('PERMISSION_DENIED')) {
              return false;
            }
          }

          // Test: Unauthenticated user should NOT be able to delete medications
          try {
            await firestore
                .collection('medications')
                .doc(medicationId)
                .delete();
            return false; // Should have thrown exception
          } catch (e) {
            if (!e.toString().contains('permission-denied') &&
                !e.toString().contains('PERMISSION_DENIED')) {
              return false;
            }
          }

          // All unauthenticated access attempts were properly denied
          return true;
        },
        config: const PropertyTestConfig(iterations: 20),
      );
    });

    group('Property 23: Invalid data is rejected by security rules', () {
      propertyTest<String>(
        'Medications with wrong userId are rejected',
        skip: !emulatorsAvailable ? 'Firebase emulators not available' : null,
        generator: () {
          return randomEmail();
        },
        property: (email) async {
          final medication = MockDataGenerators.generateMedication();

          // Create and sign in as test user
          await FirebaseTestHelper.createTestUser(
            email: email,
            password: 'testPassword123',
          );

          final firestore = FirebaseFirestore.instance;

          // Generate a wrong userId (not matching authenticated user)
          final wrongUserId =
              'wrong-user-id-${DateTime.now().millisecondsSinceEpoch}';

          try {
            // Test: Creating medication with wrong userId should be rejected
            await firestore.collection('medications').add({
              'userId': wrongUserId,
              'name': medication.name,
              'dosage': medication.dosage,
              'form': medication.form.toString(),
              'frequency': medication.frequency.toString(),
              'isActive': medication.isActive,
              'createdAt': FieldValue.serverTimestamp(),
            });
            // If we get here, security rules failed
            return false;
          } catch (e) {
            // Expected: permission denied because userId doesn't match auth.uid
            if (!e.toString().contains('permission-denied') &&
                !e.toString().contains('PERMISSION_DENIED')) {
              return false;
            }
          }

          // Test: Creating adherence log with wrong userId should be rejected
          try {
            await firestore.collection('adherence_logs').add({
              'userId': wrongUserId,
              'medicationId': 'some-medication-id',
              'status': 'taken',
              'scheduledTime': Timestamp.now(),
              'takenTime': Timestamp.now(),
            });
            // If we get here, security rules failed
            return false;
          } catch (e) {
            // Expected: permission denied
            if (!e.toString().contains('permission-denied') &&
                !e.toString().contains('PERMISSION_DENIED')) {
              return false;
            }
          }

          // All invalid data was properly rejected
          return true;
        },
        config: const PropertyTestConfig(iterations: 20),
      );
    });
  });
}
