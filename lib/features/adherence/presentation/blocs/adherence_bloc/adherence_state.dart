import 'package:equatable/equatable.dart';
import '../../../domain/entities/adherence_log_entity.dart';
import '../../widgets/adherence_chart.dart';

abstract class AdherenceState extends Equatable {
  const AdherenceState();

  @override
  List<Object> get props => [];
}

class AdherenceInitial extends AdherenceState {}

class AdherenceLoading extends AdherenceState {}

class AdherenceLogsLoaded extends AdherenceState {
  final List<AdherenceLogEntity> logs;

  const AdherenceLogsLoaded({required this.logs});

  @override
  List<Object> get props => [logs];
}

class AdherenceSummaryLoaded extends AdherenceState {
  final double overallAdherence;
  final int currentStreak;
  final int bestStreak;
  final int missedDoses;
  final List<ChartData> chartData;

  const AdherenceSummaryLoaded({
    required this.overallAdherence,
    required this.currentStreak,
    required this.bestStreak,
    required this.missedDoses,
    required this.chartData,
  });

  @override
  List<Object> get props => [
    overallAdherence,
    currentStreak,
    bestStreak,
    missedDoses,
    chartData,
  ];
}

class MedicationLoggedSuccess extends AdherenceState {
  final AdherenceLogEntity log;

  const MedicationLoggedSuccess({required this.log});

  @override
  List<Object> get props => [log];
}

class AdherenceDataExported extends AdherenceState {
  final String filePath;
  final String format;

  const AdherenceDataExported({required this.filePath, required this.format});

  @override
  List<Object> get props => [filePath, format];
}

class AdherenceError extends AdherenceState {
  final String message;

  const AdherenceError({required this.message});

  @override
  List<Object> get props => [message];
}
