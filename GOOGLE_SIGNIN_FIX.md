# Google Sign-In Fix - SHA-1 Configuration

## Issue
Google Sign-In failing with error: `ApiException: 10`

This means the SHA-1 fingerprint is not configured in Firebase Console.

## Your SHA-1 Fingerprint
```
49:D3:C4:49:14:FC:11:4D:C8:03:2A:EA:D5:9B:AC:89:70:0D:49:2A
```

## Fix Steps

### 1. Open Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your **MedMind** project
3. Click the **gear icon** (⚙️) next to "Project Overview"
4. Select **Project settings**

### 2. Add SHA-1 Fingerprint
1. Scroll down to **"Your apps"** section
2. Find your Android app (com.example.medmind or similar)
3. Click on the Android app
4. Scroll to **"SHA certificate fingerprints"** section
5. Click **"Add fingerprint"**
6. Paste this SHA-1:
   ```
   49:D3:C4:49:14:FC:11:4D:C8:03:2A:EA:D5:9B:AC:89:70:0D:49:2A
   ```
7. Click **"Save"**

### 3. Download New google-services.json
1. After adding the SHA-1, click **"Download google-services.json"**
2. Replace the file at: `android/app/google-services.json`
3. **Important**: Make sure to replace the existing file

### 4. Rebuild the App
```bash
flutter clean
flutter pub get
flutter run
```

### 5. Test Google Sign-In
1. Launch the app
2. Tap "Sign in with Google"
3. Select your Google account
4. ✅ Should sign in successfully!

---

## Alternative: Quick Command to Get SHA-1

If you need to get the SHA-1 again in the future:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep "SHA1"
```

---

## For Release Build (Production)

When you create a release build, you'll need to add the release SHA-1 as well:

```bash
keytool -list -v -keystore /path/to/your/release.keystore -alias your-key-alias
```

Then add that SHA-1 to Firebase Console following the same steps above.

---

## Troubleshooting

### If Google Sign-In Still Fails:

1. **Check Package Name**
   - In Firebase Console, verify the package name matches your app
   - Check `android/app/build.gradle` → `applicationId`

2. **Wait 5-10 Minutes**
   - Firebase changes can take a few minutes to propagate
   - Try again after waiting

3. **Clear App Data**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Check OAuth Client**
   - In Firebase Console → Authentication → Sign-in method
   - Verify Google is enabled
   - Check that OAuth client is configured

---

## Success Criteria

✅ SHA-1 added to Firebase Console
✅ New google-services.json downloaded
✅ App rebuilt with `flutter clean`
✅ Google Sign-In works without ApiException: 10

---

## Quick Reference

**Your Debug SHA-1:**
```
49:D3:C4:49:14:FC:11:4D:C8:03:2A:EA:D5:9B:AC:89:70:0D:49:2A
```

**Firebase Console:**
https://console.firebase.google.com/

**Steps:**
1. Add SHA-1 to Firebase Console
2. Download new google-services.json
3. Replace android/app/google-services.json
4. Run `flutter clean && flutter run`
5. Test Google Sign-In ✅
