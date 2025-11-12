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
              value: frequency,
              decoration: const InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Once daily', child: Text('Once daily')),
                DropdownMenuItem(value: 'Twice daily', child: Text('Twice daily')),
                DropdownMenuItem(value: 'Three times daily', child: Text('Three times daily')),
                DropdownMenuItem(value: 'Four times daily', child: Text('Four times daily')),
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
                      ListTile(
                        title: const Text('Reminder Time'),
                        subtitle: Text(reminderTime.format(context)),
                        trailing: const Icon(Icons.access_time),
                        onTap: () => _selectTime(context),
                        contentPadding: EdgeInsets.zero,
                      ),
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

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
    );
    if (picked != null) {
      onReminderTimeChanged(picked);
    }
  }
}