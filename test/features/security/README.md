# Firebase Security Rules Verification Tests

This directory contains property-based tests that verify Firebase Security Rules are correctly configured to protect user data.

## Overview

These tests validate three critical security properties:

1. **Property 21**: Users can only access their own data (Requirements 6.1, 6.2)
2. **Property 22**: Unauthenticated requests are denied (Requirement 6.3)
3. **Property 23**: Invalid data is rejected by security rules (Requirement 6.4)

## Running the Tests

### Prerequisites

These tests require Firebase emulators to be running. The tests will automatically skip if emulators are not available.

### Starting Firebase Emulators

1. Install Firebase CLI if you haven't already:
   ```bash
   npm install -g firebase-tools
   ```

2. Start the Firebase emulators:
   ```bash
   firebase emulators:start
   ```

   This will start:
   - Auth Emulator on port 9099
   - Firestore Emulator on port 8080
   - Storage Emulator on port 9199

3. In a separate terminal, run the tests:
   ```bash
   flutter test test/features/security/security_rules_verification_tests.dart
   ```

### Running Without Emulators

If you run the tests without emulators, they will be skipped with a message:
```
⚠️  Firebase emulators not available. Skipping security rules tests.
   To run these tests, start Firebase emulators with: firebase emulators:start
```

## Test Structure

### Property 21: Data Access Authorization

Tests that authenticated users can:
- Create, read, update, and delete their own user documents
- Create, read, update, and delete their own medications
- Create, read, update, and delete their own adherence logs

Tests that users CANNOT:
- Read other users' documents
- Update other users' documents
- Delete other users' documents

### Property 22: Unauthenticated Access Denial

Tests that unauthenticated users CANNOT:
- Read any user documents
- Read any medications
- Create medications
- Update medications
- Delete medications
- Read adherence logs

### Property 23: Data Validation

Tests that security rules reject:
- Medications created with a userId that doesn't match the authenticated user
- Adherence logs created with a userId that doesn't match the authenticated user
- Any attempt to create documents with incorrect ownership

## Security Rules

The security rules being tested are defined in:
- `firestore.rules` - Firestore database rules
- `storage.rules` - Firebase Storage rules

### Firestore Rules Summary

```javascript
// Users can only access their own data
match /users/{userId} {
  allow read, write: if request.auth.uid == userId;
}

// Medications must have correct userId
match /medications/{medicationId} {
  allow read, write: if resource.data.userId == request.auth.uid;
  allow create: if request.resource.data.userId == request.auth.uid;
}

// Adherence logs must have correct userId
match /adherence_logs/{logId} {
  allow read, write: if resource.data.userId == request.auth.uid;
  allow create: if request.resource.data.userId == request.auth.uid;
}
```

## Property-Based Testing

These tests use property-based testing to verify security rules across many random inputs:
- Each test runs 20 iterations with randomly generated data
- Tests verify that security properties hold for ALL valid inputs
- Failures indicate potential security vulnerabilities

## Troubleshooting

### Tests are skipped
- Ensure Firebase emulators are running: `firebase emulators:start`
- Check that emulator ports are not in use (9099, 8080, 9199)

### Connection errors
- Verify `firebase.json` has correct emulator configuration
- Ensure no firewall is blocking localhost connections

### Permission denied errors in tests
- This is expected behavior! The tests verify that unauthorized access is properly denied
- Only unexpected permission denials (when access should be granted) indicate test failures

## CI/CD Integration

For CI/CD pipelines, you can start emulators in the background:

```bash
# Start emulators in background
firebase emulators:start --only auth,firestore,storage &
EMULATOR_PID=$!

# Wait for emulators to be ready
sleep 5

# Run tests
flutter test test/features/security/

# Stop emulators
kill $EMULATOR_PID
```

## Related Documentation

- [Firebase Security Rules Documentation](https://firebase.google.com/docs/rules)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [MedMind Security Requirements](../../../.kiro/specs/system-verification/requirements.md)
- [MedMind Design Document](../../../.kiro/specs/system-verification/design.md)
