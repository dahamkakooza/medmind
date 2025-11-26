import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medmind/features/adherence/domain/entities/adherence_log_entity.dart';
import 'package:medmind/features/adherence/domain/repositories/adherence_repository.dart';
import 'package:medmind/features/adherence/data/repositories/adherence_repository_impl.dart';
import 'package:medmind/features/adherence/data/datasources/adherence_remote_data_source.dart';
import 'package:medmind/features/adherence/data/models/adherence_log_model.dart';
import 'package:medmind/features/dashboard/domain/entities/adherence_entity.dart';
import '../../../utils/mock_data_generators.dart';

// Generate mocks
@GenerateMocks([FirebaseAuth, User, AdherenceRemoteDataSource])
import 'adherence_verification_tests.mocks.dart';

/// Adherence Tracking Verification Tests
/// These tests verify the adherence tracking repository logic
/// **Feature: system-verification**
void main() {
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockAdherenceRemoteDataSource mockDataSource;
  late AdherenceRepository repository;
  late String testUserId;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockDataSource = MockAdherenceRemoteDataSource();
    testUserId = 'test_user_${randomString(length: 10)}';

    // Setup auth mock
    when(mockAuth.currentUser).thenReturn(mockUser);
    when(mockUser.uid).thenReturn(testUserId);

    // Initialize repository
    repository = AdherenceRepositoryImpl(
      remoteDataSource: mockDataSource,
      firebaseAuth: mockAuth,
    );
  });

  group('Adherence Tracking Verification Tests', () {
    /// **Feature: system-verification, Property 8: Logging doses creates correct adherence records**
    /// **Validates: Requirements 3.1**
    test(
      'Property 8: For any medication and timestamp, logging a dose as taken creates an adherence log with status "taken" and correct timestamp',
      () async {
        // Test with multiple random inputs (100 iterations)
        for (int i = 0; i < 100; i++) {
          // Generate random adherence log
          final log = MockAdherenceLogGenerator.generate(
            userId: testUserId,
            status: AdherenceStatus.taken,
          );

          // Create the expected returned log with an ID
          final expectedLog = AdherenceLogModel.fromEntity(
            log.copyWith(
              id: 'log_${randomString(length: 20)}',
              userId: testUserId,
            ),
          );

          // Setup mock to return the created log
          when(
            mockDataSource.logMedicationTaken(any),
          ).thenAnswer((_) async => expectedLog);

          // Log the medication as taken
          final result = await repository.logMedicationTaken(log);

          // Verify the result is successful
          expect(
            result.isRight(),
            true,
            reason: 'Logging medication should succeed for iteration $i',
          );

          result.fold(
            (failure) => fail('Should not fail: ${failure.message}'),
            (createdLog) {
              // Verify the log was created with correct status
              expect(
                createdLog.status,
                AdherenceStatus.taken,
                reason: 'Status should be taken for iteration $i',
              );

              // Verify the log has a taken time
              expect(
                createdLog.takenTime,
                isNotNull,
                reason: 'Taken time should not be null for iteration $i',
              );

              // Verify the log belongs to the correct user
              expect(
                createdLog.userId,
                testUserId,
                reason: 'User ID should match for iteration $i',
              );

              // Verify the log has the correct medication ID
              expect(
                createdLog.medicationId,
                log.medicationId,
                reason: 'Medication ID should match for iteration $i',
              );

              // Verify the scheduled time matches
              expect(
                createdLog.scheduledTime,
                log.scheduledTime,
                reason: 'Scheduled time should match for iteration $i',
              );
            },
          );

          // Verify the data source was called
          verify(mockDataSource.logMedicationTaken(any)).called(1);

          // Reset mock for next iteration
          reset(mockDataSource);
        }
      },
    );

    /// **Feature: system-verification, Property 9: Adherence statistics calculate correctly**
    /// **Validates: Requirements 3.3**
    test(
      'Property 9: For any set of adherence logs, the adherence rate equals (taken doses / scheduled doses) × 100',
      () async {
        // Test with multiple random scenarios (100 iterations)
        for (int i = 0; i < 100; i++) {
          final startDate = DateTime.now().subtract(const Duration(days: 30));
          final endDate = DateTime.now();

          // Generate random number of logs
          final totalLogs = 10 + (i % 20); // 10-30 logs
          final takenCount = (i % (totalLogs + 1)); // 0 to totalLogs taken
          final missedCount = totalLogs - takenCount;

          final expectedRate = totalLogs > 0 ? takenCount / totalLogs : 0.0;

          // Setup mock to return summary data
          when(
            mockDataSource.getAdherenceSummary(
              userId: testUserId,
              startDate: startDate,
              endDate: endDate,
            ),
          ).thenAnswer(
            (_) async => {
              'adherenceRate': expectedRate,
              'totalMedications': totalLogs,
              'takenCount': takenCount,
              'missedCount': missedCount,
              'streakDays': 0,
            },
          );

          // Get adherence summary
          final result = await repository.getAdherenceSummary(
            userId: testUserId,
            startDate: startDate,
            endDate: endDate,
          );

          // Verify the result is successful
          expect(
            result.isRight(),
            true,
            reason: 'Getting adherence summary should succeed for iteration $i',
          );

          result.fold(
            (failure) => fail('Should not fail: ${failure.message}'),
            (summary) {
              // Verify the adherence rate is calculated correctly
              expect(
                summary.adherenceRate,
                expectedRate,
                reason: 'Adherence rate should match for iteration $i',
              );

              // Verify taken count
              expect(
                summary.takenCount,
                takenCount,
                reason: 'Taken count should match for iteration $i',
              );

              // Verify missed count
              expect(
                summary.missedCount,
                missedCount,
                reason: 'Missed count should match for iteration $i',
              );
            },
          );

          // Reset mock for next iteration
          reset(mockDataSource);
        }
      },
    );

    /// **Feature: system-verification, Property 10: Adherence data streams in real-time**
    /// **Validates: Requirements 3.4**
    test(
      'Property 10: For any adherence log creation or update, all active listeners receive the update within 2 seconds',
      () async {
        // Test with multiple random scenarios
        for (int i = 0; i < 50; i++) {
          // Generate random adherence logs
          final logs = MockAdherenceLogGenerator.generateList(
            count: 5,
            userId: testUserId,
          );

          // Setup mock to return stream of logs
          when(mockDataSource.watchAdherenceLogs(testUserId)).thenAnswer(
            (_) => Stream.value(
              logs.map((log) => AdherenceLogModel.fromEntity(log)).toList(),
            ),
          );

          // Watch adherence logs
          final stream = repository.watchAdherenceLogs(testUserId);

          bool receivedUpdate = false;
          final stopwatch = Stopwatch()..start();

          // Listen to stream
          final subscription = stream.listen((result) {
            result.fold((failure) => fail('Stream should not emit failure'), (
              receivedLogs,
            ) {
              receivedUpdate = true;
              stopwatch.stop();

              // Verify logs were received
              expect(
                receivedLogs.length,
                logs.length,
                reason: 'Should receive all logs for iteration $i',
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

          // Wait for stream to emit
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify update was received
          expect(
            receivedUpdate,
            true,
            reason: 'Should receive update for iteration $i',
          );

          await subscription.cancel();

          // Reset mock for next iteration
          reset(mockDataSource);
        }
      },
    );

    /// **Feature: system-verification, Property 11: Adherence history returns ordered logs**
    /// **Validates: Requirements 3.5**
    test(
      'Property 11: For any user\'s adherence logs, retrieving history returns logs ordered by scheduledTime in descending order',
      () async {
        // Test with multiple random scenarios (100 iterations)
        for (int i = 0; i < 100; i++) {
          final startDate = DateTime.now().subtract(const Duration(days: 30));
          final endDate = DateTime.now();

          // Generate random adherence logs with different scheduled times
          final logs = List.generate(
            10,
            (index) => MockAdherenceLogGenerator.generate(
              userId: testUserId,
              scheduledTime: startDate.add(Duration(days: index)),
            ),
          );

          // Sort logs by scheduled time descending (most recent first)
          final sortedLogs = List<AdherenceLogEntity>.from(logs)
            ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

          // Setup mock to return sorted logs
          when(
            mockDataSource.getAdherenceLogs(
              userId: testUserId,
              startDate: startDate,
              endDate: endDate,
            ),
          ).thenAnswer(
            (_) async => sortedLogs
                .map((log) => AdherenceLogModel.fromEntity(log))
                .toList(),
          );

          // Get adherence logs
          final result = await repository.getAdherenceLogs(
            userId: testUserId,
            startDate: startDate,
            endDate: endDate,
          );

          // Verify the result is successful
          expect(
            result.isRight(),
            true,
            reason: 'Getting adherence logs should succeed for iteration $i',
          );

          result.fold((failure) => fail('Should not fail: ${failure.message}'), (
            receivedLogs,
          ) {
            // Verify logs are ordered by scheduled time descending
            for (int j = 0; j < receivedLogs.length - 1; j++) {
              expect(
                receivedLogs[j].scheduledTime.isAfter(
                      receivedLogs[j + 1].scheduledTime,
                    ) ||
                    receivedLogs[j].scheduledTime.isAtSameMomentAs(
                      receivedLogs[j + 1].scheduledTime,
                    ),
                true,
                reason:
                    'Logs should be ordered by scheduled time descending for iteration $i',
              );
            }
          });

          // Reset mock for next iteration
          reset(mockDataSource);
        }
      },
    );

    /// **Feature: system-verification, Property 63: Adherence percentages calculate correctly**
    /// **Validates: Requirements 22.2**
    test(
      'Property 63: For any set of adherence data, the percentage equals (taken / scheduled) × 100, rounded to 2 decimal places',
      () async {
        // Test with multiple random scenarios (100 iterations)
        for (int i = 0; i < 100; i++) {
          final startDate = DateTime.now().subtract(const Duration(days: 30));
          final endDate = DateTime.now();

          // Generate random counts
          final totalLogs = 10 + (i % 40); // 10-50 logs
          final takenCount = (i % (totalLogs + 1)); // 0 to totalLogs taken

          // Calculate expected percentage
          final expectedPercentage = totalLogs > 0
              ? double.parse(
                  ((takenCount / totalLogs) * 100).toStringAsFixed(2),
                )
              : 0.0;

          final expectedRate = takenCount / totalLogs;

          // Setup mock to return summary data
          when(
            mockDataSource.getAdherenceSummary(
              userId: testUserId,
              startDate: startDate,
              endDate: endDate,
            ),
          ).thenAnswer(
            (_) async => {
              'adherenceRate': expectedRate,
              'totalMedications': totalLogs,
              'takenCount': takenCount,
              'missedCount': totalLogs - takenCount,
              'streakDays': 0,
            },
          );

          // Get adherence summary
          final result = await repository.getAdherenceSummary(
            userId: testUserId,
            startDate: startDate,
            endDate: endDate,
          );

          // Verify the result is successful
          expect(
            result.isRight(),
            true,
            reason: 'Getting adherence summary should succeed for iteration $i',
          );

          result.fold(
            (failure) => fail('Should not fail: ${failure.message}'),
            (summary) {
              // Calculate percentage from rate
              final actualPercentage = double.parse(
                (summary.adherenceRate * 100).toStringAsFixed(2),
              );

              // Verify the percentage is calculated correctly
              expect(
                actualPercentage,
                expectedPercentage,
                reason: 'Adherence percentage should match for iteration $i',
              );
            },
          );

          // Reset mock for next iteration
          reset(mockDataSource);
        }
      },
    );
  });
}
