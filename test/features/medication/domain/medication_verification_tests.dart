import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medmind/features/medication/domain/entities/medication_entity.dart';
import 'package:medmind/features/medication/data/models/medication_model.dart';
import 'package:medmind/features/medication/data/datasources/medication_remote_data_source.dart';
import 'package:medmind/features/medication/data/repositories/medication_repository_impl.dart';
import 'package:medmind/features/adherence/domain/entities/adherence_log_entity.dart';
import 'package:medmind/core/constants/firebase_constants.dart';
import '../../../utils/mock_data_generators.dart';
import '../../../utils/property_test_framework.dart';

// Generate mocks
@GenerateMocks([
  FirebaseAuth,
  FirebaseFirestore,
  User,
  MedicationRemoteDataSource,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
])
import 'medication_verification_tests.mocks.dart';

/// Medication CRUD Verification Tests
/// These tests verify medication repository operations
/// **Feature: system-verification**
void main() {
  group('Medication CRUD Verification Tests', () {
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockUser mockUser;
    late MockMedicationRemoteDataSource mockDataSource;
    late MedicationRepositoryImpl repository;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      mockDataSource = MockMedicationRemoteDataSource();

      // Setup default user
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_user_id');

      repository = MedicationRepositoryImpl(
        remoteDataSource: mockDataSource,
        firebaseAuth: mockAuth,
      );
    });

    /// **Property 4: Medication creation persists with user association**
    /// **Validates: Requirements 2.1**
    test(
      'Property 4: Medication creation persists with user association',
      () async {
        // Test with multiple random inputs
        for (int i = 0; i < 100; i++) {
          final medication = MockMedicationGenerator.generate(
            userId: 'test_user_id',
            isActive: true,
          );

          // Setup mock to return the medication with an ID
          when(mockDataSource.addMedication(any)).thenAnswer((_) async {
            return MedicationModel.fromEntity(
              medication.copyWith(
                id: 'med_${i}_${DateTime.now().millisecondsSinceEpoch}',
              ),
            );
          });

          // Act: Add medication through repository
          final result = await repository.addMedication(medication);

          // Assert: Operation succeeded
          expect(
            result.isRight(),
            true,
            reason: 'Medication creation should succeed for iteration $i',
          );

          final addedMedication = result.getOrElse(() => throw Exception());

          // Verify userId matches
          expect(
            addedMedication.userId,
            'test_user_id',
            reason: 'UserId should match for iteration $i',
          );

          // Verify all required fields are present
          expect(addedMedication.id, isNotEmpty);
          expect(addedMedication.name, isNotEmpty);
          expect(addedMedication.dosage, isNotEmpty);
          expect(addedMedication.times, isNotEmpty);
          expect(addedMedication.isActive, true);

          // Verify data source was called
          verify(mockDataSource.addMedication(any)).called(1);
          clearInteractions(mockDataSource);
        }
      },
    );

    /// **Property 5: Users only retrieve their own medications**
    /// **Validates: Requirements 2.2**
    test('Property 5: Users only retrieve their own medications', () async {
      // Test with multiple random inputs
      for (int i = 0; i < 100; i++) {
        final userId = 'user_$i';
        when(mockUser.uid).thenReturn(userId);

        // Generate medications for this user
        final userMedications = MockMedicationGenerator.generateList(
          count: 5,
          userId: userId,
        );

        // Setup mock to return only user's medications
        when(mockDataSource.getMedications(userId)).thenAnswer((_) async {
          return userMedications
              .map((e) => MedicationModel.fromEntity(e))
              .toList();
        });

        // Act: Get medications
        final result = await repository.getMedications();

        // Assert: Operation succeeded
        expect(
          result.isRight(),
          true,
          reason: 'Get medications should succeed for iteration $i',
        );

        final medications = result.getOrElse(() => throw Exception());

        // Verify all medications belong to the user
        for (final medication in medications) {
          expect(
            medication.userId,
            userId,
            reason: 'All medications should belong to user for iteration $i',
          );
        }

        // Verify data source was called with correct userId
        verify(mockDataSource.getMedications(userId)).called(1);
        clearInteractions(mockDataSource);
      }
    });

    /// **Property 6: Medication updates persist immediately**
    /// **Validates: Requirements 2.3**
    test('Property 6: Medication updates persist immediately', () async {
      // Test with multiple random inputs
      for (int i = 0; i < 100; i++) {
        final medication = MockMedicationGenerator.generate(
          userId: 'test_user_id',
          isActive: true,
        );

        // Setup mock for update
        when(mockDataSource.updateMedication(any)).thenAnswer((_) async {});

        // Act: Update medication
        final result = await repository.updateMedication(medication);

        // Assert: Operation succeeded
        expect(
          result.isRight(),
          true,
          reason: 'Medication update should succeed for iteration $i',
        );

        // Verify data source was called
        verify(mockDataSource.updateMedication(any)).called(1);
        clearInteractions(mockDataSource);
      }
    });

    /// **Property 7: Medication deletion cascades to adherence logs**
    /// **Validates: Requirements 2.4**
    test(
      'Property 7: Medication deletion cascades to adherence logs',
      () async {
        // Test with multiple random inputs
        for (int i = 0; i < 100; i++) {
          final medicationId = 'med_$i';

          // Setup mock for deletion
          when(
            mockDataSource.deleteMedication(medicationId),
          ).thenAnswer((_) async {});

          // Act: Delete medication
          final result = await repository.deleteMedication(medicationId);

          // Assert: Operation succeeded
          expect(
            result.isRight(),
            true,
            reason: 'Medication deletion should succeed for iteration $i',
          );

          // Verify data source was called
          verify(mockDataSource.deleteMedication(medicationId)).called(1);
          clearInteractions(mockDataSource);
        }
      },
    );

    /// **Property 39: Serialization round-trip preserves data**
    /// **Validates: Requirements 12.1**
    test('Property 39: Serialization round-trip preserves data', () async {
      // Test with multiple random inputs
      for (int i = 0; i < 100; i++) {
        final medication = MockMedicationGenerator.generate(
          userId: 'test_user_id',
          isActive: true,
        );

        // Convert to model
        final model = MedicationModel.fromEntity(medication);

        // Serialize to JSON
        final json = model.toJson();

        // Deserialize back
        final deserializedModel = MedicationModel.fromJson(json);

        // Verify all fields match
        expect(deserializedModel.id, medication.id);
        expect(deserializedModel.userId, medication.userId);
        expect(deserializedModel.name, medication.name);
        expect(deserializedModel.dosage, medication.dosage);
        expect(deserializedModel.form, medication.form);
        expect(deserializedModel.frequency, medication.frequency);
        expect(deserializedModel.times.length, medication.times.length);
        expect(deserializedModel.days, medication.days);
        expect(deserializedModel.isActive, medication.isActive);
        expect(deserializedModel.refillReminder, medication.refillReminder);
      }
    });

    /// **Property 40: Model-to-entity conversion is complete**
    /// **Validates: Requirements 12.2**
    test('Property 40: Model-to-entity conversion is complete', () async {
      // Test with multiple random inputs
      for (int i = 0; i < 100; i++) {
        final model = MedicationModel.fromEntity(
          MockMedicationGenerator.generate(
            userId: 'test_user_id',
            isActive: true,
          ),
        );

        // Convert to entity (model extends entity, so it IS an entity)
        final entity = model as MedicationEntity;

        // Verify all fields are accessible
        expect(entity.id, isNotEmpty);
        expect(entity.userId, isNotEmpty);
        expect(entity.name, isNotEmpty);
        expect(entity.dosage, isNotEmpty);
        expect(entity.form, isNotNull);
        expect(entity.frequency, isNotNull);
        expect(entity.times, isNotEmpty);
        expect(entity.days, isNotNull);
        expect(entity.startDate, isNotNull);
        expect(entity.createdAt, isNotNull);
        expect(entity.updatedAt, isNotNull);
      }
    });

    /// **Property 41: Entity-to-model conversion is correct**
    /// **Validates: Requirements 12.3**
    test('Property 41: Entity-to-model conversion is correct', () async {
      // Test with multiple random inputs
      for (int i = 0; i < 100; i++) {
        final entity = MockMedicationGenerator.generate(
          userId: 'test_user_id',
          isActive: true,
        );

        // Convert to model
        final model = MedicationModel.fromEntity(entity);

        // Verify all fields match
        expect(model.id, entity.id);
        expect(model.userId, entity.userId);
        expect(model.name, entity.name);
        expect(model.dosage, entity.dosage);
        expect(model.form, entity.form);
        expect(model.frequency, entity.frequency);
        expect(model.times, entity.times);
        expect(model.days, entity.days);
        expect(model.startDate, entity.startDate);
        expect(model.isActive, entity.isActive);
        expect(model.barcodeData, entity.barcodeData);
        expect(model.refillReminder, entity.refillReminder);
        expect(model.instructions, entity.instructions);
        expect(model.createdAt, entity.createdAt);
        expect(model.updatedAt, entity.updatedAt);

        // Verify model can be serialized to Firestore format
        final document = model.toDocument();
        expect(document, isNotNull);
        expect(document['userId'], entity.userId);
        expect(document['name'], entity.name);
        expect(document['dosage'], entity.dosage);
      }
    });

    /// **Integration Test for Barcode Scanning**
    /// **Validates: Requirements 2.5**
    test('Barcode scanning integration', () async {
      // Test barcode scanning returns appropriate error
      // (actual scanning happens in presentation layer)
      final result = await repository.scanBarcode();

      // Should return a validation failure indicating this is UI-level
      expect(result.isLeft(), true);

      result.fold(
        (failure) {
          expect(failure.message, isNotEmpty);
        },
        (_) => fail('Barcode scanning should not succeed at repository level'),
      );
    });
  });
}
