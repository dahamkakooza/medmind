
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationUtils {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  static Future<void> initialize() async {
    try {
      const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(settings);
      _isInitialized = true;
      print('Notification system initialized successfully');
    } catch (e) {
      print('Failed to initialize notifications: $e');
      _isInitialized = false;
    }
  }

  static Future<void> scheduleMedicationReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    if (!_isInitialized) {
      print('Notifications not initialized - skipping schedule');
      return;
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        _scheduleTime(scheduledTime),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminder',
            'Medication Reminders',
            channelDescription: 'Notifications for medication reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
          ),
        ),
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print('Failed to schedule reminder: $e');
    }
  }

  static tz.TZDateTime _scheduleTime(DateTime scheduledTime) {
    final now = DateTime.now();
    final scheduled = DateTime(
      now.year,
      now.month,
      now.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );

    if (scheduled.isBefore(now)) {
      return tz.TZDateTime.from(scheduled.add(const Duration(days: 1)), tz.local);
    }

    return tz.TZDateTime.from(scheduled, tz.local);
  }

  static Future<void> cancelReminder(int id) async {
    if (!_isInitialized) return;

    try {
      await _notificationsPlugin.cancel(id);
    } catch (e) {
      print('Failed to cancel reminder: $e');
    }
  }

  static Future<void> cancelAllReminders() async {
    if (!_isInitialized) return;

    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      print('Failed to cancel all reminders: $e');
    }
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) {
      print('Notifications not initialized - showing fallback');
      // Fallback: Just show a snackbar or print to console
      print('NOTIFICATION: $title - $body');
      return;
    }

    try {
      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'instant_notifications',
            'Instant Notifications',
            channelDescription: 'Instant notification channel',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } catch (e) {
      print('Failed to show notification: $e');
      // Fallback
      print('NOTIFICATION FALLBACK: $title - $body');
    }
  }

  static Future<void> requestPermissions() async {
    if (!_isInitialized) return;

    try {
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      print('Failed to request permissions: $e');
    }
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_isInitialized) return [];

    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      print('Failed to get pending notifications: $e');
      return [];
    }
  }
}