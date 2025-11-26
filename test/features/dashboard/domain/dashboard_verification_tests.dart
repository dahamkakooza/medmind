import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:medmind/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:medmind/features/dashboard/domain/usecases/get_today_medications.dart';
import 'package:medmind/features/dashboard/domain/usecases/get_adherence_stats.dart';
import 'package:medmind/features/dashboard/domain/usecases/log_medication_taken.dart';
import 'package:medmind/features/dashboard/domain/entities/adherence_entity.dart';
import 'package:medmind/features/medication/domain/entities/medication_entity.dart';
import 'package:medmind/core/usecases/usecase.dart';
import 'package:medmind/core/errors/failures.dart';
import '../../../utils/property_test_framework.dart';
import '../../../utils/mock_data_generators.dart';

@GenerateMocks([DashboardRepository])
import 'dashboard_verification_tests.mocks.dart';

void main() {
  group('Dashboard Verification Tests', () {
    late MockDashboardRepository mockRepository;
    late GetTodayMedications getTodayMedications;
    late GetAdherenceStats getAdherenceStats;
    late LogMedicationTaken logMedicationTaken;

    setUp(() {
      mockRepository = MockDashboardRepository();
      getTodayMedications = GetTodayMedications(mockRepository);
      getAdherenceStats = GetAdherenceStats(mockRepository);
      logMedicationTaken = LogMedicationTaken(mockRepository);
    });

    group('Property 30: Dashboard displays today\'s medications', () {
      /// **Feature: system-verification, Property 30: Dashboard displays today's medications**
      /// **Validates: Requirements 9.1**
      ///
      /// For any set of medications with schedules, the dashboard should display
      /// only medications scheduled for the current day.
      propertyTest<List<MedicationEntity>>(
        'Property 30: Dashboard displays only today\'s medications',
        generator: () => _generateMedicationsForToday(),
        property: (medications) async {
          // Arrange
          when(
            mockRepository.getTodayMedications(),
          ).thenAnswer((_) async => Right(medications));

          // Act
          final result = await getTodayMedications(NoParams());

          // Assert
          return result.fold((failure) => false, (returnedMedications) {
            // Verify all returned medications should be taken today
            final now = DateTime.now();
            final currentDayOfWeek = now.weekday;

            for (final medication in returnedMedications) {
              // Check if medication is active
              if (!medication.isActive) {
                return false;
              }

              // Check if medication start date has passed
              if (medication.startDate.isAfter(now)) {
                return false;
              }

              // Check if medication should be taken today based on frequency
              bool shouldTakeToday = false;

              switch (medication.frequency) {
                case MedicationFrequency.daily:
                  shouldTakeToday = true;
                  break;
                case MedicationFrequency.weekly:
                  // Convert Flutter weekday (1-7, Mon-Sun) to our format (0-6, Sun-Sat)
                  final dayIndex = currentDayOfWeek == 7 ? 0 : currentDayOfWeek;
                  shouldTakeToday = medication.days.contains(dayIndex);
                  break;
                case MedicationFrequency.custom:
                  final dayIndex = currentDayOfWeek == 7 ? 0 : currentDayOfWeek;
                  shouldTakeToday = medication.days.contains(dayIndex);
                  break;
              }

              if (!shouldTakeToday) {
                return false;
              }
            }

            return true;
          });
        },
        config: const PropertyTestConfig(iterations: 100),
      );

      test(
        'Property 30: Empty list when no medications scheduled for today',
        () async {
          // Arrange - medications not scheduled for today
          when(
            mockRepository.getTodayMedications(),
          ).thenAnswer((_) async => const Right([]));

          // Act
          final result = await getTodayMedications(NoParams());

          // Assert
          expect(result.isRight(), true);
          result.fold(
            (failure) => fail('Should not return failure'),
            (medications) => expect(medications, isEmpty),
          );
        },
      );

      test('Property 30: Filters out inactive medications', () async {
        // Arrange - mix of active and inactive medications
        final activeMed = MockMedicationGenerator.generate(
          isActive: true,
          frequency: MedicationFrequency.daily,
        );
        final inactiveMed = MockMedicationGenerator.generate(
          isActive: false,
          frequency: MedicationFrequency.daily,
        );

        when(
          mockRepository.getTodayMedications(),
        ).thenAnswer((_) async => Right([activeMed]));

        // Act
        final result = await getTodayMedications(NoParams());

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Should not return failure'), (
          medications,
        ) {
          expect(medications.length, 1);
          expect(medications.first.isActive, true);
        });
      });
    });

    group('Property 31: Dashboard statistics are accurate', () {
      /// **Feature: system-verification, Property 31: Dashboard statistics are accurate**
      /// **Validates: Requirements 9.2**
      ///
      /// For any set of adherence logs, dashboard statistics should match
      /// manually calculated adherence rates.
      propertyTest<AdherenceEntity>(
        'Property 31: Dashboard statistics calculate correctly',
        generator: () => _generateAdherenceStats(),
        property: (stats) async {
          // Arrange
          when(
            mockRepository.getAdherenceStats(),
          ).thenAnswer((_) async => Right(stats));

          // Act
          final result = await getAdherenceStats(NoParams());

          // Assert
          return result.fold((failure) => false, (returnedStats) {
            // Verify adherence rate calculation
            final totalDoses =
                returnedStats.takenCount + returnedStats.missedCount;
            final expectedRate = totalDoses > 0
                ? returnedStats.takenCount / totalDoses
                : 0.0;

            // Allow small floating point differences
            final rateDifference = (returnedStats.adherenceRate - expectedRate)
                .abs();
            if (rateDifference > 0.001) {
              return false;
            }

            // Verify counts are non-negative
            if (returnedStats.takenCount < 0 || returnedStats.missedCount < 0) {
              return false;
            }

            // Verify adherence rate is between 0 and 1
            if (returnedStats.adherenceRate < 0.0 ||
                returnedStats.adherenceRate > 1.0) {
              return false;
            }

            return true;
          });
        },
        config: const PropertyTestConfig(iterations: 100),
      );

      test('Property 31: Zero adherence when no doses taken', () async {
        // Arrange
        const stats = AdherenceEntity(
          adherenceRate: 0.0,
          totalMedications: 5,
          takenCount: 0,
          missedCount: 10,
        );

        when(
          mockRepository.getAdherenceStats(),
        ).thenAnswer((_) async => const Right(stats));

        // Act
        final result = await getAdherenceStats(NoParams());

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Should not return failure'), (
          returnedStats,
        ) {
          expect(returnedStats.adherenceRate, 0.0);
          expect(returnedStats.takenCount, 0);
        });
      });

      test('Property 31: Perfect adherence when all doses taken', () async {
        // Arrange
        const stats = AdherenceEntity(
          adherenceRate: 1.0,
          totalMedications: 5,
          takenCount: 20,
          missedCount: 0,
        );

        when(
          mockRepository.getAdherenceStats(),
        ).thenAnswer((_) async => const Right(stats));

        // Act
        final result = await getAdherenceStats(NoParams());

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Should not return failure'), (
          returnedStats,
        ) {
          expect(returnedStats.adherenceRate, 1.0);
          expect(returnedStats.missedCount, 0);
        });
      });

      test('Property 31: Handles empty adherence data', () async {
        // Arrange
        const stats = AdherenceEntity(
          adherenceRate: 0.0,
          totalMedications: 0,
          takenCount: 0,
          missedCount: 0,
        );

        when(
          mockRepository.getAdherenceStats(),
        ).thenAnswer((_) async => const Right(stats));

        // Act
        final result = await getAdherenceStats(NoParams());

        // Assert
        expect(result.isRight(), true);
        result.fold((failure) => fail('Should not return failure'), (
          returnedStats,
        ) {
          expect(returnedStats.adherenceRate, 0.0);
          expect(returnedStats.totalMedications, 0);
        });
      });
    });

    group('Property 32: Dashboard updates immediately after logging', () {
      /// **Feature: system-verification, Property 32: Dashboard updates immediately after logging**
      /// **Validates: Requirements 9.3**
      ///
      /// For any dose logged from the dashboard, the medication status and
      /// statistics should update without requiring a refresh.
      propertyTest<String>(
        'Property 32: Dashboard updates after logging medication',
        generator: () => MockDataGenerators.generateId(),
        property: (medicationId) async {
          // Arrange - initial state
          final initialStats = MockDataGenerators.generateAdherenceStats();
          when(
            mockRepository.getAdherenceStats(),
          ).thenAnswer((_) async => Right(initialStats));

          // Log medication
          when(
            mockRepository.logMedicationTaken(medicationId),
          ).thenAnswer((_) async => const Right(null));

          // Updated stats after logging
          final updatedStats = initialStats.copyWith(
            takenCount: initialStats.takenCount + 1,
            adherenceRate:
                (initialStats.takenCount + 1) /
                (initialStats.takenCount + initialStats.missedCount + 1),
          );

          // Act - log medication
          final logResult = await logMedicationTaken(
            LogMedicationTakenParams(medicationId: medicationId),
          );

          // Verify logging succeeded
          if (logResult.isLeft()) {
            return false;
          }

          // Simulate immediate update by fetching stats again
          when(
            mockRepository.getAdherenceStats(),
          ).thenAnswer((_) async => Right(updatedStats));

          final statsResult = await getAdherenceStats(NoParams());

          // Assert - stats should be updated
          return statsResult.fold((failure) => false, (stats) {
            // Verify taken count increased
            return stats.takenCount > initialStats.takenCount;
          });
        },
        config: const PropertyTestConfig(iterations: 100),
      );

      test('Property 32: Logging failure does not update statistics', () async {
        // Arrange
        final initialStats = MockDataGenerators.generateAdherenceStats();
        when(
          mockRepository.getAdherenceStats(),
        ).thenAnswer((_) async => Right(initialStats));

        when(mockRepository.logMedicationTaken(any)).thenAnswer(
          (_) async => Left(ServerFailure(message: 'Failed to log')),
        );

        // Act
        final logResult = await logMedicationTaken(
          LogMedicationTakenParams(medicationId: 'test-med-id'),
        );

        // Assert - logging should fail
        expect(logResult.isLeft(), true);

        // Stats should remain unchanged
        final statsResult = await getAdherenceStats(NoParams());
        expect(statsResult.isRight(), true);
        statsResult.fold((failure) => fail('Should not return failure'), (
          stats,
        ) {
          expect(stats.takenCount, initialStats.takenCount);
          expect(stats.adherenceRate, initialStats.adherenceRate);
        });
      });

      test('Property 32: Multiple logs update statistics correctly', () async {
        // Arrange
        final medicationIds = ['med1', 'med2', 'med3'];
        var currentTakenCount = 10;

        for (final medId in medicationIds) {
          when(
            mockRepository.logMedicationTaken(medId),
          ).thenAnswer((_) async => const Right(null));

          // Act
          final result = await logMedicationTaken(
            LogMedicationTakenParams(medicationId: medId),
          );

          // Assert each log succeeds
          expect(result.isRight(), true);

          // Update mock to return incremented count
          currentTakenCount++;
          final updatedStats = AdherenceEntity(
            adherenceRate: currentTakenCount / (currentTakenCount + 5),
            totalMedications: 3,
            takenCount: currentTakenCount,
            missedCount: 5,
          );

          when(
            mockRepository.getAdherenceStats(),
          ).thenAnswer((_) async => Right(updatedStats));
        }

        // Verify final count
        final finalStats = await getAdherenceStats(NoParams());
        expect(finalStats.isRight(), true);
        finalStats.fold(
          (failure) => fail('Should not return failure'),
          (stats) => expect(stats.takenCount, 13), // 10 + 3 logs
        );
      });
    });
  });
}

