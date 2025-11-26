# Firebase Emulator Setup Guide

This guide provides instructions for setting up and running Firebase emulators to test security rules.

---

## Prerequisites

1. **Firebase CLI**: Install Firebase tools globally
   ```bash
   npm install -g firebase-tools
   ```

2. **Java Runtime**: Firebase emulators require Java 11 or higher
   ```bash
   # Check Java version
   java -version
   
   # Should show version 11 or higher
   # If not, install Java from: https://adoptium.net/
   ```

3. **Firebase Project**: Ensure you're logged in to Firebase
   ```bash
   firebase login
   ```

---

## Emulator Configuration

The project is already configured with emulators in `firebase.json`:

```json
{
  "emulators": {
    "auth": {
      "port": 9099
    },
    "firestore": {
      "port": 8080
    },
    "storage": {
      "port": 9199
    },
    "ui": {
      "enabled": true,
      "port": 4000
    }
  }
}
```

---

## Starting Emulators

### Option 1: Start All Emulators
```bash
# From project root
firebase emulators:start
```

### Option 2: Start Specific Emulators
```bash
# Only Auth and Firestore
firebase emulators:start --only auth,firestore

# Only Firestore
firebase emulators:start --only firestore
```

### Option 3: Start with Import/Export
```bash
# Export data on shutdown
firebase emulators:start --export-on-exit=./emulator-data

# Import data on startup
firebase emulators:start --import=./emulator-data
```

---

## Verifying Emulator Status

Once started, you should see:

```
✔  All emulators ready! It is now safe to connect your app.
┌─────────────────────────────────────────────────────────────┐
│ ✔  All emulators ready! It is now safe to connect your app. │
│ i  View Emulator UI at http://localhost:4000                │
└─────────────────────────────────────────────────────────────┘

┌────────────────┬────────────────┬─────────────────────────────────┐
│ Emulator       │ Host:Port      │ View in Emulator UI             │
├────────────────┼────────────────┼─────────────────────────────────┤
│ Authentication │ localhost:9099 │ http://localhost:4000/auth      │
├────────────────┼────────────────┼─────────────────────────────────┤
│ Firestore      │ localhost:8080 │ http://localhost:4000/firestore │
├────────────────┼────────────────┼─────────────────────────────────┤
│ Storage        │ localhost:9199 │ http://localhost:4000/storage   │
└────────────────┴────────────────┴─────────────────────────────────┘
```

### Check Emulator UI
Open your browser to: http://localhost:4000

You should see:
- Authentication tab with test users
- Firestore tab with collections
- Storage tab with files

---

## Running Security Rules Tests

### Step 1: Start Emulators (Terminal 1)
```bash
firebase emulators:start
```

### Step 2: Run Tests (Terminal 2)
```bash
# Run all security tests
flutter test test/features/security/security_rules_verification_tests.dart

# Run with verbose output
flutter test test/features/security/security_rules_verification_tests.dart --reporter expanded

# Run specific test group
flutter test test/features/security/security_rules_verification_tests.dart --name "Property 21"
```

---

## Expected Test Results

When emulators are running, you should see:

```
00:00 +0: Firebase Security Rules Verification (setUpAll)
✓ Connected to Auth emulator at localhost:9099
✓ Connected to Firestore emulator at localhost:8080
✓ Connected to Storage emulator at localhost:9199

00:01 +1: Property 21: Authenticated users can read and write their own data
  ✓ Iteration 1/20 passed
  ✓ Iteration 2/20 passed
  ...
  ✓ Iteration 20/20 passed

00:02 +2: Property 21: Users cannot access other users' data
  ✓ Iteration 1/20 passed
  ...
  ✓ Iteration 20/20 passed

00:03 +3: Property 22: Unauthenticated users cannot access protected data
  ✓ Iteration 1/20 passed
  ...
  ✓ Iteration 20/20 passed

00:04 +4: Property 23: Invalid data is rejected by security rules
  ✓ Iteration 1/20 passed
  ...
  ✓ Iteration 20/20 passed

00:04 +4: All tests passed!
```

---

## Troubleshooting

### Issue: Emulators Won't Start

**Problem:** Java version incompatibility
```
⚠  firestore: Unsupported java version
```

