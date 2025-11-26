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
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _frequency = 'Once daily';
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _enableReminders = true;

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

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final medication = MedicationEntity(
        id: '',
        userId: '', // Will be set by repository
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        form: MedicationForm.tablet, // Default form
        frequency: MedicationFrequency.daily, // Default frequency
        times: _enableReminders ? [_reminderTime] : [],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication'),
        actions: [
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
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Medication added successfully'),
                  ),
                );
              }
              if (state is MedicationError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
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
          reminderTime: _reminderTime,
          enableReminders: _enableReminders,
          onFrequencyChanged: (value) => setState(() => _frequency = value!),
          onReminderTimeChanged: (time) => setState(() => _reminderTime = time),
          onEnableRemindersChanged: (value) =>
              setState(() => _enableReminders = value),
          onSave: _saveMedication,
        ),
      ),
    );
  }
}
