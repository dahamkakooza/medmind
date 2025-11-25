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
    emit(DashboardLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _onLogMedicationTaken(
    LogMedicationTakenEvent event,
    Emitter<DashboardState> emit,
  ) async {
    final result = await logMedicationTaken(
      LogMedicationTakenParams(medicationId: event.medicationId),
    );
    result.fold(
      (failure) =>
          emit(const DashboardError(message: 'Failed to log medication')),
      (_) {
        emit(MedicationLoggedSuccess(medicationId: event.medicationId));
        add(RefreshDashboardData());
      },
    );
  }

  Future<void> _loadData(Emitter<DashboardState> emit) async {
    final medicationsResult = await getTodayMedications(NoParams());
    final statsResult = await getAdherenceStats(NoParams());

    if (medicationsResult.isLeft() || statsResult.isLeft()) {
      emit(const DashboardError(message: 'Failed to load dashboard data'));
      return;
    }

    final medications = medicationsResult.getOrElse(() => []);
    final stats = statsResult.getOrElse(() => throw Exception());

    emit(DashboardLoaded(todayMedications: medications, adherenceStats: stats));
  }
}
