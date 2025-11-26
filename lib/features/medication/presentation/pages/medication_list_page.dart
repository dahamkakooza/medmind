import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/medication_bloc/medication_bloc.dart';
import '../blocs/medication_bloc/medication_event.dart';
import '../blocs/medication_bloc/medication_state.dart';
import '../widgets/medication_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';

class MedicationListPage extends StatefulWidget {
  const MedicationListPage({super.key});

  @override
  State<MedicationListPage> createState() => _MedicationListPageState();
}

class _MedicationListPageState extends State<MedicationListPage> {
  @override
  void initState() {
    super.initState();
    context.read<MedicationBloc>().add(GetMedicationsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/add-medication'),
          ),
        ],
      ),
      body: BlocBuilder<MedicationBloc, MedicationState>(
        builder: (context, state) {
          if (state is MedicationLoading) {
            return const LoadingWidget();
          }

          if (state is MedicationError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () => context.read<MedicationBloc>().add(GetMedicationsRequested()),
            );
          }

          if (state is MedicationLoaded) {
            if (state.medications.isEmpty) {
              return EmptyStateWidget(
                icon: Icons.medication,
                title: 'No medications yet',
                child: Text('Add your first medication to get started'),
                actionText: 'Add Medication',
                onAction: () => Navigator.pushNamed(context, '/add-medication'), description: '',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<MedicationBloc>().add(GetMedicationsRequested());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.medications.length,
                itemBuilder: (context, index) {
                  final medication = state.medications[index];
                  return MedicationCard(
                    medication: medication,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/medication-detail',
                      arguments: medication,
                    ),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add-medication'),
        child: const Icon(Icons.add),
      ),
    );
  }
}