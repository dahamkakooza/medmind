import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationSetting(
            title: 'Medication Reminders',
            subtitle: 'Get notified when it\'s time to take your medication',
            value: true,
            onChanged: (value) {},
          ),
          _buildNotificationSetting(
            title: 'Refill Reminders',
            subtitle: 'Get notified when your medication is running low',
            value: true,
            onChanged: (value) {},
          ),
          _buildNotificationSetting(
            title: 'Adherence Reports',
            subtitle: 'Weekly summary of your medication adherence',
            value: false,
            onChanged: (value) {},
          ),
          _buildNotificationSetting(
            title: 'Health Tips',
            subtitle: 'Receive helpful health and wellness tips',
            value: true,
            onChanged: (value) {},
          ),
          _buildNotificationSetting(
            title: 'App Updates',
            subtitle: 'Notifications about new features and updates',
            value: false,
            onChanged: (value) {},
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Notification Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildNotificationSetting(
            title: 'Sound',
            subtitle: 'Play sound for notifications',
            value: true,
            onChanged: (value) {},
          ),
          _buildNotificationSetting(
            title: 'Vibration',
            subtitle: 'Vibrate for notifications',
            value: true,
            onChanged: (value) {},
          ),
          _buildNotificationSetting(
            title: 'Badge',
            subtitle: 'Show badge on app icon',
            value: false,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSetting({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
        ),
      ),
    );
  }
}