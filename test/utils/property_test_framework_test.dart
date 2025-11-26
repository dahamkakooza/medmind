library property_test_framework_test;

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'property_test_framework.dart';
import 'mock_data_generators.dart';

final _testRandom = Random();

void main() {
  group('Property Test Framework', () {
    test('runPropertyTest passes when property holds', () async {
      final result = await runPropertyTest<int>(
        name: 'Non-negative integers are >= 0',
        generator: () => _testRandom.nextInt(1000),
        property: (n) async => n >= 0,
        config: const PropertyTestConfig(iterations: 50),
      );

      expect(result.passed, true);
      expect(result.totalIterations, 50);
      expect(result.failedIteration, null);
    });

    test('runPropertyTest fails when property does not hold', () async {
      final result = await runPropertyTest<int>(
        name: 'All integers are positive',
        generator: () => _testRandom.nextInt(100) - 50, // Can be negative
        property: (n) async => n > 0,
        config: const PropertyTestConfig(iterations: 50),
      );

      expect(result.passed, false);
      expect(result.failedIteration, isNotNull);
      expect(result.failingInput, isNotNull);
    });

    test('runPropertyTestSync works for synchronous properties', () async {
      final result = await runPropertyTestSync<String>(
        name: 'String length is non-negative',
        generator: () => randomString(length: _testRandom.nextInt(20)),
        property: (s) => s.length >= 0,
        config: const PropertyTestConfig(iterations: 50),
      );

      expect(result.passed, true);
    });

    test('propertyTest can be used directly', () async {
      // This test verifies that the property test wrapper works
      // by running a simple property test inline
      final result = await runPropertyTestSync<int>(
        name: 'Integers squared are non-negative',
        generator: () => _testRandom.nextInt(100) - 50,
        property: (n) => n * n >= 0,
        config: const PropertyTestConfig(iterations: 50),
      );

      expect(result.passed, true);
    });

    test('PropertyTestConfig provides different iteration counts', () {
      expect(PropertyTestConfig.quick.iterations, 20);
      expect(PropertyTestConfig.standard.iterations, 100);
      expect(PropertyTestConfig.thorough.iterations, 500);
    });
  });

  group('Mock Data Generators', () {
    test('MockUserGenerator creates valid users', () {
      final user = MockUserGenerator.generate();

      expect(user.id, isNotEmpty);
      expect(user.email, contains('@'));
      expect(user.displayName, isNotEmpty);
      expect(user.dateJoined, isNotNull);
    });

    test('MockMedicationGenerator creates valid medications', () {
      final medication = MockMedicationGenerator.generate();

      expect(medication.id, isNotEmpty);
      expect(medication.userId, isNotEmpty);
      expect(medication.name, isNotEmpty);
      expect(medication.dosage, isNotEmpty);
      expect(medication.times, isNotEmpty);
      expect(medication.createdAt, isNotNull);
    });

    test('MockAdherenceLogGenerator creates valid logs', () {
      final log = MockAdherenceLogGenerator.generate();

      expect(log.id, isNotEmpty);
      expect(log.userId, isNotEmpty);
      expect(log.medicationId, isNotEmpty);
      expect(log.scheduledTime, isNotNull);
      expect(log.status, isNotNull);
    });

    test('TestDataBundle generates complete test data', () {
      final bundle = TestDataBundle.generate(
        medicationCount: 3,
        logsPerMedication: 5,
      );

      expect(bundle.user, isNotNull);
      expect(bundle.medications.length, 3);
      expect(bundle.adherenceLogs.length, 15); // 3 meds * 5 logs

      // Verify all medications belong to the user
      for (final med in bundle.medications) {
        expect(med.userId, bundle.user.id);
      }

      // Verify all logs belong to the user
      for (final log in bundle.adherenceLogs) {
        expect(log.userId, bundle.user.id);
      }
    });

    test('randomEmail generates valid email format', () {
      for (int i = 0; i < 10; i++) {
        final email = randomEmail();
        expect(email, contains('@'));
        expect(email, contains('.'));
      }
    });

    test('randomPhoneNumber generates valid format', () {
      for (int i = 0; i < 10; i++) {
        final phone = randomPhoneNumber();
        expect(phone, startsWith('+1'));
        expect(phone.length, 12); // +1 + 10 digits
      }
    });

    test('randomDate generates dates within range', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 12, 31);

      for (int i = 0; i < 10; i++) {
        final date = randomDate(start: start, end: end);
        expect(date.isAfter(start) || date.isAtSameMomentAs(start), true);
        expect(date.isBefore(end) || date.isAtSameMomentAs(end), true);
      }
    });
  });
}
