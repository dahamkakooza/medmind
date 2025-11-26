library mock_data_generators;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:medmind/features/auth/domain/entities/user_entity.dart';
import 'package:medmind/features/medication/domain/entities/medication_entity.dart';
import 'package:medmind/features/adherence/domain/entities/adherence_log_entity.dart';
import 'package:medmind/features/dashboard/domain/entities/adherence_entity.dart';

/// Random instance for all generators
final Random _random = Random();

/// Generates a random string of specified length
String randomString({int length = 10, bool alphanumeric = true}) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const numbers = '0123456789';
  final pool = alphanumeric ? chars + numbers : chars;

  return List.generate(
    length,
    (index) => pool[_random.nextInt(pool.length)],
  ).join();
}

/// Generates a random email address
String randomEmail() {
  return '${randomString(length: 8)}@${randomString(length: 5)}.com'
      .toLowerCase();
}

/// Generates a random phone number
String randomPhoneNumber() {
  return '+1${_random.nextInt(900) + 100}${_random.nextInt(900) + 100}${_random.nextInt(9000) + 1000}';
}

/// Generates a random date within a range
DateTime randomDate({DateTime? start, DateTime? end}) {
  final startDate = start ?? DateTime.now().subtract(const Duration(days: 365));
  final endDate = end ?? DateTime.now().add(const Duration(days: 365));

  final diff = endDate.difference(startDate).inDays;
  final randomDays = _random.nextInt(diff);

  return startDate.add(Duration(days: randomDays));
}

/// Generates a random time of day
TimeOfDay randomTimeOfDay() {
  final hour = _random.nextInt(24);
  final minute = _random.nextInt(60);

  return TimeOfDay(hour: hour, minute: minute);
}

/// Mock User Data Generator
class MockUserGenerator {
  /// Generate a random user entity
  static UserEntity generate({String? id, String? email, String? displayName}) {
    return UserEntity(
      id: id ?? 'user_${randomString(length: 20)}',
      email: email ?? randomEmail(),
      displayName: displayName ?? 'User ${randomString(length: 8)}',
      photoURL: _random.nextBool() ? 'https://example.com/photo.jpg' : null,
      dateJoined: randomDate(
        start: DateTime.now().subtract(const Duration(days: 365)),
        end: DateTime.now(),
      ),
      lastLogin: _random.nextBool() ? DateTime.now() : null,
      emailVerified: _random.nextBool(),
    );
  }

  /// Generate multiple random users
  static List<UserEntity> generateList({int count = 5}) {
    return List.generate(count, (_) => generate());
  }
}

/// Mock Medication Data Generator
class MockMedicationGenerator {
  /// Generate a random medication entity
  static MedicationEntity generate({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    MedicationForm? form,
    MedicationFrequency? frequency,
    List<TimeOfDay>? times,
    List<int>? days,
    bool? isActive,
  }) {
    final forms = MedicationForm.values;
    final frequencies = MedicationFrequency.values;
    final medicationNames = [
      'Aspirin',
      'Ibuprofen',
      'Lisinopril',
      'Metformin',
      'Atorvastatin',
      'Amlodipine',
      'Omeprazole',
      'Levothyroxine',
      'Albuterol',
      'Gabapentin',
    ];

    final dosages = ['5mg', '10mg', '25mg', '50mg', '100mg', '200mg', '500mg'];
    final selectedFrequency =
        frequency ?? frequencies[_random.nextInt(frequencies.length)];

    return MedicationEntity(
      id: id ?? 'med_${randomString(length: 20)}',
      userId: userId ?? 'user_${randomString(length: 20)}',
      name: name ?? medicationNames[_random.nextInt(medicationNames.length)],
      dosage: dosage ?? dosages[_random.nextInt(dosages.length)],
      form: form ?? forms[_random.nextInt(forms.length)],
      frequency: selectedFrequency,
      times: times ?? _generateRandomTimes(),
      days: days ?? _generateRandomDays(selectedFrequency),
      startDate: randomDate(
        start: DateTime.now().subtract(const Duration(days: 180)),
        end: DateTime.now(),
      ),
      isActive: isActive ?? _random.nextBool(),
      barcodeData: _random.nextBool()
          ? randomString(length: 12, alphanumeric: true)
          : null,
      refillReminder: _random.nextBool(),
      instructions: _random.nextBool() ? 'Take with food' : null,
      createdAt: randomDate(
        start: DateTime.now().subtract(const Duration(days: 365)),
        end: DateTime.now(),
      ),
      updatedAt: DateTime.now(),
    );
  }

  /// Generate random times (1-4 times per day)
  static List<TimeOfDay> _generateRandomTimes() {
    final timesPerDay = _random.nextInt(4) + 1;
    final times = <TimeOfDay>[];

    for (int i = 0; i < timesPerDay; i++) {
      times.add(randomTimeOfDay());
    }

    times.sort((a, b) => a.hour.compareTo(b.hour));
    return times;
  }

  /// Generate random days based on frequency
  static List<int> _generateRandomDays(MedicationFrequency frequency) {
    if (frequency == MedicationFrequency.daily) {
      return [0, 1, 2, 3, 4, 5, 6]; // All days
    } else if (frequency == MedicationFrequency.weekly) {
      // Random day of the week
      return [_random.nextInt(7)];
    } else {
      // Custom: random selection of days
      final numDays = _random.nextInt(6) + 1;
      final days = <int>{};
      while (days.length < numDays) {
        days.add(_random.nextInt(7));
      }
      return days.toList()..sort();
    }
  }

