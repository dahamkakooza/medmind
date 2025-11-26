# Java Upgrade Instructions for Firebase Emulators

**Status:** Pending - To be completed after Task 28  
**Current Java:** 1.8.0_421  
**Required Java:** 11 or higher (21 recommended)

---

## Why Upgrade Java?

The Firebase Firestore and Storage emulators require Java 11 or higher to function properly. Currently, only the Auth emulator works with Java 1.8.

**Current Status:**
- ✅ Auth Emulator: Working with Java 1.8
- ⚠️ Firestore Emulator: Requires Java 11+
- ⚠️ Storage Emulator: Requires Java 11+

---

## Installation Steps

### Option 1: Install Downloaded Java Package

If you've already downloaded a Java installer (.dmg or .pkg):

1. **Locate the installer** in your Downloads folder
2. **Double-click** the installer file
3. **Follow the installation wizard**
4. **Verify installation:**
   ```bash
   /usr/libexec/java_home -V
   ```

### Option 2: Install via Homebrew (Recommended)

```bash
# Install OpenJDK 11
brew install openjdk@11

# Create symlink
sudo ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk \
  /Library/Java/JavaVirtualMachines/openjdk-11.jdk

# Verify installation
/usr/libexec/java_home -V
```

### Option 3: Install OpenJDK 21 (Future-proof)

```bash
# Install OpenJDK 21
brew install openjdk@21

# Create symlink
sudo ln -sfn /usr/local/opt/openjdk@21/libexec/openjdk.jdk \
  /Library/Java/JavaVirtualMachines/openjdk-21.jdk

# Verify installation
/usr/libexec/java_home -V
```

---

## Setting JAVA_HOME

After installation, set JAVA_HOME to use the new version:

### Temporary (Current Terminal Session)

```bash
# For Java 11
export JAVA_HOME=$(/usr/libexec/java_home -v 11)

# For Java 21
export JAVA_HOME=$(/usr/libexec/java_home -v 21)

# Verify
java -version
```

### Permanent (All Terminal Sessions)

Add to your shell profile (`~/.zshrc` for zsh or `~/.bash_profile` for bash):

```bash
# For Java 11
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 11)' >> ~/.zshrc

# For Java 21
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 21)' >> ~/.zshrc

# Reload shell configuration
source ~/.zshrc
```

---

## Verification Steps

### 1. Check Java Version

```bash
java -version
```

**Expected output (Java 11):**
```
openjdk version "11.0.x"
OpenJDK Runtime Environment (build 11.0.x)
OpenJDK 64-Bit Server VM (build 11.0.x, mixed mode)
```

**Expected output (Java 21):**
```
openjdk version "21.0.x"
OpenJDK Runtime Environment (build 21.0.x)
OpenJDK 64-Bit Server VM (build 21.0.x, mixed mode, sharing)
```

### 2. Check Available Java Versions

```bash
/usr/libexec/java_home -V
```

**Expected output:**
```
Matching Java Virtual Machines (2):
    21.0.x (arm64) "Homebrew" - "OpenJDK 21.0.x" /usr/local/Cellar/openjdk@21/...
    1.8.421.09 (x86_64) "Oracle Corporation" - "Java" /Library/Internet Plug-Ins/...
```

### 3. Test Firebase Emulators

```bash
# Start all emulators
firebase emulators:start
```

**Expected output:**
```
✔  All emulators ready! It is now safe to connect your app.
┌────────────────┬────────────────┬────────────────────────────┐
│ Emulator       │ Host:Port      │ View in Emulator UI        │
├────────────────┼────────────────┼────────────────────────────┤
│ Authentication │ 127.0.0.1:9099 │ http://127.0.0.1:4000/auth │
├────────────────┼────────────────┼────────────────────────────┤
│ Firestore      │ 127.0.0.1:8080 │ http://127.0.0.1:4000/firestore │
├────────────────┼────────────────┼────────────────────────────┤
│ Storage        │ 127.0.0.1:9199 │ http://127.0.0.1:4000/storage │
└────────────────┴────────────────┴────────────────────────────┘
```

### 4. Run Security Tests

In a new terminal:

