library property_test_framework;

import 'package:flutter_test/flutter_test.dart';
import 'dart:math';
import 'dart:developer' as developer;

/// Result of a property test execution
class PropertyTestResult {
  final bool passed;
  final int totalIterations;
  final int? failedIteration;
  final dynamic failingInput;
  final String? errorMessage;
  final StackTrace? stackTrace;

  PropertyTestResult({
    required this.passed,
    required this.totalIterations,
    this.failedIteration,
    this.failingInput,
    this.errorMessage,
    this.stackTrace,
  });

  @override
  String toString() {
    if (passed) {
      return 'Property test PASSED after $totalIterations iterations';
    } else {
      return '''
Property test FAILED at iteration $failedIteration/$totalIterations
Failing input: $failingInput
Error: $errorMessage
''';
    }
  }
}

/// Configuration for property test execution
class PropertyTestConfig {
  final int iterations;
  final int? seed;
  final bool verbose;
  final Duration? timeout;

  const PropertyTestConfig({
    this.iterations = 100,
    this.seed,
    this.verbose = false,
    this.timeout,
  });

  static const PropertyTestConfig standard = PropertyTestConfig(
    iterations: 100,
  );
  static const PropertyTestConfig quick = PropertyTestConfig(iterations: 20);
  static const PropertyTestConfig thorough = PropertyTestConfig(
    iterations: 500,
  );
}

/// Base class for property test generators
abstract class Generator<T> {
  final Random _random;

  Generator({int? seed}) : _random = Random(seed);

  /// Generate a random value
  T generate();

  /// Get the random instance for subclasses
  Random get random => _random;
}

/// Runs a property-based test with configurable iterations
///
/// Example:
/// ```dart
/// await runPropertyTest<String>(
///   name: 'String length is non-negative',
///   generator: () => randomString(),
///   property: (str) async => str.length >= 0,
///   config: PropertyTestConfig.standard,
/// );
/// ```
Future<PropertyTestResult> runPropertyTest<T>({
  required String name,
  required T Function() generator,
  required Future<bool> Function(T) property,
  PropertyTestConfig config = PropertyTestConfig.standard,
}) async {
  for (int i = 0; i < config.iterations; i++) {
    try {
      final input = generator();

      if (config.verbose) {
        developer.log(
          'Iteration ${i + 1}/${config.iterations}: Testing with input: $input',
        );
      }

      final result = await property(input).timeout(
        config.timeout ?? const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException(
          'Property test timed out at iteration ${i + 1}',
        ),
      );

      if (!result) {
        return PropertyTestResult(
          passed: false,
          totalIterations: config.iterations,
          failedIteration: i + 1,
          failingInput: input,
          errorMessage: 'Property returned false',
        );
      }
    } catch (e, stackTrace) {
      return PropertyTestResult(
        passed: false,
        totalIterations: config.iterations,
        failedIteration: i + 1,
        failingInput: null,
        errorMessage: e.toString(),
        stackTrace: stackTrace,
      );
    }
  }

  return PropertyTestResult(passed: true, totalIterations: config.iterations);
}

/// Synchronous version of runPropertyTest for properties that don't require async
Future<PropertyTestResult> runPropertyTestSync<T>({
  required String name,
  required T Function() generator,
  required bool Function(T) property,
  PropertyTestConfig config = PropertyTestConfig.standard,
}) async {
  return runPropertyTest<T>(
    name: name,
    generator: generator,
    property: (input) async => property(input),
    config: config,
  );
}

/// Test wrapper that integrates property tests with Flutter's test framework
void propertyTest<T>(
  String description, {
  required T Function() generator,
  required Future<bool> Function(T) property,
  PropertyTestConfig config = PropertyTestConfig.standard,
  dynamic skip,
  Timeout? timeout,
}) {
  test(
    description,
    () async {
      final result = await runPropertyTest<T>(
        name: description,
        generator: generator,
        property: property,
        config: config,
      );

      if (!result.passed) {
        fail(result.toString());
      }
    },
    skip: skip,
    timeout: timeout ?? Timeout(Duration(seconds: config.iterations * 10)),
  );
}

/// Synchronous version of propertyTest
void propertyTestSync<T>(
  String description, {
  required T Function() generator,
  required bool Function(T) property,
  PropertyTestConfig config = PropertyTestConfig.standard,
  dynamic skip,
  Timeout? timeout,
}) {
  propertyTest<T>(
    description,
    generator: generator,
    property: (input) async => property(input),
    config: config,
    skip: skip,
    timeout: timeout,
  );
}

/// Exception thrown when a property test times out
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
