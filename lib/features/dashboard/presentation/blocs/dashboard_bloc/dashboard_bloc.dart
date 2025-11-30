import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../../../domain/usecases/get_today_medications.dart';
import '../../../domain/usecases/get_adherence_stats.dart';
import '../../../domain/usecases/log_medication_taken.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../adherence/domain/usecases/log_medication_taken.dart' as adherence_log;
import 'package:injectable/injectable.dart';
import '../../../../adherence/presentation/blocs/adherence_bloc/adherence_bloc.dart';
import '../../../../adherence/presentation/blocs/adherence_bloc/adherence_event.dart'
    as adherence_events;
import '../../../../auth/domain/repositories/auth_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetTodayMedications getTodayMedications;
  final GetAdherenceStats getAdherenceStats;
  final LogMedicationTaken logMedicationTaken;
  final AdherenceBloc adherenceBloc;
  final AuthRepository authRepository;

  DashboardBloc({
    required this.getTodayMedications,
    required this.getAdherenceStats,
    required this.logMedicationTaken,
    required this.adherenceBloc,
    required this.authRepository,
  }) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<LogMedicationTakenEvent>(_onLogMedicationTaken);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    print('📊 [Dashboard] Loading dashboard data...');
    emit(DashboardLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    print('📊 [Dashboard] Refreshing dashboard data...');
    await _loadData(emit);
  }

  Future<void> _onLogMedicationTaken(
    LogMedicationTakenEvent event,
    Emitter<DashboardState> emit,
  ) async {
    print('📊 [Dashboard] Logging medication taken: ${event.medicationId}');

    try {
      // Get current user ID from auth repository
      final userId = authRepository.currentUser.id;
      if (userId.isEmpty) {
        print('❌ [Dashboard] No user logged in');
        emit(const DashboardError(message: 'User not authenticated'));
        return;
      }

      // Create adherence log with current timestamp and "taken" status
      final now = DateTime.now();
      adherenceBloc.add(
        adherence_events.LogMedicationTakenRequested(
          medicationId: event.medicationId,
          takenAt: now,
        ),
      );

      // Remove pending dose to decrement badge count
      await PendingDoseTracker.removePendingDose(
        medicationId: event.medicationId,
      );

      print('✅ [Dashboard] Medication logged successfully');

      // Emit success state with medication name for snackbar
      emit(
        MedicationLoggedSuccess(
          medicationId: event.medicationId,
          medicationName: event.medicationName,
        ),
      );

      // Trigger dashboard data reload to update progress indicator
      add(RefreshDashboardData());
    } catch (e) {
      print('❌ [Dashboard] Failed to log medication: ${e.toString()}');
      emit(const DashboardError(message: 'Failed to log medication'));
    }
  }

  Future<void> _loadData(Emitter<DashboardState> emit) async {
    print('📊 [Dashboard] Fetching today\'s medications...');
    final medicationsResult = await getTodayMedications(NoParams());

    print('📊 [Dashboard] Fetching adherence stats...');
    final statsResult = await getAdherenceStats(NoParams());

    medicationsResult.fold(
      (failure) => print(
        '❌ [Dashboard] Medications fetch failed: ${failure.toString()}',
      ),
      (meds) =>
          print('✅ [Dashboard] Medications fetched: ${meds.length} items'),
    );

    statsResult.fold(
      (failure) =>
          print('❌ [Dashboard] Stats fetch failed: ${failure.toString()}'),
      (stats) => print('✅ [Dashboard] Stats fetched: $stats'),
    );

    if (medicationsResult.isLeft() || statsResult.isLeft()) {
      print('❌ [Dashboard] Failed to load dashboard data');
      emit(const DashboardError(message: 'Failed to load dashboard data'));
      return;
    }

    final medications = medicationsResult.getOrElse(() => []);
    final stats = statsResult.getOrElse(() => throw Exception());

    print('✅ [Dashboard] Dashboard loaded successfully');
    emit(DashboardLoaded(todayMedications: medications, adherenceStats: stats));
  }
}