```bash
flutter test test/features/security/security_rules_verification_tests.dart
```

**Expected output:**
```
00:00 +0: Firebase Security Rules Verification (setUpAll)
✓ Connected to Auth emulator at localhost:9099
✓ Connected to Firestore emulator at localhost:8080
✓ Connected to Storage emulator at localhost:9199

00:01 +1: Property 21: Authenticated users can read and write their own data
  ✓ All 20 iterations passed

00:02 +2: Property 21: Users cannot access other users' data
  ✓ All 20 iterations passed

00:03 +3: Property 22: Unauthenticated users cannot access protected data
  ✓ All 20 iterations passed

00:04 +4: Property 23: Invalid data is rejected by security rules
  ✓ All 20 iterations passed

00:04 +4: All tests passed!
```

---

## Troubleshooting

### Issue: Java version still shows 1.8

**Problem:** After installation, `java -version` still shows 1.8

**Solution:**
```bash
# Check available versions
/usr/libexec/java_home -V

# Set JAVA_HOME explicitly
export JAVA_HOME=$(/usr/libexec/java_home -v 11)

# Verify
java -version

# Make permanent
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 11)' >> ~/.zshrc
source ~/.zshrc
```

### Issue: Emulators still fail to start

**Problem:** Firestore emulator fails even with Java 11+

**Solution:**
```bash
# Clear Firebase cache
rm -rf ~/.cache/firebase/emulators/

# Restart emulators
firebase emulators:start
```

### Issue: Permission denied when creating symlink

**Problem:** `sudo ln -sfn` fails with permission error

**Solution:**
```bash
# Use sudo with correct permissions
sudo ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk \
  /Library/Java/JavaVirtualMachines/openjdk-11.jdk

# If still fails, check if directory exists
sudo mkdir -p /Library/Java/JavaVirtualMachines/
```

---

## Post-Upgrade Checklist

After upgrading Java, verify:

- [ ] `java -version` shows Java 11 or higher
- [ ] `/usr/libexec/java_home -V` lists the new version
- [ ] `firebase emulators:start` starts all emulators successfully
- [ ] Firestore emulator accessible at http://127.0.0.1:8080
- [ ] Storage emulator accessible at http://127.0.0.1:9199
- [ ] Security tests pass: `flutter test test/features/security/`
- [ ] All 4 property tests pass with 20 iterations each

---

## Benefits After Upgrade

Once Java 11+ is installed:

1. **Full Emulator Support**
   - ✅ Auth emulator
   - ✅ Firestore emulator
   - ✅ Storage emulator

2. **Complete Security Testing**
   - ✅ User data isolation tests
   - ✅ Authentication requirement tests
   - ✅ Invalid data rejection tests
   - ✅ Cross-user access prevention tests

3. **Local Development**
   - ✅ Test without internet connection
   - ✅ Fast test execution
   - ✅ No Firebase quota usage
   - ✅ Easy data inspection via Emulator UI

4. **CI/CD Ready**
   - ✅ Automated testing in pipelines
   - ✅ Consistent test environment
   - ✅ No production data contamination

---

## Timeline

**Current Status:** Task 26 complete, Java 1.8 in use  
**Planned Upgrade:** After Task 28  
**Estimated Time:** 10-15 minutes  
**Impact:** Enables full Firebase emulator testing

---

## Summary

The Java upgrade is **optional but recommended** for complete Firebase emulator testing. The current system works well with:
- ✅ All 64 automated tests passing
- ✅ Auth emulator functional
- ✅ Security tests skip gracefully

After upgrading to Java 11+, you'll gain:
- ✅ Full Firestore emulator support
- ✅ Storage emulator support
- ✅ Complete security rules testing
- ✅ Better local development experience

---

**Next Steps:**
1. Complete Tasks 27 and 28
2. Install Java 11+ (via downloaded installer or Homebrew)
3. Set JAVA_HOME environment variable
4. Test Firebase emulators
5. Run security tests to verify

**Documentation:** This file will be updated after the Java upgrade is complete.

---

**Created:** November 26, 2025  
**Status:** Pending Java upgrade after Task 28  
**Priority:** Medium (optional but recommended)
