import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medmind/features/medication/domain/repositories/medication_repository.dart';
import 'package:medmind/features/medication/data/repositories/medication_repository_impl.dart';
import 'package:medmind/features/medication/data/datasources/medication_remote_data_source.dart';
import 'package:medmind/features/medication/data/models/medication_model.dart';
import 'package:medmind/features/adherence/domain/repositories/adherence_repository.dart';
import 'package:medmind/features/adherence/data/repositories/adherence_repository_impl.dart';
import 'package:medmind/features/adherence/data/datasources/adherence_remote_data_source.dart';
import 'package:medmind/features/adherence/data/models/adherence_log_model.dart';
import 'package:medmind/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:medmind/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:medmind/features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'package:medmind/features/dashboard/domain/entities/adherence_entity.dart';
import 'package:medmind/features/dashboard/data/models/adherence_model.dart';
import '../../utils/mock_data_generators.dart';
import 'dart:async';

// Generate mocks
@GenerateMocks([
  FirebaseAuth,
  User,
  MedicationRemoteDataSource,
  AdherenceRemoteDataSource,
  DashboardRemoteDataSource,
])
import 'realtime_sync_verification_tests.mocks.dart';

/// Real-Time Synchronization Verification Tests
/// These tests verify real-time data streaming and synchronization
/// **Feature: system-verification**
void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockMedicationRemoteDataSource mockMedicationDataSource;
  late MockAdherenceRemoteDataSource mockAdherenceDataSource;
  late MockDashboardRemoteDataSource mockDashboardDataSource;
  late MedicationRepository medicationRepository;
  late AdherenceRepository adherenceRepository;
  late DashboardRepository dashboardRepository;
  late String testUserId;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockMedicationDataSource = MockMedicationRemoteDataSource();
    mockAdherenceDataSource = MockAdherenceRemoteDataSource();
    mockDashboardDataSource = MockDashboardRemoteDataSource();
    testUserId = 'test_user_${randomString(length: 10)}';

    // Setup auth mock
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn(testUserId);

    // Initialize repositories
    medicationRepository = MedicationRepositoryImpl(
      remoteDataSource: mockMedicationDataSource,
      firebaseAuth: mockAuth,
    );

    adherenceRepository = AdherenceRepositoryImpl(
      remoteDataSource: mockAdherenceDataSource,
      firebaseAuth: mockAuth,
    );

    dashboardRepository = DashboardRepositoryImpl(
      remoteDataSource: mockDashboardDataSource,
      firebaseAuth: mockAuth,
    );
  });

  group('Real-Time Synchronization Verification Tests', () {
    /// **Feature: system-verification, Property 48: Data changes stream to listeners**
    /// **Validates: Requirements 17.1**
    test(
      'Property 48: For any Firestore document change, all active stream listeners receive the update within 2 seconds',
      () async {
        // Test with multiple random scenarios (50 iterations)
        for (int i = 0; i < 50; i++) {
          // Generate random medications
          final medications = MockMedicationGenerator.generateList(
            count: 5,
            userId: testUserId,
          );

          // Create a stream controller to simulate Firestore snapshots
          final streamController = StreamController<List<MedicationModel>>();

          // Setup mock to return stream
          when(
            mockMedicationDataSource.watchMedications(testUserId),
          ).thenAnswer((_) => streamController.stream);

          // Watch medications
          final stream = medicationRepository.watchMedications();

          bool receivedUpdate = false;
          final stopwatch = Stopwatch()..start();

          // Listen to stream
          final subscription = stream.listen((result) {
            result.fold((failure) => fail('Stream should not emit failure'), (
              receivedMedications,
            ) {
              receivedUpdate = true;
              stopwatch.stop();

              // Verify medications were received
              expect(
                receivedMedications.length,
                medications.length,
                reason: 'Should receive all medications for iteration $i',
              );

              // Verify update was received within 2 seconds
              expect(
                stopwatch.elapsed.inSeconds,
                lessThan(2),
                reason:
                    'Update should be received within 2 seconds for iteration $i',
              );
            });
          });

          // Simulate Firestore emitting data
          streamController.add(
            medications.map((med) => MedicationModel.fromEntity(med)).toList(),
          );

          // Wait for stream to emit
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify update was received
          expect(
            receivedUpdate,
            true,
            reason: 'Should receive update for iteration $i',
          );

          await subscription.cancel();
          await streamController.close();

          // Reset mock for next iteration
          reset(mockMedicationDataSource);
        }
      },
    );

    /// **Feature: system-verification, Property 49: Adherence logs update dashboard in real-time**
    /// **Validates: Requirements 17.2**
    test(
      'Property 49: For any new adherence log creation, the dashboard statistics update without manual refresh',
      () async {
        // Test with multiple random scenarios (50 iterations)
        for (int i = 0; i < 50; i++) {
          // Generate initial adherence stats
          final initialStats = MockDataGenerators.generateAdherenceStats();

          // Create a stream controller to simulate dashboard updates
          final streamController = StreamController<AdherenceModel>();

          // Setup mock to return stream
          when(
            mockDashboardDataSource.watchAdherenceStats(testUserId),
          ).thenAnswer((_) => streamController.stream);

          // Watch dashboard adherence stats
          final stream = dashboardRepository.watchAdherenceStats();

          int updateCount = 0;
          final stopwatch = Stopwatch()..start();

          // Listen to stream
          final subscription = stream.listen((result) {
            result.fold((failure) => fail('Stream should not emit failure'), (
              stats,
            ) {
              updateCount++;

              if (updateCount == 2) {
                stopwatch.stop();

                // Verify stats were updated
                expect(
                  stats.takenCount,
                  greaterThan(initialStats.takenCount),
                  reason:
                      'Taken count should increase after logging for iteration $i',
                );

                // Verify update was received within 2 seconds
                expect(
                  stopwatch.elapsed.inSeconds,
                  lessThan(2),
                  reason:
                      'Dashboard update should be received within 2 seconds for iteration $i',
                );
              }
            });
          });

          // Simulate initial dashboard state
          streamController.add(AdherenceModel.fromEntity(initialStats));

          await Future.delayed(const Duration(milliseconds: 50));

          // Simulate adherence log creation causing dashboard update
          final updatedStats = initialStats.copyWith(
            takenCount: initialStats.takenCount + 1,
          );

          streamController.add(AdherenceModel.fromEntity(updatedStats));

          // Wait for stream to emit
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify update was received
          expect(
            updateCount,
            greaterThanOrEqualTo(2),
            reason: 'Should receive dashboard updates for iteration $i',
          );

          await subscription.cancel();
          await streamController.close();

          // Reset mock for next iteration
          reset(mockDashboardDataSource);
        }
      },
    );

    /// **Feature: system-verification, Property 50: List screens update automatically**
    /// **Validates: Requirements 17.5**
    test(
      'Property 50: For any medication addition while on the medication list screen, the list updates without navigation',
      () async {
        // Test with multiple random scenarios (50 iterations)
        for (int i = 0; i < 50; i++) {
          // Generate initial medications
          final initialMedications = MockMedicationGenerator.generateList(
            count: 3,
            userId: testUserId,
          );

          // Create a stream controller to simulate Firestore snapshots
          final streamController = StreamController<List<MedicationModel>>();

          // Setup mock to return stream
          when(
            mockMedicationDataSource.watchMedications(testUserId),
          ).thenAnswer((_) => streamController.stream);

          // Watch medications (simulating being on the list screen)
          final stream = medicationRepository.watchMedications();

          int updateCount = 0;
          int finalMedicationCount = 0;
          final stopwatch = Stopwatch()..start();

          // Listen to stream
          final subscription = stream.listen((result) {
            result.fold((failure) => fail('Stream should not emit failure'), (
              medications,
            ) {
              updateCount++;
              finalMedicationCount = medications.length;

              if (updateCount == 2) {
                stopwatch.stop();

                // Verify list was updated with new medication
                expect(
                  medications.length,
                  initialMedications.length + 1,
                  reason: 'List should include new medication for iteration $i',
                );

                // Verify update was received within 2 seconds
                expect(
                  stopwatch.elapsed.inSeconds,
                  lessThan(2),
                  reason:
                      'List update should be received within 2 seconds for iteration $i',
                );
              }
            });
          });

          // Simulate initial list state
          streamController.add(
            initialMedications
                .map((med) => MedicationModel.fromEntity(med))
                .toList(),
          );

          await Future.delayed(const Duration(milliseconds: 50));

          // Simulate adding a new medication
          final newMedication = MockMedicationGenerator.generate(
            userId: testUserId,
          );
          final updatedMedications = [...initialMedications, newMedication];

          streamController.add(
            updatedMedications
                .map((med) => MedicationModel.fromEntity(med))
                .toList(),
          );

          // Wait for stream to emit
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify list was updated
          expect(
            updateCount,
            greaterThanOrEqualTo(2),
            reason: 'Should receive list updates for iteration $i',
          );

          expect(
            finalMedicationCount,
            initialMedications.length + 1,
            reason: 'Final list should include new medication for iteration $i',
          );

          await subscription.cancel();
          await streamController.close();

          // Reset mock for next iteration
          reset(mockMedicationDataSource);
        }
      },
    );
  });
}
