import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../../../domain/usecases/get_today_medications.dart';
import '../../../domain/usecases/get_adherence_stats.dart';
import '../../../../adherence/domain/usecases/log_medication_taken.dart' as adherence_log;
import 'package:injectable/injectable.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

@injectable
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetTodayMedications getTodayMedications;
  final GetAdherenceStats getAdherenceStats;
  final adherence_log.LogMedicationTaken logMedicationTaken;

  DashboardBloc({
    required this.getTodayMedications,
    required this.getAdherenceStats,
    required this.logMedicationTaken,
  }) : super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<LogMedicationTaken>(_onLogMedicationTaken);
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
      LogMedicationTaken event,
      Emitter<DashboardState> emit,
      ) async {
    final result = await logMedicationTaken(
      adherence_log.LogMedicationTakenParams(
        medicationId: event.medicationId,
        takenAt: DateTime.now(),
      ),
    );
    result.fold(
          (failure) => emit(DashboardError(message: _mapFailureToMessage(failure))),
          (_) {
        emit(MedicationLoggedSuccess(medicationId: event.medicationId));
        add(RefreshDashboardData());
      },
    );
  }

  Future<void> _loadData(Emitter<DashboardState> emit) async {
    final medicationsResult = await getTodayMedications(NoParams());
    final statsResult = await getAdherenceStats(NoParams());

    medicationsResult.fold(
          (failure) => emit(DashboardError(message: _mapFailureToMessage(failure))),
          (medications) {
        statsResult.fold(
              (failure) => emit(DashboardError(message: _mapFailureToMessage(failure))),
              (stats) => emit(DashboardLoaded(
            todayMedications: medications,
            adherenceStats: stats,
          )),
        );
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred';
      case NetworkFailure:
        return 'No internet connection';
      case CacheFailure:
        return 'Cache error occurred';
      default:
        return 'An unexpected error occurred';
    }
  }
}