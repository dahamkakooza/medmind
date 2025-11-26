# Firebase & Firestore Setup Guide for MedMind

This guide will walk you through setting up Firebase and Firestore for the MedMind application, including configuration, security rules, and testing.

## 📋 Prerequisites

- A Google account
- Flutter SDK installed
- Firebase CLI installed (optional, for deploying rules)
- Android Studio / Xcode (for platform-specific setup)

---

## Step 1: Create a Firebase Project

### 1.1 Go to Firebase Console
1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project name: `medmind` (or your preferred name)
4. Click **Continue**

### 1.2 Configure Google Analytics (Optional)
- You can enable or disable Google Analytics
- For development, you can skip this
- Click **Continue** → **Create project**

### 1.3 Wait for Project Creation
- Firebase will create your project (takes ~30 seconds)
- Click **Continue** when ready

---

## Step 2: Add Your Flutter App to Firebase

### 2.1 Add Android App
1. In Firebase Console, click the **Android icon** (or **Add app** → **Android**)
2. **Android package name**: Check your `android/app/build.gradle.kts` file
   - Look for `applicationId` (usually `com.example.medmind` or similar)
   - Enter this package name
3. **App nickname** (optional): `MedMind Android`
4. **Debug signing certificate SHA-1** (optional for now, needed for Google Sign-In later)
5. Click **Register app**

### 2.2 Download Configuration File for Android
1. Download `google-services.json`
2. **IMPORTANT**: Place it in `android/app/` directory
   ```
   android/app/google-services.json
   ```
3. **DO NOT** commit this file to git (it's in .gitignore)

### 2.3 Add iOS App (if developing for iOS)
1. Click **Add app** → **iOS**
2. **iOS bundle ID**: Check `ios/Runner/Info.plist` or Xcode project settings
   - Usually `com.example.medmind` or similar
3. **App nickname**: `MedMind iOS`
4. Click **Register app**

### 2.4 Download Configuration File for iOS
1. Download `GoogleService-Info.plist`
2. **IMPORTANT**: Place it in `ios/Runner/` directory
   ```
   ios/Runner/GoogleService-Info.plist
   ```
3. **DO NOT** commit this file to git

---

## Step 3: Enable Firebase Services

### 3.1 Enable Authentication
1. In Firebase Console, go to **Build** → **Authentication**
2. Click **Get started**
3. Enable **Email/Password**:
   - Click **Email/Password**
   - Toggle **Enable**
   - Click **Save**
4. Enable **Google Sign-In** (optional):
   - Click **Google**
   - Toggle **Enable**
   - Enter support email
   - Click **Save**

### 3.2 Enable Firestore Database
1. Go to **Build** → **Firestore Database**
2. Click **Create database**
3. Choose **Start in test mode** (we'll add security rules next)
4. Select a **location** (choose closest to your users)
5. Click **Enable**

---

## Step 4: Configure Firebase in Your Code

### 4.1 Method 1: Using FlutterFire CLI (Recommended)

This is the easiest way to configure Firebase:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure
```

This will:
- Detect your Firebase project
- Generate `lib/firebase_options.dart` automatically
- Configure for all platforms (Android, iOS, Web)

### 4.2 Method 2: Manual Configuration

If you prefer manual setup, update `lib/config/firebase_config.dart`:

1. **Get your Firebase configuration:**
   - Go to Firebase Console → Project Settings (gear icon)
   - Scroll to **Your apps** section
   - Click on your Android/iOS app
   - Copy the configuration values

2. **Update `firebase_config.dart`:**

```dart
static FirebaseOptions _getFirebaseOptions() {
  if (kIsWeb) {
    return const FirebaseOptions(
      apiKey: 'YOUR_ACTUAL_WEB_API_KEY',
      appId: 'YOUR_ACTUAL_WEB_APP_ID',
      messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
      projectId: 'YOUR_ACTUAL_PROJECT_ID',
      authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
      storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    );
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    return const FirebaseOptions(
      apiKey: 'YOUR_ACTUAL_ANDROID_API_KEY',
      appId: 'YOUR_ACTUAL_ANDROID_APP_ID',
      messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
      projectId: 'YOUR_ACTUAL_PROJECT_ID',
      storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    return const FirebaseOptions(
      apiKey: 'YOUR_ACTUAL_IOS_API_KEY',
      appId: 'YOUR_ACTUAL_IOS_APP_ID',
      messagingSenderId: 'YOUR_ACTUAL_SENDER_ID',
      projectId: 'YOUR_ACTUAL_PROJECT_ID',
      storageBucket: 'YOUR_PROJECT_ID.appspot.com',
      iosBundleId: 'com.example.medmind', // Update this to match your bundle ID
    );
  }
  
  throw UnsupportedError('Platform not supported');
}
```

### 4.3 Initialize Firebase in main.dart

Update `lib/main.dart` to initialize Firebase:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'config/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase FIRST
  await FirebaseConfig.initialize();
  
  // Then initialize other services
  final sharedPreferences = await SharedPreferences.getInstance();
  await NotificationUtils.initialize();
  
  runApp(MedMindApp(sharedPreferences: sharedPreferences));
}
```

---

## Step 5: Set Up Firestore Security Rules

### 5.1 Create Firestore Security Rules File

Create `firestore.rules` in your project root:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the resource
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection - users can only read/write their own data
    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }
    
    // Medications collection - users can only access their own medications
    match /medications/{medicationId} {
      allow read, write: if isOwner(resource.data.userId);
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
    }
    
    // Adherence logs - users can only access their own logs
    match /adherence_logs/{logId} {
      allow read, write: if isOwner(resource.data.userId);
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
    }
    
    // Pharmacy prices - read-only for all authenticated users
    match /pharmacy_prices/{priceId} {
      allow read: if isAuthenticated();
      allow write: if false; // No one can write (admin only via console)
    }
  }
}
```

### 5.2 Deploy Security Rules

**Option A: Using Firebase Console (Easiest)**
1. Go to Firebase Console → Firestore Database → Rules
2. Copy the rules from `firestore.rules`
3. Paste into the console
4. Click **Publish**

**Option B: Using Firebase CLI**
```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project (if not done)
firebase init firestore

