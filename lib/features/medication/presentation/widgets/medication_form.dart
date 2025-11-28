import 'package:flutter/material.dart';

class MedicationForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController dosageController;
  final TextEditingController instructionsController;
  final String frequency;
  final TimeOfDay reminderTime;
  final bool enableReminders;
  final ValueChanged<String?> onFrequencyChanged;
  final ValueChanged<TimeOfDay> onReminderTimeChanged;
  final ValueChanged<bool> onEnableRemindersChanged;
  final VoidCallback onSave;

  const MedicationForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.dosageController,
    required this.instructionsController,
    required this.frequency,
    required this.reminderTime,
    required this.enableReminders,
    required this.onFrequencyChanged,
    required this.onReminderTimeChanged,
    required this.onEnableRemindersChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                hintText: 'e.g., Aspirin',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter medication name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: dosageController,
              decoration: const InputDecoration(
                labelText: 'Dosage',
                hintText: 'e.g., 100mg',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter dosage';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: const [
                // DEMO OPTIONS (for testing)
                DropdownMenuItem(
                  value: 'DEMO: 1 min',
                  child: Text('🧪 DEMO: 1 min from now'),
                ),
                DropdownMenuItem(
                  value: 'DEMO: 1, 2, 3 min',
                  child: Text('🧪 DEMO: 1, 2, 3 min from now'),
                ),
                // NORMAL OPTIONS
                DropdownMenuItem(
                  value: 'Once daily',
                  child: Text('Once daily'),
                ),
                DropdownMenuItem(
                  value: 'Twice daily',
                  child: Text('Twice daily'),
                ),
                DropdownMenuItem(
                  value: 'Three times daily',
                  child: Text('Three times daily'),
                ),
                DropdownMenuItem(
                  value: 'Four times daily',
                  child: Text('Four times daily'),
                ),
                DropdownMenuItem(value: 'As needed', child: Text('As needed')),
                DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
              ],
              onChanged: onFrequencyChanged,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: instructionsController,
              decoration: const InputDecoration(
                labelText: 'Instructions (Optional)',
                hintText: 'e.g., Take with food',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reminder Settings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),

                    SwitchListTile(
                      title: const Text('Enable Reminders'),
                      value: enableReminders,
                      onChanged: onEnableRemindersChanged,
                      contentPadding: EdgeInsets.zero,
                    ),

                    if (enableReminders) ...[
                      const SizedBox(height: 8),
                      _buildReminderTimesInfo(context),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: onSave,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save Medication'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderTimesInfo(BuildContext context) {
    final times = _getTimesForFrequency();

    if (times.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No scheduled reminders for "As needed" medications',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reminder Times:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        ...times.asMap().entries.map((entry) {
          final index = entry.key;
          final time = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_getDoseLabel(index, times.length)}: ${time.format(context)}',
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        Text(
          'Times are automatically set based on frequency',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  String _getDoseLabel(int index, int total) {
    if (total == 1) return 'Daily dose';
    if (total == 2) return index == 0 ? 'Morning' : 'Evening';
    if (total == 3) {
      if (index == 0) return 'Morning';
      if (index == 1) return 'Afternoon';
      return 'Evening';
    }
    if (total == 4) {
      if (index == 0) return 'Morning';
      if (index == 1) return 'Noon';
      if (index == 2) return 'Afternoon';
      return 'Evening';
    }
    return 'Dose ${index + 1}';
  }

  List<TimeOfDay> _getTimesForFrequency() {
    // DEMO MODE
    if (frequency.contains('DEMO')) {
      final now = DateTime.now();
      final demoTime1 = now.add(const Duration(minutes: 1));
      final demoTime2 = now.add(const Duration(minutes: 2));
      final demoTime3 = now.add(const Duration(minutes: 3));

      switch (frequency) {
        case 'DEMO: 1 min':
          return [TimeOfDay(hour: demoTime1.hour, minute: demoTime1.minute)];
        case 'DEMO: 1, 2, 3 min':
          return [
            TimeOfDay(hour: demoTime1.hour, minute: demoTime1.minute),
            TimeOfDay(hour: demoTime2.hour, minute: demoTime2.minute),
            TimeOfDay(hour: demoTime3.hour, minute: demoTime3.minute),
          ];
        default:
          return [TimeOfDay(hour: demoTime1.hour, minute: demoTime1.minute)];
      }
    }

    // NORMAL MODE
    switch (frequency) {
      case 'Once daily':
        return [const TimeOfDay(hour: 8, minute: 0)];
      case 'Twice daily':
        return [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
      case 'Three times daily':
        return [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
      case 'Four times daily':
        return [
          const TimeOfDay(hour: 8, minute: 0),
          const TimeOfDay(hour: 12, minute: 0),
          const TimeOfDay(hour: 16, minute: 0),
          const TimeOfDay(hour: 20, minute: 0),
        ];
      case 'As needed':
        return [];
      case 'Weekly':
        return [const TimeOfDay(hour: 8, minute: 0)];
      default:
        return [const TimeOfDay(hour: 8, minute: 0)];
    }
  }
}
