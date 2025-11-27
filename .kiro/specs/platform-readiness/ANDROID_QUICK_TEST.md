# Android Quick Test - 5 Minutes

## Test Checklist

### 1. Launch App ✓
- [ ] Run `flutter run` on Android device/emulator
- [ ] Verify app launches without errors
- [ ] Splash screen displays correctly

### 2. Google Sign-In ✓
- [ ] Tap "Sign in with Google" button
- [ ] Complete Google OAuth flow
- [ ] Verify successful login
- [ ] Verify navigation to Dashboard

### 3. Add Medication with Notifications ✓
- [ ] Tap "Add Medication" (+ button)
- [ ] Enter medication name: **"Test Med"**
- [ ] Select frequency: **"DEMO: 1, 2, 3 min"**
- [ ] Enter dosage: **"100mg"**
- [ ] Tap **Save**
- [ ] Verify medication appears in Medications list
- [ ] **Wait 1 minute** for notification
- [ ] Verify notification appears in notification tray
- [ ] Tap notification - verify it opens the app

### 4. Update Medication ✓
- [ ] Navigate to **Medications** tab
- [ ] Tap on **"Test Med"** card
- [ ] Tap **edit icon** (pencil) in app bar
- [ ] Change dosage to **"200mg"**
- [ ] Tap **Save**
- [ ] Verify dosage updated to "200mg" in detail view
- [ ] Go back to list
- [ ] Verify dosage shows "200mg" in medication card

### 5. Dashboard & Pending Doses ✓
- [ ] Navigate to **Dashboard** tab
- [ ] Verify "Test Med" appears in today's medications
- [ ] Check **badge count** on Pending Doses icon
- [ ] Tap **Pending Doses** button
- [ ] Verify "Test Med" appears in pending dose list
- [ ] Tap **"Mark as Taken"** button
- [ ] Verify badge count decreases by 1
- [ ] Verify dose removed from pending list

### 6. Sign Out ✓
- [ ] Navigate to **Profile** tab
- [ ] Scroll down to **"Logout"** button
- [ ] Tap **"Logout"**
- [ ] Confirm logout in dialog
- [ ] Verify app returns to **login screen**
- [ ] Verify Android back button doesn't navigate to authenticated screens

---

## Quick Commands

**Run on Android:**
```bash
flutter run -d <device-id>
```

**Check connected devices:**
```bash
flutter devices
```

**If you need to rebuild:**
```bash
flutter clean
flutter pub get
flutter run
```

---

## Success Criteria

✅ Google Sign-In works
✅ Medication added successfully
✅ Notification appears after 1 minute
✅ Medication can be edited
✅ Dashboard displays medication
✅ Pending doses tracked correctly
✅ Sign out returns to login

---

## Notes

- Use **DEMO mode** for quick notification testing (1, 2, 3 min)
- If notification doesn't appear, check Android notification permissions
- If Google Sign-In fails, verify SHA-1 is configured in Firebase Console
- Document any issues or crashes immediately

---

## Issues Found

Document any problems here:

- [ ] Issue 1: _______________
- [ ] Issue 2: _______________
- [ ] Issue 3: _______________
