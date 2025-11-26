// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:dartz/dartz.dart';
// import 'package:injectable/injectable.dart';
// import '../../../../../core/usecases/usecase.dart';
// import '../../../../../core/errors/failures.dart';
// import '../../../../dashboard/domain/usecases/log_medication_taken.dart';
// import '../../../domain/usecases/export_adherence_data.dart';
// import '../../../domain/usecases/get_adherence_logs.dart';
// import '../../../domain/usecases/get_adherence_summary.dart';
// import '../../../domain/usecases/get_adherence_logs.dart';
// import '../../../domain/usecases/get_adherence_summary.dart';
// import '../../../domain/usecases/log_medication_taken.dart' hide LogMedicationTaken, LogMedicationTakenParams;
// import '../../../domain/usecases/export_adherence_data.dart';
// import '../../domain/entities/adherence_log_entity.dart';
// import '../../presentation/widgets/adherence_chart.dart';
// import '../../widgets/adherence_chart.dart';
// import 'adherence_event.dart';
// import 'adherence_state.dart';
//
// @injectable
// class AdherenceBloc extends Bloc<AdherenceEvent, AdherenceState> {
//   final GetAdherenceLogs getAdherenceLogs;
//   final GetAdherenceSummary getAdherenceSummary;
//   final LogMedicationTaken logMedicationTaken;
//   final ExportAdherenceData exportAdherenceData;
//
//   AdherenceBloc({
//     required this.getAdherenceLogs,
//     required this.getAdherenceSummary,
//     required this.logMedicationTaken,
//     required this.exportAdherenceData,
//   }) : super(AdherenceInitial()) {
//     on<GetAdherenceLogsRequested>(_onGetAdherenceLogsRequested);
//     on<GetAdherenceSummaryRequested>(_onGetAdherenceSummaryRequested);
//     on<LogMedicationTakenRequested>(_onLogMedicationTakenRequested);
//     on<ExportAdherenceDataRequested>(_onExportAdherenceDataRequested);
//   }
//
//   Future<void> _onGetAdherenceLogsRequested(
//       GetAdherenceLogsRequested event,
//       Emitter<AdherenceState> emit,
//       ) async {
//     emit(AdherenceLoading());
//     try {
//       final result = await getAdherenceLogs(GetAdherenceLogsParams(
//         startDate: event.startDate,
//         endDate: event.endDate,
//       ));
//       result.fold(
//             (failure) => emit(AdherenceError(message: _mapFailureToMessage(failure))),
//             (logs) => emit(AdherenceLogsLoaded(logs: logs)),
//       );
//     } catch (e) {
//       emit(AdherenceError(message: 'Failed to load adherence logs: $e'));
//     }
//   }
//
//   Future<void> _onGetAdherenceSummaryRequested(
//       GetAdherenceSummaryRequested event,
//       Emitter<AdherenceState> emit,
//       ) async {
//     emit(AdherenceLoading());
//     try {
//       final result = await getAdherenceSummary(NoParams());
//       result.fold(
//             (failure) => emit(AdherenceError(message: _mapFailureToMessage(failure))),
//             (summary) => emit(AdherenceSummaryLoaded(
//           overallAdherence: summary['overallAdherence'] ?? 0.0,
//           currentStreak: summary['currentStreak'] ?? 0,
//           bestStreak: summary['bestStreak'] ?? 0,
//           missedDoses: summary['missedDoses'] ?? 0,
//           chartData: _generateChartData(),
//         )),
//       );
//     } catch (e) {
//       emit(AdherenceError(message: 'Failed to load adherence summary: $e'));
//     }
//   }
//
//   Future<void> _onLogMedicationTakenRequested(
//       LogMedicationTakenRequested event,
//       Emitter<AdherenceState> emit,
//       ) async {
//     try {
//       final result = await logMedicationTaken(LogMedicationTakenParams(
//         medicationId: event.medicationId,
//       ));
//       result.fold(
//             (failure) => emit(AdherenceError(message: _mapFailureToMessage(failure))),
//             (_) => emit(MedicationLoggedSuccess()),
//       );
//     } catch (e) {
//       emit(AdherenceError(message: 'Failed to log medication: $e'));
//     }
//   }
//
//   Future<void> _onExportAdherenceDataRequested(
//       ExportAdherenceDataRequested event,
//       Emitter<AdherenceState> emit,
//       ) async {
//     try {
//       final result = await exportAdherenceData(ExportAdherenceDataParams(format: event.format));
//       result.fold(
//             (failure) => emit(AdherenceError(message: _mapFailureToMessage(failure))),
//             (filePath) => emit(AdherenceDataExported(
//           filePath: filePath,
//           format: event.format,
//         )),
//       );
//     } catch (e) {
//       emit(AdherenceError(message: 'Failed to export data: $e'));
//     }
//   }
//
//   List<ChartData> _generateChartData() {
//     // Generate sample chart data for demonstration
//     return List.generate(7, (index) {
//       return ChartData(
//         label: 'Day ${index + 1}',
//         percentage: 70.0 + (index * 5),
//         date: DateTime.now().subtract(Duration(days: 6 - index)),
//       );
//     });
//   }
//
//   String _mapFailureToMessage(Failure failure) {
//     switch (failure.runtimeType) {
//       case ServerFailure:
//         return 'Server error occurred. Please try again.';
//       case NetworkFailure:
//         return 'No internet connection. Please check your network.';
//       case CacheFailure:
//         return 'Local storage error. Please restart the app.';
//       case InvalidCredentialsFailure:
//         return 'Invalid credentials. Please check your login details.';
//       case PermissionFailure:
//         return 'Permission denied. Please check app permissions.';
//       case TimeoutFailure:
//         return 'Request timeout. Please try again.';
//       default:
//         return 'An unexpected error occurred. Please try again.';
//     }
//   }
//
//   @override
//   Future<void> close() {
//     // Clean up resources if needed
//     return super.close();
//   }
// }
//
// class TimeoutFailure {
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/errors/failures.dart';
import '../../../domain/usecases/export_adherence_data.dart';
import '../../../domain/usecases/get_adherence_logs.dart';
import '../../../domain/usecases/get_adherence_summary.dart';
import '../../../domain/usecases/log_medication_taken.dart';
import '../../domain/entities/adherence_log_entity.dart';
import '../../widgets/adherence_chart.dart';
import 'adherence_event.dart';
import 'adherence_state.dart';

