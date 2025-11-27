# Google Sign-In Quick Fix 🔧

## Your SHA-1 Fingerprint

```
49:D3:C4:49:14:FC:11:4D:C8:03:2A:EA:D5:9B:AC:89:70:0D:49:2A
```

## Fix Steps (2 minutes)

### 1. Open Firebase Console

Go to: https://console.firebase.google.com/project/medmind-b5e0f/settings/general

### 2. Add SHA-1 Fingerprint

1. Scroll to "Your apps" section
2. Find your Android app
3. Click "Add fingerprint"
4. Paste: `49:D3:C4:49:14:FC:11:4D:C8:03:2A:EA:D5:9B:AC:89:70:0D:49:2A`
5. Click Save

### 3. Download New Config

1. Click "Download google-services.json"
2. Replace file in `android/app/google-services.json`

### 4. Rebuild App

```bash
flutter clean
flutter pub get
flutter run
```

### 5. Test

1. Open app
2. Tap "Sign in with Google"
3. Should work! ✅

## Alternative: Use Email Sign-In

Email/password sign-in is already working perfectly! No configuration needed.

**To use:**
1. Tap "Sign Up" on login page
2. Enter email and password
3. Works immediately! ✅

---

**Recommendation:** For demos and testing, use email sign-in. It's simpler and already functional! 🚀
