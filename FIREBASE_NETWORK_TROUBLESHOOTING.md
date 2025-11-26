# Firebase Network Error Troubleshooting

## 🔴 Current Issue

You're seeing this error when trying to sign up or log in:

```
E/RecaptchaCallWrapper: Initial task failed for action RecaptchaAction(action=signUpPassword)
with exception - A network error (such as timeout, interrupted connection or unreachable host) has occurred.
```

## 🎯 Root Causes

### 1. Emulator Network Configuration
The Android emulator may not have proper network access to Firebase servers.

### 2. Firebase Configuration
Firebase may not be properly configured for your project.

### 3. App Check Not Configured
The warning `No AppCheckProvider installed` indicates App Check is not set up (this is optional but recommended).

---

## ✅ Solutions

### Solution 1: Check Emulator Internet Connection

**Test if emulator has internet:**
```bash
# Open emulator terminal
adb shell ping -c 4 8.8.8.8
```

If ping fails, restart the emulator:
```bash
# Kill and restart emulator
flutter run
```

### Solution 2: Use Real Device Instead

The emulator sometimes has network issues. Try on a real device:

```bash
# Connect your phone via USB
# Enable USB debugging on phone
flutter run
```

### Solution 3: Check Firebase Configuration

1. **Verify google-services.json exists:**
```bash
ls android/app/google-services.json
```

2. **Check if it's the correct file:**
   - Open Firebase Console
   - Go to Project Settings
   - Download google-services.json again
   - Replace the file in `android/app/`

3. **Rebuild the app:**
```bash
flutter clean
flutter pub get
flutter run
```

### Solution 4: Disable reCAPTCHA (Development Only)

For development, you can disable reCAPTCHA verification:

1. Go to Firebase Console
2. Navigate to Authentication → Settings
3. Under "App verification", disable reCAPTCHA for development

⚠️ **Warning**: Only do this for development/testing!

### Solution 5: Configure Firebase Emulator Suite (Recommended for Development)

Use Firebase Local Emulator instead of production:

1. **Install Firebase CLI:**
```bash
npm install -g firebase-tools
```

2. **Initialize emulators:**
```bash
firebase init emulators
# Select: Authentication, Firestore
```

3. **Start emulators:**
```bash
firebase emulators:start
```

4. **Update your app to use emulators** (add to `lib/config/firebase_config.dart`):
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> useFirebaseEmulator() async {
  // Use emulator for Auth
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  
  // Use emulator for Firestore
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
}
```

### Solution 6: Check Firestore Rules

Your Firestore rules might be blocking access:

1. Go to Firebase Console → Firestore Database → Rules
2. For testing, use these rules (⚠️ **NOT for production**):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Solution 7: Wait and Retry

Sometimes Firebase has temporary connectivity issues:

1. Wait 30 seconds
2. Try signing up again
3. If it fails 3 times, try a different solution

---

## 🔍 Diagnostic Steps

### Step 1: Check Firebase Status
Visit: https://status.firebase.google.com/
- Verify all services are operational

### Step 2: Test Network Connectivity
```bash
# From your computer
ping firebase.googleapis.com

# From emulator
adb shell ping firebase.googleapis.com
```

### Step 3: Check Logs for More Details
```bash
flutter run --verbose
```

Look for:
- SSL/TLS errors
- DNS resolution failures
- Timeout errors

### Step 4: Verify Firebase Project ID
Check `android/app/google-services.json`:
```json
{
  "project_info": {
    "project_id": "your-project-id"  // Should match Firebase Console
  }
}
```

---

## 🎯 Quick Fix for Testing

If you just want to test the UI without Firebase:

1. **Comment out Firebase initialization** in `lib/main.dart`:
```dart
// await FirebaseConfig.initialize();  // Comment this out
```

2. **Use mock authentication** (temporary):
```dart
// In AuthBloc, return success immediately
emit(Authenticated(user: mockUser));
```

3. **Test the UI flow** without real authentication

---

## ✅ Verification

After applying fixes, verify:

1. **Sign Up Works:**
```
1. Enter email: test@example.com
2. Enter password: password123
3. Click Sign Up
4. ✅ Should navigate to Dashboard
```

2. **Login Works:**
```
1. Enter same credentials
2. Click Login
3. ✅ Should navigate to Dashboard
```

3. **No Network Errors in Logs:**
```bash
flutter run | grep -i "network error"
# Should show nothing
```

---

## 📝 Current Status

Based on your logs:

✅ **App compiles and runs**  
✅ **UI loads correctly**  
✅ **Firebase initializes**  
❌ **Network connectivity to Firebase fails**  
❌ **Sign up/Login cannot complete**  

**Most Likely Cause**: Emulator network configuration issue

**Recommended Solution**: Try on a real device OR use Firebase Emulator Suite

---

## 🆘 Still Not Working?

If none of these solutions work:

1. **Share your Firebase Console settings:**
   - Authentication methods enabled
   - Firestore rules
   - Project ID

2. **Try creating a new Firebase project:**
   - Sometimes project configuration gets corrupted
   - Create fresh project
   - Download new google-services.json

3. **Check Android emulator settings:**
   - Ensure "Use host GPU" is enabled
   - Try different emulator image
   - Increase emulator RAM

---

## 💡 Prevention

To avoid this in the future:

1. **Use Firebase Emulator Suite for development**
2. **Test on real devices regularly**
3. **Keep Firebase SDK updated**
4. **Monitor Firebase status page**
5. **Have offline fallback in your app**