@injectable
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
    try {
      final result = await getAdherenceLogs(GetAdherenceLogsParams(
        startDate: event.startDate,
        endDate: event.endDate,
      ));
      result.fold(
            (failure) => emit(AdherenceError(message: _mapFailureToMessage(failure))),
            (logs) => emit(AdherenceLogsLoaded(logs: logs)),
      );
    } catch (e) {
      emit(AdherenceError(message: 'Failed to load adherence logs: $e'));
    }
  }

  Future<void> _onGetAdherenceSummaryRequested(
      GetAdherenceSummaryRequested event,
      Emitter<AdherenceState> emit,
      ) async {
    emit(AdherenceLoading());
    try {
      final result = await getAdherenceSummary(NoParams());
      result.fold(
            (failure) => emit(AdherenceError(message: _mapFailureToMessage(failure))),
            (summary) => emit(AdherenceSummaryLoaded(
          overallAdherence: summary['overallAdherence'] ?? 0.0,
          currentStreak: summary['currentStreak'] ?? 0,
          bestStreak: summary['bestStreak'] ?? 0,
          missedDoses: summary['missedDoses'] ?? 0,
          chartData: _generateChartData(),
        )),
      );
    } catch (e) {
      emit(AdherenceError(message: 'Failed to load adherence summary: $e'));
    }
  }

  Future<void> _onLogMedicationTakenRequested(
      LogMedicationTakenRequested event,
      Emitter<AdherenceState> emit,
      ) async {
    try {
      final result = await logMedicationTaken(LogMedicationTakenParams(
        medicationId: event.medicationId,
        takenAt: event.takenAt,
        notes: event.notes,
      ));
      result.fold(
            (failure) => emit(AdherenceError(message: _mapFailureToMessage(failure))),
            (_) => emit(MedicationLoggedSuccess()),
      );
    } catch (e) {
      emit(AdherenceError(message: 'Failed to log medication: $e'));
    }
  }

  Future<void> _onExportAdherenceDataRequested(
      ExportAdherenceDataRequested event,
      Emitter<AdherenceState> emit,
      ) async {
    try {
      final result = await exportAdherenceData(ExportAdherenceDataParams(format: event.format));
      result.fold(
            (failure) => emit(AdherenceError(message: _mapFailureToMessage(failure))),
            (filePath) => emit(AdherenceDataExported(
          filePath: filePath,
          format: event.format,
        )),
      );
    } catch (e) {
      emit(AdherenceError(message: 'Failed to export data: $e'));
    }
  }

  List<ChartData> _generateChartData() {
    return List.generate(7, (index) {
      return ChartData(
        label: 'Day ${index + 1}',
        percentage: 70.0 + (index * 5),
        date: DateTime.now().subtract(Duration(days: 6 - index)),
      );
    });
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred. Please try again.';
      case NetworkFailure:
        return 'No internet connection. Please check your network.';
      case CacheFailure:
        return 'Local storage error. Please restart the app.';
      case InvalidCredentialsFailure:
        return 'Invalid credentials. Please check your login details.';
      case PermissionFailure:
        return 'Permission denied. Please check app permissions.';
      case TimeoutFailure:
        return 'Request timeout. Please try again.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}