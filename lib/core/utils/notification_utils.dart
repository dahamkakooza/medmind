import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationUtils {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
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
  }

  static Future<void> scheduleMedicationReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
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
          sound: RawResourceAndroidNotificationSound('notification'),
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
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
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
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
  }

  static Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            DarwinFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notificationsPlugin.pendingNotificationRequests();
  }
}