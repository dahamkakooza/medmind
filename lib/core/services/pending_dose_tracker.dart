import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Tracks pending medication doses that need to be taken
/// Increments when notification fires, decrements when marked as taken
class PendingDoseTracker {
  static const String _pendingDosesKey = 'pending_doses';
  static const String _lastCheckKey = 'last_dose_check';

  /// Add a pending dose when notification fires
  static Future<void> addPendingDose({
    required String medicationId,
    required String medicationName,
    required DateTime scheduledTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingDoses = await getPendingDoses();

    // Create unique ID for this dose (medication + time)
    final doseId = '${medicationId}_${scheduledTime.millisecondsSinceEpoch}';

    // Add to pending doses if not already there
    if (!pendingDoses.containsKey(doseId)) {
      pendingDoses[doseId] = {
        'medicationId': medicationId,
        'medicationName': medicationName,
        'scheduledTime': scheduledTime.toIso8601String(),
        'addedAt': DateTime.now().toIso8601String(),
      };

      await prefs.setString(_pendingDosesKey, json.encode(pendingDoses));
    }
  }

  /// Remove a pending dose when marked as taken
  static Future<void> removePendingDose({
    required String medicationId,
    DateTime? scheduledTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingDoses = await getPendingDoses();

    if (scheduledTime != null) {
      // Remove specific dose
      final doseId = '${medicationId}_${scheduledTime.millisecondsSinceEpoch}';
      pendingDoses.remove(doseId);
    } else {
      // Remove all doses for this medication (when marking as taken without specific time)
      pendingDoses.removeWhere(
        (key, value) => value['medicationId'] == medicationId,
      );
    }

    await prefs.setString(_pendingDosesKey, json.encode(pendingDoses));
  }

  /// Get all pending doses
  static Future<Map<String, dynamic>> getPendingDoses() async {
    final prefs = await SharedPreferences.getInstance();
    final dosesJson = prefs.getString(_pendingDosesKey);

    if (dosesJson == null || dosesJson.isEmpty) {
      return {};
    }

    try {
      return Map<String, dynamic>.from(json.decode(dosesJson));
    } catch (e) {
      return {};
    }
  }

  /// Get count of pending doses
  static Future<int> getPendingDoseCount() async {
    final pendingDoses = await getPendingDoses();
    return pendingDoses.length;
  }

  /// Clear all pending doses
  static Future<void> clearAllPendingDoses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingDosesKey);
  }

  /// Check for doses that should be marked as pending based on current time
  /// This runs when app opens to catch any missed notifications
  static Future<void> checkForMissedDoses(List<dynamic> medications) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getString(_lastCheckKey);

    DateTime lastCheckTime;
    if (lastCheck != null) {
      lastCheckTime = DateTime.parse(lastCheck);
    } else {
      // First time - check last 24 hours
      lastCheckTime = now.subtract(const Duration(hours: 24));
    }

    // Check each medication's scheduled times
    for (final medication in medications) {
      if (!medication.enableReminders) continue;

      // Check each scheduled time for this medication
      for (final time in medication.times) {
        // Create DateTime for today's scheduled time
        final scheduledToday = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        // If scheduled time is between last check and now, and it's in the past
        if (scheduledToday.isAfter(lastCheckTime) &&
            scheduledToday.isBefore(now)) {
          // Check if this dose was already logged as taken
          final wasTaken = await _wasDoseTaken(medication.id, scheduledToday);

          if (!wasTaken) {
            // Add as pending dose
            await addPendingDose(
              medicationId: medication.id,
              medicationName: medication.name,
              scheduledTime: scheduledToday,
            );
          }
        }
      }
    }

    // Update last check time
    await prefs.setString(_lastCheckKey, now.toIso8601String());
  }

  /// Check if a dose was taken (simplified - in real app, check adherence logs)
  static Future<bool> _wasDoseTaken(
    String medicationId,
    DateTime scheduledTime,
  ) async {
    // TODO: Check adherence logs in database
    // For now, return false (assume not taken)
    return false;
  }

  /// Get pending doses for a specific medication
  static Future<List<Map<String, dynamic>>> getPendingDosesForMedication(
    String medicationId,
  ) async {
    final allDoses = await getPendingDoses();
    return allDoses.entries
        .where((entry) => entry.value['medicationId'] == medicationId)
        .map((entry) => Map<String, dynamic>.from(entry.value))
        .toList();
  }
}
