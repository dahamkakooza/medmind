import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_today_medications.dart';
import '../../../domain/usecases/get_adherence_stats.dart';
import '../../../domain/usecases/log_medication_taken.dart';
import '../../../../../core/usecases/usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetTodayMedications getTodayMedications;
  final GetAdherenceStats getAdherenceStats;
  final LogMedicationTaken logMedicationTaken;

  DashboardBloc({
    required this.getTodayMedications,
    required this.getAdherenceStats,
    required this.logMedicationTaken,
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
    final result = await logMedicationTaken(
      LogMedicationTakenParams(medicationId: event.medicationId),
    );
    result.fold(
      (failure) {
        print('❌ [Dashboard] Failed to log medication: ${failure.toString()}');
        emit(const DashboardError(message: 'Failed to log medication'));
      },
      (_) {
        print('✅ [Dashboard] Medication logged successfully');
        emit(MedicationLoggedSuccess(medicationId: event.medicationId));
        add(RefreshDashboardData());
      },
    );
  }

  Future<void> _loadData(Emitter<DashboardState> emit) async {
    print('📊 [Dashboard] Fetching today\'s medications...');
    final medicationsResult = await getTodayMedications(NoParams());
    
    print('📊 [Dashboard] Fetching adherence stats...');
    final statsResult = await getAdherenceStats(NoParams());

    medicationsResult.fold(
      (failure) => print('❌ [Dashboard] Medications fetch failed: ${failure.toString()}'),
      (meds) => print('✅ [Dashboard] Medications fetched: ${meds.length} items'),
    );

    statsResult.fold(
      (failure) => print('❌ [Dashboard] Stats fetch failed: ${failure.toString()}'),
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
