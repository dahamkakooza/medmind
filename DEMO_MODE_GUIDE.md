# Demo Mode - Quick Notification Testing 🧪

## The Problem

Testing notifications with real times (8 AM, 2 PM, etc.) is impractical for demonstrations. You'd have to wait hours to see notifications!

## The Solution: DEMO Mode

We've added **DEMO frequency options** that schedule notifications for **1, 2, and 3 minutes from now**. Perfect for quick demonstrations!

## How to Use Demo Mode

### Step 1: Add a Medication

1. Sign in to the app
2. Tap "Add Medication"
3. Fill in details:
   ```
   Name: Demo Aspirin
   Dosage: 100mg
   ```

### Step 2: Select DEMO Frequency

In the **Frequency** dropdown, you'll see:

```
🧪 DEMO: 1 min from now
🧪 DEMO: 1, 2, 3 min from now
─────────────────────────
Once daily
Twice daily
Three times daily
...
```

**Choose one:**
- **DEMO: 1 min** - Single notification in 1 minute
- **DEMO: 1, 2, 3 min** - Three notifications (1, 2, and 3 minutes from now)

### Step 3: Enable Reminders

Make sure **"Enable Reminders"** toggle is ON

### Step 4: Review Times

The form will show you the exact times:
```
Reminder Times:
⏰ Dose 1: 14:35  (1 min from now)
⏰ Dose 2: 14:36  (2 min from now)
⏰ Dose 3: 14:37  (3 min from now)

Times are automatically set based on frequency
```

### Step 5: Save & Wait

1. Tap "Save Medication"
2. Return to dashboard
3. **Wait 1 minute**
4. Notification will fire!
5. Badge will increment

## Complete Demo Flow

### Quick Demo (1 minute)

```
1. Add medication
2. Select "🧪 DEMO: 1 min from now"
3. Save
4. Wait 1 minute
5. See notification!
6. Badge shows "1"
7. Tap badge → See pending dose
8. Mark as taken
9. Badge clears
```

**Time:** ~2 minutes total

### Full Demo (3 minutes)

```
1. Add medication
2. Select "🧪 DEMO: 1, 2, 3 min from now"
3. Save
4. Wait 1 minute → First notification
   - Badge: 1
5. Wait 1 more minute → Second notification
   - Badge: 2
6. Wait 1 more minute → Third notification
   - Badge: 3
7. Open Pending Doses page
   - See all 3 doses listed
   - Some marked as "overdue"
8. Mark first as "Missed"
   - Badge: 2
9. Mark second as "Taken"
   - Badge: 1
10. Mark third as "Taken"
    - Badge: 0 (cleared!)
```

**Time:** ~5 minutes total

## What You'll Demonstrate

### 1. Multi-Dose Notifications ✅
- Multiple notifications scheduled automatically
- Each dose gets its own notification
- Badge increments for each

### 2. Pending Dose Tracking ✅
- Badge shows pending count
- Dashboard card shows count
- Pending Doses page lists all

### 3. Overdue Detection ✅
- Doses show "Overdue by X minutes"
- Color coding (orange → red)
- Visual urgency indicators

### 4. Honest Tracking ✅
- Can mark as "Taken" (even if late)
- Can mark as "Missed" (honest tracking)
- Badge clears when action taken

### 5. Adherence Logging ✅
- All actions logged to Firestore
- Scheduled time vs actual time tracked
- Status (taken/missed) recorded

## Demo Script

### For Stakeholders (5 minutes)

**"Let me show you how the medication reminder system works..."**

1. **Setup** (30 seconds)
   - "I'll add a test medication with reminders"
   - "For demo purposes, I'll use our test mode that schedules notifications 1, 2, and 3 minutes from now"

2. **Show Scheduling** (30 seconds)
   - "See here - it shows exactly when each notification will fire"
   - "In production, these would be real times like 8 AM, 2 PM, etc."

3. **Wait for First Notification** (1 minute)
   - "Now we wait... and there it is!"
   - "Notice the badge on the dashboard - it shows 1 pending dose"

4. **Show Pending Doses** (1 minute)
   - "Tapping the badge shows all pending doses"
   - "As more notifications fire, the count increases"
   - "See - now we have 2 pending doses"

5. **Demonstrate Actions** (2 minutes)
   - "For the first dose, I forgot to take it - I'll mark it as 'Missed'"
   - "For the second, I took it late - I'll mark it as 'Taken'"
   - "Notice the badge decrements as I handle each dose"
   - "All of this is logged for adherence tracking"

6. **Show Results** (30 seconds)
   - "Badge is now clear - all caught up!"
   - "All actions are logged to the database for analytics"
   - "Healthcare providers can see actual adherence patterns"

### For Developers (2 minutes)

**"Here's how the demo mode works..."**

1. **Show Code** (30 seconds)
   ```dart
   // DEMO MODE: Use current time + offsets
   if (_frequency.contains('DEMO')) {
     final now = DateTime.now();
     final demoTime1 = now.add(const Duration(minutes: 1));
     return [TimeOfDay(hour: demoTime1.hour, minute: demoTime1.minute)];
   }
   ```

2. **Explain Flow** (1 minute)
   - "Notifications scheduled with flutter_local_notifications"
   - "Pending doses tracked locally in SharedPreferences"
   - "Adherence logs saved to Firestore"
   - "Badge count updates in real-time"

3. **Show Data** (30 seconds)
   - "Here's the Firestore collection with adherence logs"
   - "Each log has scheduled time, taken time, and status"
   - "Perfect for analytics and reporting"

## Tips for Best Demo

### Do's ✅
- Use "DEMO: 1, 2, 3 min" for full feature showcase
- Explain it's demo mode (production uses real times)
- Show both "Taken" and "Missed" actions
- Highlight the badge count changes
- Show the Pending Doses page

### Don'ts ❌
- Don't wait for real notification times (8 AM, etc.)
- Don't skip explaining it's demo mode
- Don't only mark as "Taken" (show "Missed" too)
- Don't forget to show the badge incrementing
- Don't rush - let notifications actually fire

## Troubleshooting

### Notification Didn't Fire?

1. **Check permissions**
   - Settings → Apps → MedMind → Notifications → Enabled

2. **Check time**
   - Make sure you waited the full minute
   - Check the scheduled time in the form

3. **Check reminders enabled**
   - Toggle should be ON when saving

### Badge Not Showing?

1. **Wait for notification to fire**
   - Badge only shows AFTER notification fires
   - Not when medication is added

2. **Check pending doses**
   - Go to Pending Doses page
   - See if doses are there

3. **Restart app**
   - Sometimes helps refresh state

## Production vs Demo

| Feature | Demo Mode | Production |
|---------|-----------|------------|
| Times | 1, 2, 3 min from now | 8 AM, 2 PM, 8 PM |
| Purpose | Testing & demos | Real medication reminders |
| Frequency | DEMO options | Once/Twice/Three times daily |
| Behavior | Identical | Identical |
| Data logging | Same | Same |

## Summary

✅ **DEMO mode** - Quick testing with 1-3 minute delays  
✅ **Easy to use** - Just select from dropdown  
✅ **Full features** - All functionality works the same  
✅ **Perfect for demos** - Show complete flow in 5 minutes  
✅ **Production ready** - Switch to normal frequencies anytime  

Now you can demonstrate the entire notification system in just a few minutes! 🎉

---

**Quick Start:**
1. Add medication
2. Select "🧪 DEMO: 1, 2, 3 min from now"
3. Save
4. Wait 3 minutes
5. See all features in action!

**That's it!** 🚀
