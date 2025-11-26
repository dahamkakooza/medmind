# Google Sign-In Setup Guide

## Current Status
Google Sign-In is **implemented in the code** but requires Firebase Console configuration to work properly.

## Why It's Not Working
Google Sign-In requires:
1. SHA-1 certificate fingerprint registered in Firebase Console
2. OAuth 2.0 Client ID configured
3. Google Sign-In enabled in Firebase Authentication

## Setup Steps

### 1. Get Your SHA-1 Fingerprint

**For Debug Build (Development):**
```bash
cd android
./gradlew signingReport
```

Look for the **SHA-1** under `Variant: debug` and copy it.

**For macOS/Linux:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 2. Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **medmind**
3. Click the gear icon ⚙️ → **Project Settings**
4. Scroll down to **Your apps**
5. Select your Android app
6. Click **Add fingerprint**
7. Paste your SHA-1 fingerprint
8. Click **Save**

### 3. Enable Google Sign-In in Firebase

1. In Firebase Console, go to **Authentication**
2. Click **Sign-in method** tab
3. Click **Google**
4. Toggle **Enable**
5. Set **Project support email** (your email)
6. Click **Save**

### 4. Download Updated google-services.json

1. In Firebase Console → **Project Settings**
2. Scroll to **Your apps** → Android app
3. Click **google-services.json** to download
4. Replace the file in: `android/app/google-services.json`

### 5. Restart the App

```bash
# Stop the current app
# In terminal where flutter run is active, press 'q'

# Clean and rebuild
flutter clean
flutter pub get

# Run again
flutter run
```

## Testing Google Sign-In

After setup:
1. Click **"Continue with Google"** button
2. Select your Google account
3. Grant permissions
4. You should be signed in and redirected to the dashboard

## Troubleshooting

### Error: "Sign-in failed"
- **Cause**: SHA-1 not registered or incorrect
- **Fix**: Double-check SHA-1 fingerprint in Firebase Console

### Error: "Developer error"
- **Cause**: OAuth client not configured
- **Fix**: Ensure Google Sign-In is enabled in Firebase Authentication

### Error: "Network error"
- **Cause**: No internet connection or Firebase not reachable
- **Fix**: Check internet connection and Firebase status

### Error: "Sign-in cancelled"
- **Cause**: User cancelled the Google Sign-In flow
- **Fix**: This is normal user behavior, try again

## Alternative: Email/Password Sign-In

While setting up Google Sign-In, you can use **Email/Password authentication** which is already fully functional:

1. Click **"Sign Up"** on login page
2. Fill in your details
3. Create account
4. Sign in with email and password

## For iOS Setup (If Testing on iPhone)

1. Get your iOS Bundle ID from `ios/Runner.xcodeproj`
2. Add iOS app in Firebase Console
3. Download `GoogleService-Info.plist`
4. Place in `ios/Runner/`
5. Add URL scheme in `ios/Runner/Info.plist`

## Need Help?

- [Firebase Google Sign-In Docs](https://firebase.google.com/docs/auth/android/google-signin)
- [Flutter Google Sign-In Package](https://pub.dev/packages/google_sign_in)

---

**Note**: Google Sign-In setup is **optional**. The app works perfectly with Email/Password authentication!