**Solution:** Install Java 11 or higher
```bash
# macOS (using Homebrew)
brew install openjdk@11

# Ubuntu/Debian
sudo apt-get install openjdk-11-jdk

# Windows
# Download from: https://adoptium.net/
```

---

### Issue: Port Already in Use

**Problem:** Port conflict
```
⚠  firestore: Port 8080 is not available
```

**Solution:** Stop conflicting process or use different port
```bash
# Find process using port
lsof -i :8080

# Kill process
kill -9 <PID>

# Or change port in firebase.json
```

---

### Issue: Tests Skip with "Emulators Not Available"

**Problem:** Tests can't connect to emulators
```
00:00 +0 ~1: Skip: Firebase emulators not available
```

**Solution:** Ensure emulators are running
```bash
# Check if emulators are running
lsof -i :8080 -i :9099 -i :9199

# If not running, start them
firebase emulators:start
```

---

### Issue: Connection Refused

**Problem:** Tests fail to connect
```
SocketException: Connection refused
```

**Solution:** Check emulator status and restart
```bash
# Stop emulators
Ctrl+C in emulator terminal

# Clear emulator data
rm -rf .firebase/

# Restart emulators
firebase emulators:start
```

---

## Emulator UI Features

### Authentication Tab
- View all test users created during tests
- Manually create test users
- View user tokens and claims
- Delete test users

### Firestore Tab
- Browse collections and documents
- View document data
- Manually add/edit/delete documents
- Test security rules with Rules Playground

### Storage Tab
- Browse uploaded files
- View file metadata
- Download files
- Test storage rules

---

## Security Rules Testing

### Rules Playground (Emulator UI)

1. Open http://localhost:4000/firestore
2. Click "Rules" tab
3. Test rules with different scenarios:

**Example: Test User Data Access**
```javascript
// Location
/databases/(default)/documents/users/user123

// Request Type
get

// Authenticated as
user123

// Expected Result
✓ Allow (user can read their own data)
```

**Example: Test Cross-User Access**
```javascript
// Location
/databases/(default)/documents/users/user456

// Request Type
get

// Authenticated as
user123

// Expected Result
✗ Deny (user cannot read other user's data)
```

---

## Best Practices

### 1. Clean State Between Tests
```dart
tearDown(() async {
  await FirebaseTestHelper.cleanup();
});
```

### 2. Use Unique Test Data
```dart
// Generate unique emails for each test
final email = 'test-${DateTime.now().millisecondsSinceEpoch}@example.com';
```

### 3. Verify Both Success and Failure Cases
```dart
// Test that authorized access succeeds
expect(await canRead(ownData), true);

// Test that unauthorized access fails
expect(await canRead(otherUserData), false);
```

### 4. Test All CRUD Operations
- Create (with valid and invalid data)
- Read (own data and other user's data)
- Update (own data and other user's data)
- Delete (own data and other user's data)

---

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Security Rules Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Java
        uses: actions/setup-java@v2
        with:
          distribution: 'adopt'
          java-version: '11'
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
      
      - name: Install Firebase CLI
        run: npm install -g firebase-tools
      
      - name: Start Firebase Emulators
        run: firebase emulators:start &
        
      - name: Wait for Emulators
        run: sleep 10
      
      - name: Run Security Tests
        run: flutter test test/features/security/
      
      - name: Stop Emulators
        run: pkill -f firebase
```

---

## Additional Resources

- [Firebase Emulator Suite Documentation](https://firebase.google.com/docs/emulator-suite)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Storage Security Rules](https://firebase.google.com/docs/storage/security)
- [Testing Security Rules](https://firebase.google.com/docs/rules/unit-tests)

---

## Summary

1. **Install Prerequisites**: Firebase CLI and Java 11+
2. **Start Emulators**: `firebase emulators:start`
3. **Run Tests**: `flutter test test/features/security/`
4. **View Results**: Check terminal output and Emulator UI
5. **Debug Issues**: Use Emulator UI Rules Playground

The security rules tests will automatically skip if emulators aren't available, allowing the test suite to run in environments where emulators can't be started (like some CI systems).

For full security verification, always run tests with emulators to ensure Firebase security rules are properly protecting user data.
