# Dashboard Presentation Tests

## Mark as Taken Property Tests

The `mark_as_taken_test.dart` file contains property-based tests for the "mark as taken" functionality.

### Prerequisites

These tests require Firebase emulators to be running because the DashboardBloc accesses `FirebaseAuth.instance.currentUser`.

### Running the Tests

1. **Start Firebase Emulators:**
   ```bash
   firebase emulators:start
   ```

   The tests expect the Auth emulator to be running on `localhost:9099`.

2. **Run the Tests:**
   ```bash
   flutter test test/features/dashboard/presentation/mark_as_taken_test.dart
   ```

### What the Tests Verify

**Property 3: Mark as taken updates all related state**

For any medication marked as taken from the dashboard, the system should:
1. Create an adherence log entry with status "taken" (via AdherenceBloc)
2. Decrement the pending dose count (via PendingDoseTracker)
3. Display visual feedback (via MedicationLoggedSuccess state)
4. Update the progress indicator (via dashboard refresh)

The property test runs 100 iterations with randomly generated medications to ensure the behavior holds across all inputs.

### Additional Tests

- **Adherence log timestamp**: Verifies that the adherence log is created with the current timestamp
- **Success state**: Verifies that the success state includes the medication name for the snackbar
- **Dashboard refresh**: Verifies that the dashboard triggers a refresh after marking as taken

### Troubleshooting

If tests fail with `[core/no-app] No Firebase App '[DEFAULT]' has been created`:
- Ensure Firebase emulators are running
- Check that the Auth emulator is accessible on `localhost:9099`
- Verify that `firebase.json` is properly configured

If tests fail with authentication errors:
- The tests automatically create a test user (`test@medmind.com`)
- If the user already exists, it will sign in instead
- Check emulator logs for any authentication issues
