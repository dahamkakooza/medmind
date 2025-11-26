# Firebase Emulator Testing Guide for Task 26

This guide explains how to run the security rules tests with Firebase emulators during the final verification phase (Task 26).

## Quick Start

### Step 1: Start Firebase Emulators

Open a terminal and start the emulators:

```bash
firebase emulators:start
```

You should see output like:
```
✔  All emulators ready! It is now safe to connect your app.
┌─────────────────────────────────────────────────────────────┐
│ ✔  All emulators ready! It is now safe to connect your app. │
│ i  View Emulator UI at http://127.0.0.1:4000                │
└─────────────────────────────────────────────────────────────┘

┌────────────────┬────────────────┬─────────────────────────────────┐
│ Emulator       │ Host:Port      │ View in Emulator UI             │
├────────────────┼────────────────┼─────────────────────────────────┤
│ Authentication │ 127.0.0.1:9099 │ http://127.0.0.1:4000/auth      │
├────────────────┼────────────────┼─────────────────────────────────┤
│ Firestore      │ 127.0.0.1:8080 │ http://127.0.0.1:4000/firestore │
├────────────────┼────────────────┼─────────────────────────────────┤
│ Storage        │ 127.0.0.1:9199 │ http://127.0.0.1:4000/storage   │
└────────────────┴────────────────┴─────────────────────────────────┘
```

**Keep this terminal open!** The emulators need to stay running.

### Step 2: Run Security Rules Tests

In a **new terminal**, run the security rules tests:

```bash
flutter test test/features/security/security_rules_verification_tests.dart --reporter expanded
```

### Expected Output (Success)

When emulators are running, you should see:

```
00:00 +0: Firebase Security Rules Verification (setUpAll)
00:00 +0: Firebase Security Rules Verification Property 21: Users can only access their own data Authenticated users can read and write their own data
00:01 +1: Firebase Security Rules Verification Property 21: Users can only access their own data Users cannot access other users' data
00:02 +2: Firebase Security Rules Verification Property 22: Unauthenticated requests are denied Unauthenticated users cannot access protected data
00:03 +3: Firebase Security Rules Verification Property 23: Invalid data is rejected by security rules Medications with wrong userId are rejected
00:04 +4: All tests passed!
```

Each test runs 20 iterations, so it may take a few minutes.

## What Gets Tested

### Property 21: Data Access Authorization (40 iterations total)
- ✅ Authenticated users can create, read, update, delete their own data
- ✅ Users cannot access other users' data (read, update, delete all denied)

### Property 22: Unauthenticated Access Denial (20 iterations)
- ✅ Unauthenticated users cannot read any protected data
- ✅ Unauthenticated users cannot create, update, or delete data

### Property 23: Data Validation (20 iterations)
- ✅ Documents with wrong userId are rejected
- ✅ Security rules enforce ownership validation

## Troubleshooting

### Tests Still Skip

**Problem**: Tests show "Skip: Firebase emulators not available"

**Solutions**:
1. Verify emulators are running: `firebase emulators:start`
2. Check ports are available (9099, 8080, 9199)
3. Ensure no firewall is blocking localhost connections

### Connection Errors

**Problem**: Tests fail with connection errors

**Solutions**:
1. Restart emulators: Stop with Ctrl+C, then `firebase emulators:start`
2. Clear emulator data: `firebase emulators:start --clear-data`
3. Check `firebase.json` configuration

### Permission Denied Errors (Expected!)

**This is normal!** The tests verify that unauthorized access is properly denied. You should see permission denied errors in the test output - this means security rules are working correctly.

**Only worry if**:
- Authorized access is denied (test fails)
- Unauthorized access is allowed (test fails)

### Tests Timeout

**Problem**: Tests hang or timeout

**Solutions**:
1. Increase timeout: Add `--timeout=5m` to test command
2. Reduce iterations: Edit test file, change `iterations: 20` to `iterations: 5`
3. Check emulator logs for errors

## Verification Checklist for Task 26

Use this checklist during manual verification:

- [ ] Firebase emulators started successfully
- [ ] All 4 security property tests pass
- [ ] No unexpected permission errors
- [ ] Test output shows 80 total iterations (20 per test × 4 tests)
- [ ] Emulator UI accessible at http://127.0.0.1:4000
- [ ] Can view test data in Emulator UI (Auth, Firestore)
- [ ] Security rules match `firestore.rules` file
- [ ] All test users are properly isolated (no cross-user access)

## Advanced: Running in CI/CD

For automated testing in CI/CD pipelines:

```bash
#!/bin/bash

# Start emulators in background
firebase emulators:start --only auth,firestore,storage &
EMULATOR_PID=$!

# Wait for emulators to be ready
echo "Waiting for emulators to start..."
sleep 10

# Run security tests
flutter test test/features/security/security_rules_verification_tests.dart

# Capture exit code
TEST_EXIT_CODE=$?

# Stop emulators
kill $EMULATOR_PID

# Exit with test result
exit $TEST_EXIT_CODE
```

## Viewing Test Data

While tests are running, you can view the test data in the Emulator UI:

1. Open http://127.0.0.1:4000 in your browser
2. Click "Authentication" to see test users
3. Click "Firestore" to see test documents
4. Watch data being created and deleted during tests

This is helpful for debugging if tests fail.

## Performance Notes

- Each test iteration creates and cleans up test data
- 80 total iterations means ~80 users, ~80 medications created
- Tests typically complete in 2-5 minutes
- Emulators use ~200MB RAM during testing

## After Testing

1. Stop emulators: Press Ctrl+C in the emulator terminal
2. Emulator data is automatically cleared between test runs
3. No cleanup needed - emulators are isolated from production

## Success Criteria

For task 26 verification to be complete:

✅ All 4 property tests pass  
✅ 80 total test iterations complete successfully  
✅ No unexpected errors in emulator logs  
✅ Security rules correctly enforce data isolation  
✅ Unauthenticated access properly denied  
✅ Invalid data properly rejected  

## Next Steps

After security tests pass:
1. Document results in verification report (Task 27)
2. Note any security rule improvements needed
3. Verify security rules in production Firebase console match emulator rules

## Questions?

See also:
- `test/features/security/README.md` - General security testing documentation
- `test/features/security/IMPLEMENTATION_NOTES.md` - Implementation details
- `firestore.rules` - Security rules being tested
- Firebase Emulator Suite docs: https://firebase.google.com/docs/emulator-suite
