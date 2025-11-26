# Integration Tests

This directory contains end-to-end integration tests that verify complete user workflows.

## Test Categories

### Authentication Flows
- Registration → Auth creation → Firestore document → Dashboard navigation
- Login → Authentication → Dashboard
- Password reset flow

### Medication Management
- Add medication → Validation → BLoC → Firestore → List display
- Edit medication → Update → Persist → UI refresh
- Delete medication → Confirmation → Cascade delete → UI update

### Adherence Tracking
- Log dose → Create adherence log → Update statistics → UI refresh
- View adherence history
- Export adherence data

### Profile Management
- Update profile → Persist → UI refresh
- Change theme → SharedPreferences → BLoC → Global UI update
- Logout → Clear data → Navigate to login

## Running Integration Tests

Integration tests require Firebase emulators to be running:

```bash
# Start emulators
firebase emulators:start

# In another terminal, run integration tests
flutter test test/integration/
```

## Best Practices

1. Each test should be independent and not rely on other tests
2. Clean up test data in tearDown()
3. Use realistic test data
4. Test both success and failure paths
5. Verify data persistence in Firebase
6. Check UI state after operations