# Deploy rules
firebase deploy --only firestore:rules
```

### 5.3 Create Storage Rules (Optional)

Create `storage.rules` for Firebase Storage:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User avatars - users can only upload/read their own
    match /user_avatars/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Barcode images - users can only upload/read their own
    match /barcode_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Medication images - users can only upload/read their own
    match /medication_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Deploy storage rules:
```bash
firebase deploy --only storage
```

---

## Step 6: Deploy Firestore Indexes

The `firestore.indexes.json` file we created contains composite indexes needed for efficient queries.

### 6.1 Deploy Indexes via Firebase Console
1. Go to Firebase Console → Firestore Database → Indexes
2. Click **Add Index**
3. Manually add each index from `firestore.indexes.json`

### 6.2 Deploy Indexes via Firebase CLI (Easier)
```bash
firebase deploy --only firestore:indexes
```

---

## Step 7: Test Your Firebase Connection

### 7.1 Create a Test File

Create `lib/test_firebase_connection.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseConnectionTest {
  static Future<void> testConnection() async {
    try {
      // Test Firestore connection
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'connected',
      });
      print('✅ Firestore connection successful!');
      
      // Test reading
      final doc = await firestore.collection('test').doc('connection').get();
      print('✅ Firestore read successful: ${doc.data()}');
      
      // Test Auth
      final auth = FirebaseAuth.instance;
      print('✅ Firebase Auth initialized: ${auth.currentUser?.uid ?? "No user"}');
      
      // Clean up test document
      await firestore.collection('test').doc('connection').delete();
      print('✅ Test document deleted');
      
    } catch (e) {
      print('❌ Firebase connection error: $e');
      rethrow;
    }
  }
}
```

### 7.2 Test in Your App

Add this to your `main.dart` temporarily:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await FirebaseConfig.initialize();
  
  // Test Firebase connection
  try {
    await FirebaseConnectionTest.testConnection();
  } catch (e) {
    print('Firebase test failed: $e');
  }
  
  // ... rest of your code
}
```

### 7.3 Test CRUD Operations

Create a simple test widget or add to your existing code:

```dart
// Test adding a medication
final medicationRef = FirebaseFirestore.instance
    .collection('medications')
    .doc();

await medicationRef.set({
  'userId': FirebaseAuth.instance.currentUser?.uid ?? 'test-user',
  'name': 'Test Medication',
  'dosage': '10mg',
  'form': 'tablet',
  'frequency': 'daily',
  'times': [{'hour': 8, 'minute': 0}],
  'days': [1, 2, 3, 4, 5, 6, 7],
  'startDate': Timestamp.now(),
  'isActive': true,
  'createdAt': Timestamp.now(),
  'updatedAt': Timestamp.now(),
});

print('✅ Medication created: ${medicationRef.id}');

// Test reading
final medications = await FirebaseFirestore.instance
    .collection('medications')
    .where('userId', isEqualTo: 'test-user')
    .get();

print('✅ Found ${medications.docs.length} medications');

// Test updating
await medicationRef.update({
  'name': 'Updated Medication',
  'updatedAt': Timestamp.now(),
});

print('✅ Medication updated');

// Test deleting (soft delete)
await medicationRef.update({
  'isActive': false,
  'updatedAt': Timestamp.now(),
});

print('✅ Medication deleted (soft delete)');
```

---

## Step 8: Verify Everything Works

### 8.1 Run Your App
```bash
flutter run
```

### 8.2 Check Firebase Console
1. Go to Firebase Console → Firestore Database → Data
2. You should see your test data
3. Check Authentication → Users (after signing up)

### 8.3 Monitor in Real-Time
1. Firebase Console → Firestore → Data
2. Make changes in your app
3. Watch them appear in real-time in the console

---

## 🔒 Security Checklist

- [ ] Firestore security rules deployed
- [ ] Storage security rules deployed (if using Storage)
- [ ] Authentication enabled
- [ ] Test mode disabled (use proper security rules)
- [ ] Configuration files NOT committed to git
- [ ] API keys are secure (never expose in client code)

---

## 🐛 Troubleshooting

### "FirebaseApp not initialized"
- Make sure `FirebaseConfig.initialize()` is called before using Firebase
- Check that configuration values are correct

### "Permission denied"
- Check Firestore security rules
- Verify user is authenticated
- Check that `userId` matches `request.auth.uid`

### "Index not found"
- Deploy indexes: `firebase deploy --only firestore:indexes`
- Wait a few minutes for indexes to build

### "google-services.json not found"
- Make sure file is in `android/app/` directory
- Check file name is exactly `google-services.json`

---

## 📚 Additional Resources

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/get-started)
- [Firebase Console](https://console.firebase.google.com/)

---

## ✅ Next Steps

1. Set up Firebase project ✅
2. Configure your app ✅
3. Deploy security rules ✅
4. Test CRUD operations ✅
5. Integrate with your repository implementations
6. Test authentication flow
7. Test real-time updates

---

**Note**: Remember to never commit `google-services.json`, `GoogleService-Info.plist`, or `firebase_options.dart` if it contains sensitive data. These are already in `.gitignore`.

