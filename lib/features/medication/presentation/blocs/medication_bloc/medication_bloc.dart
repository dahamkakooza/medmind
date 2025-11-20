import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_medications.dart';
import '../../../domain/usecases/add_medication.dart';
import '../../../domain/usecases/update_medication.dart';
import '../../../domain/usecases/delete_medication.dart';
import '../../../../../core/usecases/usecase.dart';
import 'medication_event.dart';
import 'medication_state.dart';

class MedicationBloc extends Bloc<MedicationEvent, MedicationState> {
  final GetMedications getMedications;
  final AddMedication addMedication;
  final UpdateMedication updateMedication;
  final DeleteMedication deleteMedication;

  MedicationBloc({
    required this.getMedications,
    required this.addMedication,
    required this.updateMedication,
    required this.deleteMedication,
  }) : super(MedicationInitial()) {
    on<GetMedicationsRequested>(_onGetMedicationsRequested);
    on<AddMedicationRequested>(_onAddMedicationRequested);
    on<UpdateMedicationRequested>(_onUpdateMedicationRequested);
    on<DeleteMedicationRequested>(_onDeleteMedicationRequested);
  }

  Future<void> _onGetMedicationsRequested(
    GetMedicationsRequested event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());
    final result = await getMedications(NoParams());
    result.fold(
      (failure) => emit(const MedicationError(message: 'Failed to load medications')),
      (medications) => emit(MedicationLoaded(medications: medications)),
    );
  }

  Future<void> _onAddMedicationRequested(
    AddMedicationRequested event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());
    final result = await addMedication(AddMedicationParams(medication: event.medication));
    result.fold(
      (failure) => emit(const MedicationError(message: 'Failed to add medication')),
      (medication) => emit(MedicationAdded(medication: medication)),
    );
  }

  Future<void> _onUpdateMedicationRequested(
    UpdateMedicationRequested event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());
    final result = await updateMedication(UpdateMedicationParams(medication: event.medication));
    result.fold(
      (failure) => emit(const MedicationError(message: 'Failed to update medication')),
      (medication) => emit(MedicationUpdated(medication: medication)),
    );
  }

  Future<void> _onDeleteMedicationRequested(
    DeleteMedicationRequested event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());
    final result = await deleteMedication(DeleteMedicationParams(medicationId: event.medicationId));
    result.fold(
      (failure) => emit(const MedicationError(message: 'Failed to delete medication')),
      (_) => emit(MedicationDeleted(medicationId: event.medicationId)),
    );
  }
}