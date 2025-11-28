import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/medication_bloc/medication_bloc.dart';
import '../blocs/medication_bloc/medication_event.dart';
import '../blocs/medication_bloc/medication_state.dart';
// TODO: Implement BarcodeBloc
// import '../blocs/barcode_bloc/barcode_bloc.dart';
// import '../blocs/barcode_bloc/barcode_event.dart';
// import '../blocs/barcode_bloc/barcode_state.dart';
import '../widgets/medication_form.dart' as widgets;
import '../widgets/barcode_scanner.dart';
import '../../domain/entities/medication_entity.dart';

class AddMedicationPage extends StatefulWidget {
  final MedicationEntity? medication; // For editing existing medication

  const AddMedicationPage({super.key, this.medication});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _frequency = 'Once daily';
  List<TimeOfDay> _reminderTimes = [const TimeOfDay(hour: 8, minute: 0)];
  bool _enableReminders = true;

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing medication data
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _dosageController.text = widget.medication!.dosage;
      _instructionsController.text = widget.medication!.instructions ?? '';
      _enableReminders = widget.medication!.times.isNotEmpty;
      if (widget.medication!.times.isNotEmpty) {
        _reminderTimes = widget.medication!.times;
      }
      // Set frequency based on times count
      _frequency = _getFrequencyFromTimes(widget.medication!.times.length);
    }
  }

  String _getFrequencyFromTimes(int timesCount) {
    switch (timesCount) {
      case 1:
        return 'Once daily';
      case 2:
        return 'Twice daily';
      case 3:
        return 'Three times daily';
      case 4:
        return 'Four times daily';
      default:
        return 'Once daily';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _scanBarcode() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const BarcodeScanner(),
    );
  }

  List<TimeOfDay> _getTimesForFrequency() {
    if (!_enableReminders) return [];

    // DEMO MODE: Use current time + offsets for easy testing
    if (_frequency.contains('DEMO')) {
      final now = DateTime.now();
      final demoTime1 = now.add(const Duration(minutes: 1));
      final demoTime2 = now.add(const Duration(minutes: 2));
      final demoTime3 = now.add(const Duration(minutes: 3));

      switch (_frequency) {
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

    // NORMAL MODE: Standard times
    switch (_frequency) {
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

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();

      if (widget.medication != null) {
        // Update existing medication
        final updatedMedication = MedicationEntity(
          id: widget.medication!.id,
          userId: widget.medication!.userId,
          name: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          form: widget.medication!.form,
          frequency: widget.medication!.frequency,
          times: _getTimesForFrequency(),
          days: widget.medication!.days,
          startDate: widget.medication!.startDate,
          isActive: widget.medication!.isActive,
          barcodeData: widget.medication!.barcodeData,
          refillReminder: widget.medication!.refillReminder,
          instructions: _instructionsController.text.trim(),
          createdAt: widget.medication!.createdAt,
          updatedAt: now,
        );

        context.read<MedicationBloc>().add(
          UpdateMedicationRequested(medication: updatedMedication),
        );
      } else {
        // Add new medication
        final medication = MedicationEntity(
          id: '',
          userId: '', // Will be set by repository
          name: _nameController.text.trim(),
          dosage: _dosageController.text.trim(),
          form: MedicationForm.tablet, // Default form
          frequency: MedicationFrequency.daily, // Default frequency
          times: _getTimesForFrequency(),
          days: [], // Empty for daily
          startDate: now,
          isActive: true,
          instructions: _instructionsController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );

        context.read<MedicationBloc>().add(
          AddMedicationRequested(medication: medication),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.medication != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Medication' : 'Add Medication'),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: _scanBarcode,
            ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MedicationBloc, MedicationState>(
            listener: (context, state) {
              if (state is MedicationAdded) {
                // Navigate to dashboard and clear navigation stack
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Medication added successfully!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              if (state is MedicationUpdated) {
                // Go back to previous screen (detail or list)
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Medication updated successfully!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              if (state is MedicationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ ${state.message}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          // TODO: Add BarcodeBloc listener when BarcodeBloc is implemented
        ],
        child: widgets.MedicationForm(
          formKey: _formKey,
          nameController: _nameController,
          dosageController: _dosageController,
          instructionsController: _instructionsController,
          frequency: _frequency,
          reminderTime: _reminderTimes.first,
          enableReminders: _enableReminders,
          onFrequencyChanged: (value) => setState(() => _frequency = value!),
          onReminderTimeChanged: (time) =>
              setState(() => _reminderTimes = [time]),
          onEnableRemindersChanged: (value) =>
              setState(() => _enableReminders = value),
          onSave: _saveMedication,
        ),
      ),
    );
  }
}
