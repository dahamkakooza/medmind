import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/medication_bloc/medication_bloc.dart';
import '../blocs/medication_bloc/medication_event.dart';
import '../blocs/medication_bloc/medication_state.dart';
import '../blocs/barcode_bloc/barcode_bloc.dart';
import '../blocs/barcode_bloc/barcode_event.dart';
import '../blocs/barcode_bloc/barcode_state.dart';
import '../widgets/medication_form.dart';
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
      builder: (context) => BlocProvider.value(
        value: context.read<BarcodeBloc>(),
        child: const BarcodeScanner(),
      ),
    );
  }

  void _saveMedication() {
    if (_formKey.currentState!.validate()) {
      final medication = MedicationEntity(
        id: '',
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: _frequency,
        instructions: _instructionsController.text.trim(),
        reminderTime: _reminderTime,
        enableReminders: _enableReminders,
        createdAt: DateTime.now(),
      );

      context.read<MedicationBloc>().add(AddMedicationRequested(medication: medication));
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
                  const SnackBar(content: Text('Medication added successfully')),
                );
              }
              if (state is MedicationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
          BlocListener<BarcodeBloc, BarcodeState>(
            listener: (context, state) {
              if (state is BarcodeScanned) {
                _nameController.text = state.medicationName;
                Navigator.pop(context);
              }
            },
          ),
        ],
        child: MedicationForm(
          formKey: _formKey,
          nameController: _nameController,
          dosageController: _dosageController,
          instructionsController: _instructionsController,
          frequency: _frequency,
          reminderTime: _reminderTime,
          enableReminders: _enableReminders,
          onFrequencyChanged: (value) => setState(() => _frequency = value!),
          onReminderTimeChanged: (time) => setState(() => _reminderTime = time),
          onEnableRemindersChanged: (value) => setState(() => _enableReminders = value),
          onSave: _saveMedication,
        ),
      ),
    );
  }
}