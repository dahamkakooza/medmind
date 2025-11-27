import 'package:flutter/material.dart';
import '../../../../core/utils/notification_utils.dart';

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({super.key});

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  List<String> _logs = [];
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshPendingNotifications();
  }

  Future<void> _refreshPendingNotifications() async {
    final pending = await NotificationUtils.getPendingNotifications();
    setState(() {
      _pendingCount = pending.length;
    });
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(
        0,
        '${DateTime.now().toString().substring(11, 19)}: $message',
      );
      if (_logs.length > 10) _logs.removeLast();
    });
  }

  Future<void> _testInstantNotification() async {
    _addLog('Sending instant notification...');
    await NotificationUtils.showInstantNotification(
      title: 'Test Notification',
      body: 'This is a test notification from MedMind!',
    );
    _addLog('Instant notification sent');
  }

  Future<void> _testScheduledNotification() async {
    _addLog('Scheduling notification for 10 seconds from now...');
    final scheduledTime = DateTime.now().add(const Duration(seconds: 10));

    await NotificationUtils.scheduleMedicationReminder(
      id: DateTime.now().millisecondsSinceEpoch,
      title: 'Scheduled Test',
      body: 'This notification was scheduled 10 seconds ago',
      scheduledTime: scheduledTime,
      payload: 'test',
    );

    _addLog(
      'Notification scheduled for ${scheduledTime.toString().substring(11, 19)}',
    );
    await _refreshPendingNotifications();
  }

  Future<void> _cancelAllNotifications() async {
    _addLog('Cancelling all notifications...');
    await NotificationUtils.cancelAllReminders();
    _addLog('All notifications cancelled');
    await _refreshPendingNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPendingNotifications,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.notifications_active, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Pending Notifications: $_pendingCount',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _testInstantNotification,
              icon: const Icon(Icons.notification_add),
              label: const Text('Send Instant Notification'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _testScheduledNotification,
              icon: const Icon(Icons.schedule),
              label: const Text('Schedule Notification (10s)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _cancelAllNotifications,
              icon: const Icon(Icons.clear_all),
              label: const Text('Cancel All Notifications'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Activity Log',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Card(
                child: _logs.isEmpty
                    ? const Center(
                        child: Text('No activity yet. Try the buttons above!'),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.circle, size: 8),
                            title: Text(
                              _logs[index],
                              style: const TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 16),
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'How it works',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Instant notifications appear immediately\n'
                      '• Scheduled notifications appear at the set time\n'
                      '• Medication reminders are auto-scheduled when you add medications with reminders enabled',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
