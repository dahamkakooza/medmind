import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Test class to verify Firebase and Firestore connection
///
/// Usage:
/// ```dart
/// await FirebaseConnectionTest.testConnection();
/// ```
class FirebaseConnectionTest {
  /// Test basic Firebase connection and CRUD operations
  static Future<void> testConnection() async {
    try {
      print('🔵 Starting Firebase connection test...');

      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      final testDocRef = firestore.collection('test').doc('connection');

      // CREATE - Test writing to Firestore
      await testDocRef.set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'connected',
        'testMessage': 'Firebase connection test successful',
      });
      print('✅ Firestore CREATE successful!');

      // READ - Test reading from Firestore
      final doc = await testDocRef.get();
      if (doc.exists) {
        print('✅ Firestore READ successful: ${doc.data()}');
      } else {
        print('⚠️ Document not found after creation');
      }

      // UPDATE - Test updating document
      await testDocRef.update({
        'status': 'updated',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Firestore UPDATE successful!');

      // Test Auth
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        print('✅ Firebase Auth: User logged in - ${currentUser.uid}');
      } else {
        print('ℹ️ Firebase Auth: No user logged in (this is OK for testing)');
      }

      // DELETE - Clean up test document
      await testDocRef.delete();
      print('✅ Firestore DELETE successful!');

      print('✅ All Firebase tests passed!');
    } catch (e, stackTrace) {
      print('❌ Firebase connection error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Test medication CRUD operations
  static Future<void> testMedicationCRUD() async {
    try {
      print('🔵 Starting Medication CRUD test...');

      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      final userId =
          auth.currentUser?.uid ??
          'test-user-${DateTime.now().millisecondsSinceEpoch}';

      // CREATE - Add a test medication
      final medicationRef = firestore.collection('medications').doc();
      await medicationRef.set({
        'userId': userId,
        'name': 'Test Medication',
        'dosage': '10mg',
        'form': 'tablet',
        'frequency': 'daily',
        'times': [
          {'hour': 8, 'minute': 0},
        ],
        'days': [1, 2, 3, 4, 5, 6, 7],
        'startDate': Timestamp.now(),
        'isActive': true,
        'refillReminder': false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      print('✅ Medication CREATE successful: ${medicationRef.id}');

      // READ - Query medications
      final medications = await firestore
          .collection('medications')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();
      print(
        '✅ Medication READ successful: Found ${medications.docs.length} medications',
      );

      // UPDATE - Update medication
      await medicationRef.update({
        'name': 'Updated Test Medication',
        'updatedAt': Timestamp.now(),
      });
      print('✅ Medication UPDATE successful');

      // DELETE (soft delete) - Set isActive to false
      await medicationRef.update({
        'isActive': false,
        'updatedAt': Timestamp.now(),
      });
      print('✅ Medication DELETE (soft) successful');

      // Clean up - Hard delete test medication
      await medicationRef.delete();
      print('✅ Test medication cleaned up');

      print('✅ All Medication CRUD tests passed!');
    } catch (e, stackTrace) {
      print('❌ Medication CRUD test error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Test adherence log operations
  static Future<void> testAdherenceLogCRUD() async {
    try {
      print('🔵 Starting Adherence Log CRUD test...');

      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;
      final userId =
          auth.currentUser?.uid ??
          'test-user-${DateTime.now().millisecondsSinceEpoch}';
      final medicationId = 'test-medication-123';

      // CREATE - Add a test adherence log
      final logRef = firestore.collection('adherence_logs').doc();
      await logRef.set({
        'userId': userId,
        'medicationId': medicationId,
        'scheduledTime': Timestamp.now(),
        'takenTime': Timestamp.now(),
        'status': 'taken',
        'createdAt': Timestamp.now(),
      });
      print('✅ Adherence Log CREATE successful: ${logRef.id}');

      // READ - Query adherence logs
      final logs = await firestore
          .collection('adherence_logs')
          .where('userId', isEqualTo: userId)
          .orderBy('scheduledTime', descending: true)
          .limit(10)
          .get();
      print('✅ Adherence Log READ successful: Found ${logs.docs.length} logs');

      // UPDATE - Update log
      await logRef.update({'status': 'missed', 'takenTime': null});
      print('✅ Adherence Log UPDATE successful');

      // Clean up - Delete test log
      await logRef.delete();
      print('✅ Test adherence log cleaned up');

      print('✅ All Adherence Log CRUD tests passed!');
    } catch (e, stackTrace) {
      print('❌ Adherence Log CRUD test error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Run all tests
  static Future<void> runAllTests() async {
    try {
      await testConnection();
      await Future.delayed(const Duration(seconds: 1));
      await testMedicationCRUD();
      await Future.delayed(const Duration(seconds: 1));
      await testAdherenceLogCRUD();
      print('\n🎉 All Firebase tests completed successfully!');
    } catch (e) {
      print('\n❌ Some tests failed. Check the errors above.');
      rethrow;
    }
  }
}
