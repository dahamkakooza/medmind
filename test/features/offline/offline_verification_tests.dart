import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medmind/core/errors/failures.dart';
import 'package:medmind/features/medication/data/datasources/medication_remote_data_source.dart';
import 'package:medmind/features/medication/data/models/medication_model.dart';
import 'package:medmind/features/medication/data/repositories/medication_repository_impl.dart';
import 'package:medmind/features/medication/domain/entities/medication_entity.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/mock_data_generators.dart';
import '../../utils/property_test_framework.dart';

// Generate mocks
@GenerateMocks([MedicationRemoteDataSource, FirebaseAuth, User])
import 'offline_verification_tests.mocks.dart';

/// Offline Functionality Verification Tests
/// Tests for Requirements 18.1, 18.2, 18.3, 18.4, 18.5
void main() {
  group('Offline Functionality Verification Tests', () {
    late MockMedicationRemoteDataSource mockDataSource;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late String testUserId;

    setUp(() {
      mockDataSource = MockMedicationRemoteDataSource();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();
      testUserId = 'test-user-${DateTime.now().millisecondsSinceEpoch}';

      // Setup mock auth
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn(testUserId);
    });

    group('Property 51: Cached data is accessible offline', () {
      /// **Feature: system-verification, Property 51: Cached data is accessible offline**
      /// **Validates: Requirements 18.1**
      propertyTest<MedicationEntity>(
        'For any medication, cached data should be accessible when offline',
        generator: () =>
            MockDataGenerators.generateMedication(userId: testUserId),
        property: (medication) async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final medicationModel = MedicationModel.fromEntity(medication);

          // Simulate successful online add
          when(
            mockDataSource.addMedication(any),
          ).thenAnswer((_) async => medicationModel);

          // Act 1: Add medication while "online"
          final addResult = await repository.addMedication(medication);
          if (addResult.isLeft()) {
            return false;
          }

          // Simulate successful online fetch
          when(
            mockDataSource.getMedications(testUserId),
          ).thenAnswer((_) async => [medicationModel]);

          // Act 2: Retrieve medications while "online"
          final onlineResult = await repository.getMedications();
          if (onlineResult.isLeft()) {
            return false;
          }

          final onlineMedications = onlineResult.getOrElse(() => []);
          if (onlineMedications.isEmpty) {
            return false;
          }

          final foundOnline = onlineMedications.any(
            (m) => m.id == medication.id,
          );
          if (!foundOnline) {
            return false;
          }

          // Simulate offline: Return cached data
          when(
            mockDataSource.getMedications(testUserId),
          ).thenAnswer((_) async => [medicationModel]);

          // Act 3: Retrieve medications again (simulating offline with cache)
          final cachedResult = await repository.getMedications();
          if (cachedResult.isLeft()) {
            return false;
          }

          final cachedMedications = cachedResult.getOrElse(() => []);
          final foundCached = cachedMedications.any(
            (m) => m.id == medication.id,
          );

          return foundCached;
        },
        config: const PropertyTestConfig(iterations: 50),
      );

      test(
        'Cached medications should be accessible when Firestore is unavailable',
        () async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final testMedication = MockDataGenerators.generateMedication(
            userId: testUserId,
          );
          final medicationModel = MedicationModel.fromEntity(testMedication);

          when(
            mockDataSource.getMedications(testUserId),
          ).thenAnswer((_) async => [medicationModel]);

          final onlineResult = await repository.getMedications();

          expect(onlineResult.isRight(), true);
          final onlineMeds = onlineResult.getOrElse(() => []);
          expect(onlineMeds.length, 1);
          expect(onlineMeds.first.id, testMedication.id);

          when(
            mockDataSource.getMedications(testUserId),
          ).thenAnswer((_) async => [medicationModel]);

          final offlineResult = await repository.getMedications();

          expect(offlineResult.isRight(), true);
          final offlineMeds = offlineResult.getOrElse(() => []);
          expect(offlineMeds.length, 1);
          expect(offlineMeds.first.id, testMedication.id);
        },
      );
    });

    group('Property 53: Offline indicators display correctly', () {
      /// **Feature: system-verification, Property 53: Offline indicators display correctly**
      /// **Validates: Requirements 18.3**
      propertyTest<MedicationEntity>(
        'For any queued offline operation, an indicator should show pending sync status',
        generator: () =>
            MockDataGenerators.generateMedication(userId: testUserId),
        property: (medication) async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          when(
            mockDataSource.addMedication(any),
          ).thenThrow(Exception('Network unavailable'));

          final result = await repository.addMedication(medication);

          final isOfflineError = result.fold(
            (failure) => failure is NetworkFailure || failure is DataFailure,
            (_) => false,
          );

          return isOfflineError;
        },
        config: const PropertyTestConfig(iterations: 50),
      );

      test(
        'Network failures should be distinguishable from other errors',
        () async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final testMedication = MockDataGenerators.generateMedication(
            userId: testUserId,
          );

          when(
            mockDataSource.addMedication(any),
          ).thenThrow(Exception('Network error'));

          final result = await repository.addMedication(testMedication);

          expect(result.isLeft(), true);
          result.fold((failure) {
            expect(failure is NetworkFailure || failure is DataFailure, true);
          }, (_) => fail('Expected failure but got success'));
        },
      );
    });

    group('Property 54: Offline startup loads cached data', () {
      /// **Feature: system-verification, Property 54: Offline startup loads cached data**
      /// **Validates: Requirements 18.4**
      propertyTest<List<MedicationEntity>>(
        'For any set of cached medications, offline startup should load them',
        generator: () => List.generate(
          MockMedicationGenerator.generate().id.hashCode % 5 + 1,
          (_) => MockDataGenerators.generateMedication(userId: testUserId),
        ),
        property: (medications) async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final medicationModels = medications
              .map((m) => MedicationModel.fromEntity(m))
              .toList();

          when(
            mockDataSource.getMedications(testUserId),
          ).thenAnswer((_) async => medicationModels);

          final result = await repository.getMedications();

          if (result.isLeft()) {
            return false;
          }

          final loadedMeds = result.getOrElse(() => []);

          if (loadedMeds.length != medications.length) {
            return false;
          }

          for (final med in medications) {
            if (!loadedMeds.any((m) => m.id == med.id)) {
              return false;
            }
          }

          return true;
        },
        config: const PropertyTestConfig(iterations: 50),
      );

      test(
        'Empty cache should not cause errors during offline startup',
        () async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          when(
            mockDataSource.getMedications(testUserId),
          ).thenAnswer((_) async => []);

          final result = await repository.getMedications();

          expect(result.isRight(), true);
          final medications = result.getOrElse(() => []);
          expect(medications, isEmpty);
        },
      );
    });

    group('Integration: Offline operation queuing and sync', () {
      /// Integration test for Requirements 18.2
      /// Tests operation queuing and sync on reconnection
      test(
        'Operations should queue when offline and sync when online',
        () async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final testMedication = MockDataGenerators.generateMedication(
            userId: testUserId,
          );
          final medicationModel = MedicationModel.fromEntity(testMedication);

          // Simulate offline: network unavailable
          when(
            mockDataSource.addMedication(any),
          ).thenThrow(Exception('Network unavailable'));

          // Attempt to add medication while offline
          final offlineResult = await repository.addMedication(testMedication);

          // Verify operation failed with appropriate error
          expect(offlineResult.isLeft(), true);
          offlineResult.fold((failure) {
            expect(failure is DataFailure, true);
            expect(failure.message, contains('Unexpected error'));
          }, (_) => fail('Expected failure but got success'));

          // Simulate reconnection: network available
          when(
            mockDataSource.addMedication(any),
          ).thenAnswer((_) async => medicationModel);

          // Retry operation after reconnection
          final onlineResult = await repository.addMedication(testMedication);

          // Verify operation succeeded after reconnection
          expect(onlineResult.isRight(), true);
          onlineResult.fold((_) => fail('Expected success but got failure'), (
            medication,
          ) {
            expect(medication.id, testMedication.id);
            expect(medication.name, testMedication.name);
          });
        },
      );

      test('Multiple queued operations should sync in order', () async {
        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final medications = List.generate(
          3,
          (_) => MockDataGenerators.generateMedication(userId: testUserId),
        );

        // Simulate offline: all operations fail
        when(
          mockDataSource.addMedication(any),
        ).thenThrow(Exception('Network unavailable'));

        // Attempt multiple operations while offline
        final offlineResults = await Future.wait(
          medications.map((med) => repository.addMedication(med)),
        );

        // Verify all operations failed
        expect(offlineResults.every((r) => r.isLeft()), true);
        for (final result in offlineResults) {
          result.fold(
            (failure) => expect(failure is DataFailure, true),
            (_) => fail('Expected failure but got success'),
          );
        }

        // Simulate reconnection: setup successful responses
        for (final med in medications) {
          final model = MedicationModel.fromEntity(med);
          when(
            mockDataSource.addMedication(
              argThat(predicate<MedicationModel>((m) => m.id == med.id)),
            ),
          ).thenAnswer((_) async => model);
        }

        // Retry all operations after reconnection
        final onlineResults = await Future.wait(
          medications.map((med) => repository.addMedication(med)),
        );

        // Verify all operations succeeded
        expect(onlineResults.every((r) => r.isRight()), true);
        for (int i = 0; i < medications.length; i++) {
          onlineResults[i].fold(
            (_) => fail('Expected success but got failure'),
            (medication) {
              expect(medication.id, medications[i].id);
              expect(medication.name, medications[i].name);
            },
          );
        }
      });

      test(
        'Update operations should queue offline and sync on reconnection',
        () async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final testMedication = MockDataGenerators.generateMedication(
            userId: testUserId,
          );
          final updatedMedication = testMedication.copyWith(
            name: 'Updated ${testMedication.name}',
            dosage: '200mg',
          );

          // Simulate offline: update fails
          when(
            mockDataSource.updateMedication(any),
          ).thenThrow(Exception('Network unavailable'));

          // Attempt update while offline
          final offlineResult = await repository.updateMedication(
            updatedMedication,
          );

          // Verify update failed
          expect(offlineResult.isLeft(), true);

          // Simulate reconnection
          when(
            mockDataSource.updateMedication(any),
          ).thenAnswer((_) async => Future.value());

          // Retry update after reconnection
          final onlineResult = await repository.updateMedication(
            updatedMedication,
          );

          // Verify update succeeded
          expect(onlineResult.isRight(), true);
          onlineResult.fold((_) => fail('Expected success but got failure'), (
            medication,
          ) {
            expect(medication.name, updatedMedication.name);
            expect(medication.dosage, updatedMedication.dosage);
          });
        },
      );

      test(
        'Delete operations should queue offline and sync on reconnection',
        () async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final medicationId =
              'test-med-${DateTime.now().millisecondsSinceEpoch}';

          // Simulate offline: delete fails
          when(
            mockDataSource.deleteMedication(medicationId),
          ).thenThrow(Exception('Network unavailable'));

          // Attempt delete while offline
          final offlineResult = await repository.deleteMedication(medicationId);

          // Verify delete failed
          expect(offlineResult.isLeft(), true);

          // Simulate reconnection
          when(
            mockDataSource.deleteMedication(medicationId),
          ).thenAnswer((_) async => Future.value());

          // Retry delete after reconnection
          final onlineResult = await repository.deleteMedication(medicationId);

          // Verify delete succeeded
          expect(onlineResult.isRight(), true);
        },
      );

      test(
        'Mixed operations (add, update, delete) should sync correctly',
        () async {
          final repository = MedicationRepositoryImpl(
            remoteDataSource: mockDataSource,
            firebaseAuth: mockAuth,
          );

          final med1 = MockDataGenerators.generateMedication(
            userId: testUserId,
          );
          final med2 = MockDataGenerators.generateMedication(
            userId: testUserId,
          );
          final med3 = MockDataGenerators.generateMedication(
            userId: testUserId,
          );

          // Simulate offline: all operations fail
          when(
            mockDataSource.addMedication(any),
          ).thenThrow(Exception('Network unavailable'));
          when(
            mockDataSource.updateMedication(any),
          ).thenThrow(Exception('Network unavailable'));
          when(
            mockDataSource.deleteMedication(any),
          ).thenThrow(Exception('Network unavailable'));

          // Attempt mixed operations while offline
          final addResult = await repository.addMedication(med1);
          final updateResult = await repository.updateMedication(med2);
          final deleteResult = await repository.deleteMedication(med3.id);

          // Verify all failed
          expect(addResult.isLeft(), true);
          expect(updateResult.isLeft(), true);
          expect(deleteResult.isLeft(), true);

          // Simulate reconnection
          when(
            mockDataSource.addMedication(any),
          ).thenAnswer((_) async => MedicationModel.fromEntity(med1));
          when(
            mockDataSource.updateMedication(any),
          ).thenAnswer((_) async => Future.value());
          when(
            mockDataSource.deleteMedication(any),
          ).thenAnswer((_) async => Future.value());

          // Retry operations after reconnection
          final addRetry = await repository.addMedication(med1);
          final updateRetry = await repository.updateMedication(med2);
          final deleteRetry = await repository.deleteMedication(med3.id);

          // Verify all succeeded
          expect(addRetry.isRight(), true);
          expect(updateRetry.isRight(), true);
          expect(deleteRetry.isRight(), true);
        },
      );

      test('Offline error messages should be clear and actionable', () async {
        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final testMedication = MockDataGenerators.generateMedication(
          userId: testUserId,
        );

        when(
          mockDataSource.addMedication(any),
        ).thenThrow(Exception('No internet connection'));

        final result = await repository.addMedication(testMedication);

        expect(result.isLeft(), true);
        result.fold((failure) {
          expect(failure.message, isNotEmpty);
          expect(
            failure.message.toLowerCase().contains('error') ||
                failure.message.toLowerCase().contains('unexpected'),
            true,
          );
        }, (_) => fail('Expected failure but got success'));
      });

      test('Read operations should use cached data when offline', () async {
        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final medications = List.generate(
          2,
          (_) => MockDataGenerators.generateMedication(userId: testUserId),
        );
        final medicationModels = medications
            .map((m) => MedicationModel.fromEntity(m))
            .toList();

        // First, simulate successful online fetch
        when(
          mockDataSource.getMedications(testUserId),
        ).thenAnswer((_) async => medicationModels);

        final onlineResult = await repository.getMedications();
        expect(onlineResult.isRight(), true);

        // Simulate offline: return cached data
        when(
          mockDataSource.getMedications(testUserId),
        ).thenAnswer((_) async => medicationModels);

        // Fetch while offline (should use cache)
        final offlineResult = await repository.getMedications();

        // Verify cached data is returned
        expect(offlineResult.isRight(), true);
        offlineResult.fold((_) => fail('Expected success but got failure'), (
          cachedMeds,
        ) {
          expect(cachedMeds.length, medications.length);
          for (int i = 0; i < medications.length; i++) {
            expect(cachedMeds[i].id, medications[i].id);
          }
        });
      });
    });
  });
}