  /// Generate multiple random medications
  static List<MedicationEntity> generateList({int count = 5, String? userId}) {
    return List.generate(count, (_) => generate(userId: userId));
  }
}

/// Mock Adherence Log Data Generator
class MockAdherenceLogGenerator {
  /// Generate a random adherence log entity
  static AdherenceLogEntity generate({
    String? id,
    String? userId,
    String? medicationId,
    DateTime? scheduledTime,
    DateTime? takenTime,
    AdherenceStatus? status,
  }) {
    final statuses = AdherenceStatus.values;
    final selectedStatus = status ?? statuses[_random.nextInt(statuses.length)];

    final scheduled =
        scheduledTime ??
        randomDate(
          start: DateTime.now().subtract(const Duration(days: 30)),
          end: DateTime.now(),
        );

    DateTime? taken;
    if (selectedStatus == AdherenceStatus.taken) {
      // Taken time should be close to scheduled time
      final minutesOffset = _random.nextInt(120) - 60; // -60 to +60 minutes
      taken = scheduled.add(Duration(minutes: minutesOffset));
    }

    int? snoozeDuration;
    if (selectedStatus == AdherenceStatus.snoozed) {
      snoozeDuration = [5, 10, 15, 30, 60][_random.nextInt(5)];
    }

    return AdherenceLogEntity(
      id: id ?? 'log_${randomString(length: 20)}',
      userId: userId ?? 'user_${randomString(length: 20)}',
      medicationId: medicationId ?? 'med_${randomString(length: 20)}',
      scheduledTime: scheduled,
      takenTime: taken,
      status: selectedStatus,
      snoozeDuration: snoozeDuration,
      createdAt: scheduled,
      deviceInfo: _random.nextBool()
          ? {'platform': 'iOS', 'version': '1.0.0'}
          : null,
    );
  }

  /// Generate multiple random adherence logs
  static List<AdherenceLogEntity> generateList({
    int count = 10,
    String? userId,
    String? medicationId,
  }) {
    return List.generate(
      count,
      (_) => generate(userId: userId, medicationId: medicationId),
    );
  }

  /// Generate adherence logs for a specific time period
  static List<AdherenceLogEntity> generateForPeriod({
    required DateTime startDate,
    required DateTime endDate,
    required String userId,
    required String medicationId,
    required List<TimeOfDay> scheduleTimes,
  }) {
    final logs = <AdherenceLogEntity>[];
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      for (final scheduleTime in scheduleTimes) {
        final scheduledDateTime = DateTime(
          currentDate.year,
          currentDate.month,
          currentDate.day,
          scheduleTime.hour,
          scheduleTime.minute,
        );

        if (scheduledDateTime.isBefore(DateTime.now())) {
          logs.add(
            generate(
              userId: userId,
              medicationId: medicationId,
              scheduledTime: scheduledDateTime,
            ),
          );
        }
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return logs;
  }
}

/// Test Data Bundle - combines related test data
class TestDataBundle {
  final UserEntity user;
  final List<MedicationEntity> medications;
  final List<AdherenceLogEntity> adherenceLogs;

  TestDataBundle({
    required this.user,
    required this.medications,
    required this.adherenceLogs,
  });

  /// Generate a complete test data bundle
  factory TestDataBundle.generate({
    int medicationCount = 3,
    int logsPerMedication = 10,
  }) {
    final user = MockUserGenerator.generate();
    final medications = MockMedicationGenerator.generateList(
      count: medicationCount,
      userId: user.id,
    );

    final logs = <AdherenceLogEntity>[];
    for (final medication in medications) {
      logs.addAll(
        MockAdherenceLogGenerator.generateList(
          count: logsPerMedication,
          userId: user.id,
          medicationId: medication.id,
        ),
      );
    }

    return TestDataBundle(
      user: user,
      medications: medications,
      adherenceLogs: logs,
    );
  }
}

/// Convenience class for accessing all generators
class MockDataGenerators {
  /// Generate user credentials for testing
  static Map<String, dynamic> generateUserCredentials() {
    return {'email': randomEmail(), 'password': randomString(length: 12)};
  }

  /// Generate a user entity
  static UserEntity generateUser({String? email, String? id}) {
    return MockUserGenerator.generate(email: email, id: id);
  }

  /// Generate a medication entity
  static MedicationEntity generateMedication({String? userId}) {
    return MockMedicationGenerator.generate(userId: userId);
  }

  /// Generate an adherence log entity
  static AdherenceLogEntity generateAdherenceLog({
    String? userId,
    String? medicationId,
  }) {
    return MockAdherenceLogGenerator.generate(
      userId: userId,
      medicationId: medicationId,
    );
  }

  /// Generate a random ID
  static String generateId() {
    return randomString(length: 20);
  }

  /// Generate adherence stats entity
  static AdherenceEntity generateAdherenceStats() {
    final takenCount = _random.nextInt(80) + 20;
    final missedCount = _random.nextInt(20);
    final totalMedications = _random.nextInt(10) + 1;
    final adherenceRate = takenCount / (takenCount + missedCount);

    return AdherenceEntity(
      adherenceRate: adherenceRate,
      totalMedications: totalMedications,
      takenCount: takenCount,
      missedCount: missedCount,
      weeklyStats: [],
      monthlyStats: [],
      streakDays: _random.nextInt(30),
    );
  }
}
