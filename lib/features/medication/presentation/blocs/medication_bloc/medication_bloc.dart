import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_medications.dart';
import '../../../domain/usecases/add_medication.dart';
import '../../../domain/usecases/update_medication.dart';
import '../../../domain/usecases/delete_medication.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/notification_utils.dart';
import 'package:injectable/injectable.dart';
import 'medication_event.dart';
import 'medication_state.dart';

@injectable
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
          // Check for missed doses today and add them to pending doses
          await _addMissedDosesToPending(medication);
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
          payload: '${medication.id}|${medication.name}',
          recurring: true, // Daily recurring notification
        );

        print(
          '✅ Scheduled daily reminder for ${medication.name} at ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        );
      }
    } catch (e) {
      // Silently fail - don't block medication creation if notification fails
      print('❌ Failed to schedule notification: $e');
    }
  }

  /// Check for missed doses today and add them to pending doses
  Future<void> _addMissedDosesToPending(dynamic medication) async {
    try {
      final now = DateTime.now();
      print('\n🔍 Checking for missed doses for: ${medication.name}');
      print('   Current time: ${now.toString()}');
      print('   Number of times: ${medication.times.length}');

      for (final time in medication.times) {
        final scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

        print(
          '   Checking time: ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
        );
        print('   Scheduled: ${scheduledTime.toString()}');
        print('   Is before now? ${scheduledTime.isBefore(now)}');

        // If the scheduled time has already passed today, add to pending doses
        if (scheduledTime.isBefore(now)) {
          await PendingDoseTracker.addPendingDose(
            medicationId: medication.id,
            medicationName: medication.name,
            scheduledTime: scheduledTime,
          );

          print(
            '   ✅ Added missed dose to pending: ${medication.name} at ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
          );

          // Verify it was added
          final count = await PendingDoseTracker.getPendingDoseCount();
          print('   📊 Current pending dose count: $count');
        } else {
          print('   ⏭️  Skipped (future time)');
        }
      }

      // Final verification
      final finalCount = await PendingDoseTracker.getPendingDoseCount();
      print('📊 FINAL pending dose count: $finalCount\n');
    } catch (e, stackTrace) {
      print('❌ Failed to add missed doses to pending: $e');
      print('Stack trace: $stackTrace');
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
          // Check for missed doses today and add them to pending doses
          await _addMissedDosesToPending(medication);
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
