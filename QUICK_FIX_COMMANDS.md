# Quick Fix Commands

## 🚀 Try These Commands in Order

### 1. Test on Real Device (Easiest)
```bash
# Connect your phone via USB
# Enable USB debugging on phone
flutter run
# Select your device when prompted
```

### 2. Restart Emulator
```bash
# Stop current app (Ctrl+C in terminal)
# Then restart:
flutter run
```

### 3. Check Emulator Internet
```bash
# Test if emulator has internet
adb shell ping -c 4 8.8.8.8

# If it fails, restart emulator completely
```

### 4. Clean and Rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### 5. Verify Firebase Config
```bash
# Check if file exists
ls android/app/google-services.json

# If missing, download from Firebase Console
# Then rebuild
```

### 6. Use Firebase Emulator (For Development)
```bash
# Install Firebase CLI (one time)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize emulators in your project
firebase init emulators
# Select: Authentication, Firestore

# Start emulators
firebase emulators:start

# In another terminal, run app
flutter run
```

## 🎯 Expected Results

### After Fix Works:
```
✅ Sign up completes successfully
✅ User is created in Firebase
✅ App navigates to Dashboard
✅ No network errors in logs
```

### Test Flow:
```bash
1. flutter run
2. Click "Sign Up"
3. Enter test credentials
4. Click "Create Account"
5. Should see Dashboard!
```

## 📱 Device vs Emulator

### Real Device (Recommended)
**Pros:**
- More reliable network
- Faster performance
- Real-world testing

**Cons:**
- Need physical device
- Need USB cable

### Emulator
**Pros:**
- No physical device needed
- Easy to test different screen sizes

**Cons:**
- Network issues (like you're experiencing)
- Slower performance

## 🔧 If Nothing Works

### Last Resort: Disable Firebase Temporarily

Edit `lib/main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // COMMENT OUT Firebase initialization for testing
    // await FirebaseConfig.initialize();
    
    await NotificationUtils.initialize();
    final sharedPreferences = await SharedPreferences.getInstance();
    runApp(MedMindApp(sharedPreferences: sharedPreferences));
  } catch (e) {
    // ...
  }
}
```

Then test UI without Firebase (won't save data but you can see the flow).

## 📞 Need More Help?

See these files:
- `FIREBASE_NETWORK_TROUBLESHOOTING.md` - Detailed solutions
- `CURRENT_ISSUE_SUMMARY.md` - Problem explanation
- `QUICK_START.md` - General guide

