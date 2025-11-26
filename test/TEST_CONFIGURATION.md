# Test Configuration Guide

This document describes the test infrastructure setup and configuration for the MedMind application.

## Test Infrastructure Components

### 1. Property Test Framework (`test/utils/property_test_framework.dart`)

A custom property-based testing framework that allows testing universal properties across many randomly generated inputs.

**Key Features:**
- Configurable iteration counts (quick: 20, standard: 100, thorough: 500)
- Comprehensive failure reporting with failing inputs
- Timeout protection
- Integration with Flutter's test framework
- Support for both sync and async properties

**Usage:**
```dart
propertyTest<String>(
  'Property description',
  generator: () => randomString(),
  property: (input) async => input.length >= 0,
  config: PropertyTestConfig.standard,
);
```

### 2. Mock Data Generators (`test/utils/mock_data_generators.dart`)

Provides random data generation for all domain entities.

**Generators:**
- `MockUserGenerator` - Random user entities
- `MockMedicationGenerator` - Random medication entities
- `MockAdherenceLogGenerator` - Random adherence log entities
- `TestDataBundle` - Complete test data sets with relationships

**Usage:**
```dart
final user = MockUserGenerator.generate();
final medications = MockMedicationGenerator.generateList(
  count: 5,
  userId: user.id,
);
```

### 3. Test Dependency Injection (`test/utils/test_dependency_injection.dart`)

Mock implementations of all dependencies for unit testing.

**Mocks Provided:**
- Firebase services (Auth, Firestore, Storage)
- All repositories
- All data sources
- SharedPreferences

**Usage:**
```dart
setUp(() async {
  await initTestDependencies();
});

tearDown(() async {
  await cleanupTestDependencies();
});

test('example', () {
  final mockRepo = getMockRepository<AuthRepository>();
  // Use mock in test
});
```

### 4. Firebase Test Helper (`test/utils/firebase_test_helper.dart`)

Utilities for integration testing with Firebase emulators.

**Features:**
- Automatic emulator connection
- Test user creation
- Firestore data management
- Cleanup utilities

**Usage:**
```dart
setUpAll(() async {
  await FirebaseTestHelper.connectToEmulators();
});

setUp(() async {
  await FirebaseTestHelper.clearFirestoreData();
});

test('integration test', () async {
  final user = await FirebaseTestHelper.createTestUser(
    email: 'test@example.com',
    password: 'password123',
  );
  // Test code
});
```

## Firebase Emulator Configuration

The Firebase emulators are configured in `firebase.json`:

```json
{
  "emulators": {
    "auth": { "port": 9099 },
    "firestore": { "port": 8080 },
    "storage": { "port": 9199 },
    "ui": { "enabled": true, "port": 4000 }
  }
}
```

### Starting Emulators

```bash
firebase emulators:start
```

### Emulator URLs
- Auth: http://localhost:9099
- Firestore: http://localhost:8080
- Storage: http://localhost:9199
- UI: http://localhost:4000

## Test Directory Structure

```
test/
├── utils/                          # Test utilities and frameworks
│   ├── property_test_framework.dart
│   ├── mock_data_generators.dart
│   ├── test_dependency_injection.dart
│   ├── firebase_test_helper.dart
│   └── test_utils.dart
├── features/                       # Feature-specific tests
│   ├── auth/
│   │   ├── data/                   # Data layer tests
│   │   ├── domain/                 # Domain layer tests
│   │   └── presentation/           # Presentation layer tests
│   ├── medication/
│   ├── adherence/
│   ├── dashboard/
│   └── profile/
└── integration/                    # End-to-end tests
```

## Test Types

### Unit Tests
- Test individual components in isolation
- Use mocks for dependencies
- Fast execution (milliseconds)
- Target: 80%+ coverage for Domain and Data layers

### Widget Tests
- Test UI components
- Verify rendering and interactions
- Use `testWidgets` from flutter_test
- Target: 60%+ coverage for Presentation layer

### Integration Tests
- Test complete workflows
- Use Firebase emulators
- Verify data persistence
- Test cross-layer interactions

### Property-Based Tests
- Test universal properties
- Use random input generation
- Catch edge cases
- Verify correctness properties from design doc

## Running Tests

### All Tests
```bash
flutter test
```

### Specific Test File
```bash
flutter test test/features/auth/presentation/blocs/auth_bloc_test.dart
```

### With Coverage
```bash
flutter test --coverage
```

### Generate Coverage Report
```bash
./test_coverage.sh
```

### Integration Tests (requires emulators)
```bash
# Terminal 1: Start emulators
firebase emulators:start

# Terminal 2: Run tests
flutter test test/integration/
```

## Coverage Goals

| Layer | Target Coverage |
|-------|----------------|
| Domain | ≥80% |
| Data | ≥80% |
| Presentation | ≥60% |
| Overall | ≥70% |

## Test Naming Conventions

### Unit Tests
```dart
test('should return Right(data) when operation succeeds', () {});
test('should return Left(failure) when operation fails', () {});
```

### Widget Tests
```dart
testWidgets('should display error message when validation fails', (tester) async {});
```

### Property Tests
```dart
propertyTest<T>(
  'Property N: Description from design doc',
  generator: () => generateT(),
  property: (input) async => verifyProperty(input),
);
```

### Integration Tests
```dart
test('complete registration flow creates user and navigates to dashboard', () async {});
```

## Best Practices

### 1. Test Structure
Use Arrange-Act-Assert pattern:
```dart
test('description', () {
  // Arrange
  final input = createInput();
  
  // Act
  final result = performAction(input);
  
  // Assert
  expect(result, expectedValue);
});
```

### 2. Mock Setup
```dart
when(mockRepository.method(any))
    .thenAnswer((_) async => Right(expectedData));
```

### 3. Cleanup
Always clean up resources:
```dart
tearDown(() async {
  await cleanupTestDependencies();
  await FirebaseTestHelper.cleanup();
});
```

### 4. Property Tests
Reference the design document:
```dart
// **Feature: system-verification, Property 4: Medication creation persists with user association**
// **Validates: Requirements 2.1**
propertyTest<MedicationEntity>(
  'Property 4: Medication creation persists with user association',
  generator: () => MockMedicationGenerator.generate(),
  property: (medication) async {
    // Test implementation
  },
);
```

### 5. Deterministic Tests
Use seeds for reproducibility:
```dart
final random = Random(42); // Fixed seed
```

### 6. Fast Tests
- Keep unit tests under 100ms
- Use mocks instead of real services
- Avoid unnecessary async operations

### 7. Isolated Tests
- Each test should be independent
- Don't rely on test execution order
- Clean up state between tests

## Troubleshooting

### Tests Timing Out
- Increase timeout: `timeout: Timeout(Duration(seconds: 30))`
- Check for infinite loops
- Verify async operations complete

### Emulator Connection Issues
- Ensure emulators are running
- Check ports are not in use
- Verify firebase.json configuration
- Clear emulator data: `firebase emulators:start --clear`

### Mock Issues
- Verify mock setup with `when()`
- Check method signatures match
- Use `verify()` to confirm calls

### Coverage Issues
- Exclude generated files: `coverage/lcov.info`
- Run with `--coverage` flag
- Check for untested branches

## Continuous Integration

Tests run automatically on:
- Every push to main branch
- Every pull request
- Scheduled nightly builds

CI Configuration: `.github/workflows/test.yml`

## Additional Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [BLoC Testing](https://pub.dev/packages/bloc_test)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
