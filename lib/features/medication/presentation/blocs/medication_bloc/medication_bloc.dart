import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_medications.dart';
import '../../../domain/usecases/add_medication.dart';
import '../../../domain/usecases/update_medication.dart';
import '../../../domain/usecases/delete_medication.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/notification_utils.dart';
import '../../../../../core/services/pending_dose_tracker.dart';
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
      (failure) =>
          emit(const MedicationError(message: 'Failed to load medications')),
      (medications) => emit(MedicationLoaded(medications: medications)),
    );
  }

  Future<void> _onAddMedicationRequested(
    AddMedicationRequested event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());
    final result = await addMedication(
      AddMedicationParams(medication: event.medication),
    );
    await result.fold(
      (failure) async =>
          emit(const MedicationError(message: 'Failed to add medication')),
      (medication) async {
        // Schedule notification if reminders are enabled
        if (medication.enableReminders) {
          await _scheduleNotification(medication);
        }
        emit(MedicationAdded(medication: medication));
      },
    );
  }

  Future<void> _scheduleNotification(dynamic medication) async {
    try {
      // Schedule a notification for each time in the medication schedule
      for (int i = 0; i < medication.times.length; i++) {
        final time = medication.times[i];
        final scheduledTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          time.hour,
          time.minute,
        );

        // Use unique ID for each time slot (medication ID + time index)
        await NotificationUtils.scheduleMedicationReminder(
          id: medication.id.hashCode + i,
          title: 'Medication Reminder',
          body: 'Time to take ${medication.name} - ${medication.dosage}',
          scheduledTime: scheduledTime,
          payload:
              '${medication.id}|${medication.name}', // Include both ID and name
        );

        // For DEMO mode or near-future notifications, add to pending doses immediately
        final now = DateTime.now();
        if (scheduledTime.isAfter(now) &&
            scheduledTime.difference(now).inMinutes <= 5) {
          // Add to pending doses for notifications within 5 minutes
          await PendingDoseTracker.addPendingDose(
            medicationId: medication.id,
            medicationName: medication.name,
            scheduledTime: scheduledTime,
          );
          print(
            '✅ Added pending dose for ${medication.name} at ${time.hour}:${time.minute}',
          );
        }
      }
    } catch (e) {
      // Silently fail - don't block medication creation if notification fails
      print('❌ Failed to schedule notification: $e');
    }
  }

  Future<void> _onUpdateMedicationRequested(
    UpdateMedicationRequested event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());
    final result = await updateMedication(
      UpdateMedicationParams(medication: event.medication),
    );
    await result.fold(
      (failure) async =>
          emit(const MedicationError(message: 'Failed to update medication')),
      (medication) async {
        // Cancel all old notifications (we don't know how many times were previously set)
        // Cancel up to 10 possible time slots to be safe
        for (int i = 0; i < 10; i++) {
          await NotificationUtils.cancelReminder(medication.id.hashCode + i);
        }

        // Schedule new notifications if reminders are enabled
        if (medication.enableReminders) {
          await _scheduleNotification(medication);
        }
        emit(MedicationUpdated(medication: medication));
      },
    );
  }

  Future<void> _onDeleteMedicationRequested(
    DeleteMedicationRequested event,
    Emitter<MedicationState> emit,
  ) async {
    emit(MedicationLoading());
    final result = await deleteMedication(
      DeleteMedicationParams(medicationId: event.medicationId),
    );
    await result.fold(
      (failure) async =>
          emit(const MedicationError(message: 'Failed to delete medication')),
      (_) async {
        // Cancel all notifications for this medication
        // Cancel up to 10 possible time slots to be safe
        for (int i = 0; i < 10; i++) {
          await NotificationUtils.cancelReminder(
            event.medicationId.hashCode + i,
          );
        }
        emit(MedicationDeleted(medicationId: event.medicationId));
      },
    );
  }
}
