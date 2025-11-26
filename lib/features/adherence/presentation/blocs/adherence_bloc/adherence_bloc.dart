import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/usecases/get_adherence_logs.dart';
import '../../../domain/usecases/get_adherence_summary.dart';
import '../../../domain/usecases/log_medication_taken.dart';
import '../../../domain/usecases/export_adherence_data.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../widgets/adherence_chart.dart';
import 'adherence_event.dart';
import 'adherence_state.dart';

class AdherenceBloc extends Bloc<AdherenceEvent, AdherenceState> {
  final GetAdherenceLogs getAdherenceLogs;
  final GetAdherenceSummary getAdherenceSummary;
  final LogMedicationTaken logMedicationTaken;
  final ExportAdherenceData exportAdherenceData;

  AdherenceBloc({
    required this.getAdherenceLogs,
    required this.getAdherenceSummary,
    required this.logMedicationTaken,
    required this.exportAdherenceData,
  }) : super(AdherenceInitial()) {
    on<GetAdherenceLogsRequested>(_onGetAdherenceLogsRequested);
    on<GetAdherenceSummaryRequested>(_onGetAdherenceSummaryRequested);
    on<LogMedicationTakenRequested>(_onLogMedicationTakenRequested);
    on<ExportAdherenceDataRequested>(_onExportAdherenceDataRequested);
  }

  Future<void> _onGetAdherenceLogsRequested(
    GetAdherenceLogsRequested event,
    Emitter<AdherenceState> emit,
  ) async {
    emit(AdherenceLoading());
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final result = await getAdherenceLogs(
      GetAdherenceLogsParams(
        userId: userId,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );
    result.fold(
      (failure) =>
          emit(const AdherenceError(message: 'Failed to load adherence logs')),
      (logs) => emit(AdherenceLogsLoaded(logs: logs)),
    );
  }

  Future<void> _onGetAdherenceSummaryRequested(
    GetAdherenceSummaryRequested event,
    Emitter<AdherenceState> emit,
  ) async {
    emit(AdherenceLoading());
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30)); // Last 30 days
    final result = await getAdherenceSummary(
      GetAdherenceSummaryParams(
        userId: userId,
        startDate: startDate,
        endDate: now,
      ),
    );
    result.fold(
      (failure) => emit(
        const AdherenceError(message: 'Failed to load adherence summary'),
      ),
      (summary) => emit(
        AdherenceSummaryLoaded(
          overallAdherence: summary['overallAdherence'] ?? 0.0,
          currentStreak: summary['currentStreak'] ?? 0,
          bestStreak: summary['bestStreak'] ?? 0,
          missedDoses: summary['missedDoses'] ?? 0,
          chartData: _generateChartData(),
        ),
      ),
    );
  }

  Future<void> _onLogMedicationTakenRequested(
    LogMedicationTakenRequested event,
    Emitter<AdherenceState> emit,
  ) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final result = await logMedicationTaken(
      LogMedicationTakenParams(
        userId: userId,
        medicationId: event.medicationId,
        takenAt: event.takenAt,
        notes: event.notes,
      ),
    );
    result.fold(
      (failure) =>
          emit(const AdherenceError(message: 'Failed to log medication')),
      (log) => emit(MedicationLoggedSuccess(log: log)),
    );
  }

  Future<void> _onExportAdherenceDataRequested(
    ExportAdherenceDataRequested event,
    Emitter<AdherenceState> emit,
  ) async {
    final result = await exportAdherenceData(
      ExportAdherenceDataParams(format: event.format),
    );
    result.fold(
      (failure) => emit(const AdherenceError(message: 'Failed to export data')),
      (filePath) =>
          emit(AdherenceDataExported(filePath: filePath, format: event.format)),
    );
  }

  List<ChartData> _generateChartData() {
    // Generate sample chart data
    return List.generate(7, (index) {
      return ChartData(
        label: 'Day ${index + 1}',
        percentage: 70.0 + (index * 5),
        date: DateTime.now().subtract(Duration(days: 6 - index)),
      );
    });
  }
}
