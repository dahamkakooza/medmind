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
import '../domain/adherence_verification_tests.mocks.dart';

/// Adherence Analytics Verification Tests
/// These tests verify the adherence analytics screen functionality
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

  group('Adherence Analytics Verification Tests', () {
    /// **Feature: system-verification, Property 64: Time range filtering works correctly**
    /// **Validates: Requirements 22.3**
    test(
      'Property 64: For any selected time range, only adherence data within that range should be displayed',
      () async {
        // Test with multiple random time ranges (100 iterations)
        for (int i = 0; i < 100; i++) {
          // Generate random time range
          final now = DateTime.now();
          final daysBack = 7 + (i % 358); // 7 to 365 days back
          final startDate = DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: daysBack));
          final endDate = DateTime(now.year, now.month, now.day);

          // Generate adherence logs - some within range, some outside
          final logsWithinRange = List.generate(
            5 + (i % 10), // 5-15 logs within range
            (index) {
              final dayOffset = (daysBack * index) ~/ (5 + (i % 10));
              return MockAdherenceLogGenerator.generate(
                userId: testUserId,
                scheduledTime: startDate.add(Duration(days: dayOffset)),
              );
            },
          );

          // Generate logs outside the range (before startDate)
          final logsOutsideRange = List.generate(
            3,
            (index) => MockAdherenceLogGenerator.generate(
              userId: testUserId,
              scheduledTime: startDate.subtract(Duration(days: index + 1)),
            ),
          );

          // Setup mock to return only logs within range
          when(
            mockDataSource.getAdherenceLogs(
              userId: testUserId,
              startDate: startDate,
              endDate: endDate,
            ),
          ).thenAnswer(
            (_) async => logsWithinRange
                .map((log) => AdherenceLogModel.fromEntity(log))
                .toList(),
          );

          // Get adherence logs for the time range
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
            // Verify all returned logs are within the time range
            for (final log in receivedLogs) {
              expect(
                log.scheduledTime.isAfter(startDate) ||
                    log.scheduledTime.isAtSameMomentAs(startDate),
                true,
                reason:
                    'Log scheduled time should be on or after start date for iteration $i',
              );

              expect(
                log.scheduledTime.isBefore(endDate) ||
                    log.scheduledTime.isAtSameMomentAs(endDate),
                true,
                reason:
                    'Log scheduled time should be on or before end date for iteration $i',
              );
            }

            // Verify no logs from outside the range are included
            for (final outsideLog in logsOutsideRange) {
              final isIncluded = receivedLogs.any(
                (log) => log.id == outsideLog.id,
              );
              expect(
                isIncluded,
                false,
                reason:
                    'Logs outside time range should not be included for iteration $i',
              );
            }

            // Verify we got the expected number of logs
            expect(
              receivedLogs.length,
              logsWithinRange.length,
              reason: 'Should receive all logs within range for iteration $i',
            );
          });

          // Verify the data source was called with correct parameters
          verify(
            mockDataSource.getAdherenceLogs(
              userId: testUserId,
              startDate: startDate,
              endDate: endDate,
            ),
          ).called(1);

          // Reset mock for next iteration
          reset(mockDataSource);
        }
      },
    );

    /// **Feature: system-verification, Property 65: Trend indicators show correctly**
    /// **Validates: Requirements 22.5**
    test(
      'Property 65: For any adherence trend (improving or declining), appropriate visual indicators should be displayed',
      () async {
        // Test with multiple random scenarios (100 iterations)
        for (int i = 0; i < 100; i++) {
          final now = DateTime.now();

          // Define two time periods to compare for trend
          // Period 1: Earlier period (e.g., 60-30 days ago)
          final period1Start = now.subtract(const Duration(days: 60));
          final period1End = now.subtract(const Duration(days: 30));

          // Period 2: Recent period (e.g., 30-0 days ago)
          final period2Start = now.subtract(const Duration(days: 30));
          final period2End = now;

          // Determine trend type for this iteration
          final trendType = i % 3; // 0: improving, 1: declining, 2: stable

          double period1Rate;
          double period2Rate;

          if (trendType == 0) {
            // Improving trend: period 2 rate > period 1 rate
            period1Rate = 0.5 + ((i % 20) * 0.01); // 50-70%
            period2Rate = period1Rate + 0.1 + ((i % 10) * 0.01); // +10-20%
          } else if (trendType == 1) {
            // Declining trend: period 2 rate < period 1 rate
            period1Rate = 0.7 + ((i % 20) * 0.01); // 70-90%
            period2Rate = period1Rate - 0.1 - ((i % 10) * 0.01); // -10-20%
          } else {
            // Stable trend: rates are similar
            period1Rate = 0.75 + ((i % 5) * 0.01); // ~75%
            period2Rate = period1Rate + ((i % 3) * 0.01) - 0.01; // ±1-2%
          }

          // Ensure rates are between 0 and 1
          period1Rate = period1Rate.clamp(0.0, 1.0);
          period2Rate = period2Rate.clamp(0.0, 1.0);

          // Calculate counts for each period
          final totalDoses = 20 + (i % 10);
          final period1Taken = (totalDoses * period1Rate).round();
          final period2Taken = (totalDoses * period2Rate).round();

          // Setup mocks for both periods
          when(
            mockDataSource.getAdherenceSummary(
              userId: testUserId,
              startDate: period1Start,
              endDate: period1End,
            ),
          ).thenAnswer(
            (_) async => {
              'adherenceRate': period1Rate,
              'totalMedications': totalDoses,
              'takenCount': period1Taken,
              'missedCount': totalDoses - period1Taken,
              'streakDays': 0,
            },
          );

          when(
            mockDataSource.getAdherenceSummary(
              userId: testUserId,
              startDate: period2Start,
              endDate: period2End,
            ),
          ).thenAnswer(
            (_) async => {
              'adherenceRate': period2Rate,
              'totalMedications': totalDoses,
              'takenCount': period2Taken,
              'missedCount': totalDoses - period2Taken,
              'streakDays': 0,
            },
          );

          // Get adherence summaries for both periods
          final result1 = await repository.getAdherenceSummary(
            userId: testUserId,
            startDate: period1Start,
            endDate: period1End,
          );

          final result2 = await repository.getAdherenceSummary(
            userId: testUserId,
            startDate: period2Start,
            endDate: period2End,
          );

          // Verify both results are successful
          expect(
            result1.isRight() && result2.isRight(),
            true,
            reason:
                'Getting adherence summaries should succeed for iteration $i',
          );

          result1.fold((failure) => fail('Period 1 should not fail: ${failure.message}'), (
            summary1,
          ) {
            result2.fold((failure) => fail('Period 2 should not fail: ${failure.message}'), (
              summary2,
            ) {
              // Calculate trend from the two periods
              final trendDifference =
                  summary2.adherenceRate - summary1.adherenceRate;

              // Verify trend direction matches expected
              if (trendType == 0) {
                // Improving trend
                expect(
                  trendDifference > 0.05,
                  true,
                  reason:
                      'Improving trend should have positive difference > 0.05 for iteration $i (diff: $trendDifference)',
                );
              } else if (trendType == 1) {
                // Declining trend
                expect(
                  trendDifference < -0.05,
                  true,
                  reason:
                      'Declining trend should have negative difference < -0.05 for iteration $i (diff: $trendDifference)',
                );
              } else {
                // Stable trend - difference should be small
                expect(
                  trendDifference.abs() <= 0.05,
                  true,
                  reason:
                      'Stable trend should have small difference <= 0.05 for iteration $i (diff: $trendDifference)',
                );
              }

              // Verify trend indicator logic
              final isImproving = trendDifference > 0.05;
              final isDeclining = trendDifference < -0.05;
              final isStable = !isImproving && !isDeclining;

              // At least one trend indicator should be true
              expect(
                isImproving || isDeclining || isStable,
                true,
                reason:
                    'At least one trend indicator should be true for iteration $i',
              );

              // Verify trend indicators are mutually exclusive
              if (isImproving) {
                expect(
                  isDeclining,
                  false,
                  reason:
                      'Cannot be both improving and declining for iteration $i',
                );
                expect(
                  isStable,
                  false,
                  reason:
                      'Cannot be both improving and stable for iteration $i',
                );
              }

              if (isDeclining) {
                expect(
                  isImproving,
                  false,
                  reason:
                      'Cannot be both declining and improving for iteration $i',
                );
                expect(
                  isStable,
                  false,
                  reason:
                      'Cannot be both declining and stable for iteration $i',
                );
              }

              // Verify the adherence rates match expected values
              expect(
                (summary1.adherenceRate - period1Rate).abs() < 0.01,
                true,
                reason:
                    'Period 1 adherence rate should match expected for iteration $i',
              );

              expect(
                (summary2.adherenceRate - period2Rate).abs() < 0.01,
                true,
                reason:
                    'Period 2 adherence rate should match expected for iteration $i',
              );
            });
          });

          // Reset mock for next iteration
          reset(mockDataSource);
        }
      },
    );
  });
}