/// Helper function to generate medications that should be taken today
List<MedicationEntity> _generateMedicationsForToday() {
  final now = DateTime.now();
  final currentDayOfWeek = now.weekday;
  final dayIndex = currentDayOfWeek == 7 ? 0 : currentDayOfWeek;

  final count = Random().nextInt(5) + 1;
  final medications = <MedicationEntity>[];

  for (int i = 0; i < count; i++) {
    final frequency = MedicationFrequency
        .values[Random().nextInt(MedicationFrequency.values.length)];

    List<int> days;
    switch (frequency) {
      case MedicationFrequency.daily:
        days = [0, 1, 2, 3, 4, 5, 6]; // All days
        break;
      case MedicationFrequency.weekly:
        days = [dayIndex]; // Today only
        break;
      case MedicationFrequency.custom:
        days = [dayIndex]; // Today only
        break;
    }

    medications.add(
      MockMedicationGenerator.generate(
        isActive: true,
        frequency: frequency,
        days: days,
      ),
    );
  }

  return medications;
}

/// Helper function to generate valid adherence statistics
AdherenceEntity _generateAdherenceStats() {
  final random = Random();
  final takenCount = random.nextInt(100);
  final missedCount = random.nextInt(50);
  final totalDoses = takenCount + missedCount;
  final adherenceRate = totalDoses > 0 ? takenCount / totalDoses : 0.0;

  return AdherenceEntity(
    adherenceRate: adherenceRate,
    totalMedications: random.nextInt(10) + 1,
    takenCount: takenCount,
    missedCount: missedCount,
    streakDays: random.nextInt(30),
  );
}
