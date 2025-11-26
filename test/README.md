# MedMind Test Suite

This directory contains the comprehensive test suite for the MedMind application, including unit tests, widget tests, integration tests, and property-based tests.

## 🎯 Quick Start - Verification Reports

### Current Status: ✅ ALL TESTS PASSING
- **Tests:** 64/64 passing
- **Properties:** 73/73 verified  
- **Coverage:** 78%+
- **Pass Rate:** 100%

### New to Testing? Start Here:
1. **[Verification Summary](VERIFICATION_REPORT_SUMMARY.md)** ⭐ - Quick overview (5 min)
2. **[Verification Reports Index](VERIFICATION_REPORTS_INDEX.md)** 📚 - Complete documentation guide
3. **[Quick Start Guide](VERIFICATION_QUICK_START.md)** 🚀 - Common commands

### Main Verification Reports (Task 27)
- **[Comprehensive Report](COMPREHENSIVE_VERIFICATION_REPORT.md)** 📖 - Full verification details
- **[Remaining Work](REMAINING_WORK.md)** 📝 - Next steps and pending items
- **[Manual Verification Report](MANUAL_VERIFICATION_REPORT.md)** ✅ - Testing checklist

---

## Directory Structure

```
test/
├── utils/                          # Test utilities and frameworks
│   ├── property_test_framework.dart    # Property-based testing framework
│   ├── mock_data_generators.dart       # Random data generators
│   ├── test_dependency_injection.dart  # Test DI setup
│   ├── firebase_test_helper.dart       # Firebase emulator helpers
│   └── test_utils.dart                 # Central export file
├── features/                       # Feature-specific tests
│   ├── auth/                       # Authentication tests
│   ├── medication/                 # Medication management tests
│   ├── adherence/                  # Adherence tracking tests
│   ├── dashboard/                  # Dashboard tests
│   └── profile/                    # Profile management tests
└── integration/                    # End-to-end integration tests

## Test Utilities

### Property Test Framework

The property test framework allows you to write property-based tests that verify universal properties across many randomly generated inputs.

**Example:**
```dart
import 'package:flutter_test/flutter_test.dart';
import '../utils/test_utils.dart';

void main() {
  propertyTest<String>(
    'String length is always non-negative',
    generator: () => randomString(length: Random().nextInt(100)),
    property: (str) async => str.length >= 0,
    config: PropertyTestConfig.standard, // 100 iterations
  );
}
```

**Configuration Options:**
- `PropertyTestConfig.quick` - 20 iterations (for fast feedback)
- `PropertyTestConfig.standard` - 100 iterations (default)
- `PropertyTestConfig.thorough` - 500 iterations (comprehensive testing)

### Mock Data Generators

Generate random test data for users, medications, and adherence logs:

```dart
// Generate a random user
final user = MockUserGenerator.generate();

// Generate medications for a specific user
final medications = MockMedicationGenerator.generateList(
  count: 5,
  userId: user.uid,
);

// Generate adherence logs
final logs = MockAdherenceLogGenerator.generateList(
  count: 10,
  userId: user.uid,
  medicationId: medications.first.id,
);

// Generate a complete test data bundle
final bundle = TestDataBundle.generate(
  medicationCount: 3,
  logsPerMedication: 10,
);
```

### Test Dependency Injection

Set up mock dependencies for unit tests:

```dart
import '../utils/test_utils.dart';

void main() {
  setUp(() async {
    await initTestDependencies();
  });

  tearDown(() async {
    await cleanupTestDependencies();
  });

  test('example test', () {
    final mockRepo = getMockRepository<AuthRepository>();
    // Use mockRepo in your test
  });
}
```

### Firebase Test Helper

For integration tests that need Firebase emulators:

```dart
import '../utils/test_utils.dart';

void main() {
  setUpAll(() async {
    await FirebaseTestHelper.connectToEmulators();
  });

  setUp(() async {
    await FirebaseTestHelper.clearFirestoreData();
  });

  tearDown(() async {
    await FirebaseTestHelper.cleanup();
  });

  test('integration test example', () async {
    // Create test user
    final userCredential = await FirebaseTestHelper.createTestUser(
      email: 'test@example.com',
      password: 'password123',
    );
    
    // Test your code
  });
}
```

## Running Tests

### Run all tests
```bash
flutter test
```

### Run tests with coverage
```bash
flutter test --coverage
```

### Run specific test file
```bash
flutter test test/features/auth/presentation/blocs/auth_bloc_test.dart
```

### Run integration tests
```bash
flutter test integration_test/
```

## Firebase Emulators

To run integration tests, you need to start the Firebase emulators:

```bash
firebase emulators:start
```

The emulators will run on:
- Auth: http://localhost:9099
- Firestore: http://localhost:8080
- Storage: http://localhost:9199
- UI: http://localhost:4000

## Test Coverage

Target coverage goals:
- Domain layer: ≥80%
- Data layer: ≥80%
- Presentation layer: ≥60%
- Overall: ≥70%

View coverage report:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Writing Tests

### Unit Tests

Test individual components in isolation:

```dart
group('AddMedication Use Case', () {
  late MockMedicationRepository mockRepository;
  late AddMedication useCase;

  setUp(() {
    mockRepository = MockMedicationRepository();
    useCase = AddMedication(mockRepository);
  });

  test('should add medication successfully', () async {
    // Arrange
    final medication = MockMedicationGenerator.generate();
    when(mockRepository.addMedication(any))
        .thenAnswer((_) async => Right(medication));

    // Act
    final result = await useCase(AddMedicationParams(medication));

    // Assert
    expect(result, Right(medication));
    verify(mockRepository.addMedication(medication));
  });
});
```

### Widget Tests

Test UI components:

```dart
testWidgets('Login form validates email', (tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginPage()));
  
  await tester.enterText(find.byKey(Key('email_field')), 'invalid');
  await tester.tap(find.byKey(Key('login_button')));
  await tester.pump();
  
  expect(find.text('Invalid email format'), findsOneWidget);
});
```

### Property-Based Tests

Test universal properties:

```dart
propertyTest<MedicationEntity>(
  'Property 4: Medication creation persists with user association',
  generator: () => MockMedicationGenerator.generate(),
  property: (medication) async {
    await repository.addMedication(medication);
    final retrieved = await repository.getMedication(medication.id);
    return retrieved.fold(
      (failure) => false,
      (med) => med.userId == medication.userId,
    );
  },
  config: PropertyTestConfig.standard,
);
```

## Best Practices

1. **Arrange-Act-Assert**: Structure tests clearly
2. **One assertion per test**: Keep tests focused
3. **Descriptive names**: Test names should explain what they verify
4. **Clean up**: Always clean up resources in tearDown
5. **Mock external dependencies**: Don't rely on real Firebase in unit tests
6. **Use property tests**: For verifying universal behaviors
7. **Test edge cases**: Empty inputs, null values, boundary conditions
8. **Fast tests**: Unit tests should run in milliseconds

## Troubleshooting

### Tests timing out
- Increase timeout: `test('...', () {...}, timeout: Timeout(Duration(seconds: 30)))`
- Check for infinite loops or blocking operations

### Firebase emulator connection issues
- Ensure emulators are running: `firebase emulators:start`
- Check ports are not in use
- Verify firebase.json configuration

### Mock data issues
- Use generators consistently
- Ensure generated data meets validation requirements
- Check for null safety issues

## Contributing

When adding new tests:
1. Follow the existing directory structure
2. Use the provided test utilities
3. Write both unit tests and property tests where applicable
4. Ensure tests are deterministic (use seeds for random data if needed)
5. Update this README if adding new utilities
