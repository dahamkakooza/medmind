import 'package:equatable/equatable.dart';
import '../../../domain/entities/adherence_log_entity.dart';

import '../../widgets/adherence_chart.dart';

abstract class AdherenceState extends Equatable {
  const AdherenceState();

  @override
  List<Object> get props => [];
}

class AdherenceInitial extends AdherenceState {
  const AdherenceInitial();

  @override
  List<Object> get props => [];
}

class AdherenceLoading extends AdherenceState {
  const AdherenceLoading();

  @override
  List<Object> get props => [];
}

class AdherenceLogsLoaded extends AdherenceState {
  final List<AdherenceLogEntity> logs;
  final DateTime? startDate;
  final DateTime? endDate;

  const AdherenceLogsLoaded({
    required this.logs,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object> get props => [logs];

  int get totalLogs => logs.length;
  int get takenLogs => logs.where((log) => log.wasOnTime).length;
  int get missedLogs => logs.length - takenLogs;
  double get adherenceRate => logs.isEmpty ? 0.0 : (takenLogs / logs.length) * 100;
}

class AdherenceSummaryLoaded extends AdherenceState {
  final double overallAdherence;
  final int currentStreak;
  final int bestStreak;
  final int missedDoses;
  final List<ChartData> chartData;
  final DateTime generatedAt;

  AdherenceSummaryLoaded({
    required this.overallAdherence,
    required this.currentStreak,
    required this.bestStreak,
    required this.missedDoses,
    required this.chartData,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  @override
  List<Object> get props => [
    overallAdherence,
    currentStreak,
    bestStreak,
    missedDoses,
    chartData,
    generatedAt,
  ];

  String get adherencePercentage => '${overallAdherence.toStringAsFixed(1)}%';
  String get streakText => '$currentStreak days';
  String get bestStreakText => '$bestStreak days';
  bool get isPerfectAdherence => overallAdherence >= 95.0;
  bool get isGoodAdherence => overallAdherence >= 80.0;
  bool get isPoorAdherence => overallAdherence < 70.0;
}

class MedicationLoggedSuccess extends AdherenceState {
  final String medicationId;
  final DateTime loggedAt;

  MedicationLoggedSuccess({
    this.medicationId = '',
    DateTime? loggedAt,
  }) : loggedAt = loggedAt ?? DateTime.now();

  @override
  List<Object> get props => [medicationId, loggedAt];

  String get successMessage => 'Medication logged successfully at ${_formatTime(loggedAt)}';

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class AdherenceDataExported extends AdherenceState {
  final String filePath;
  final String format;
  final DateTime exportedAt;
  final int recordCount;

  AdherenceDataExported({
    required this.filePath,
    required this.format,
    this.recordCount = 0,
    DateTime? exportedAt,
  }) : exportedAt = exportedAt ?? DateTime.now();

  @override
  List<Object> get props => [filePath, format, exportedAt, recordCount];

  String get exportMessage {
    return 'Exported $recordCount records to $format format';
  }

  String get fileName => filePath.split('/').last;
}

class AdherenceError extends AdherenceState {
  final String message;
  final String? errorCode;
  final DateTime occurredAt;
  final bool isRetryable;

  AdherenceError({
    required this.message,
    this.errorCode,
    this.isRetryable = true,
    DateTime? occurredAt,
  }) : occurredAt = occurredAt ?? DateTime.now();

  @override
  List<Object> get props => [message, occurredAt, isRetryable];

  AdherenceError copyWith({
    String? message,
    String? errorCode,
    bool? isRetryable,
  }) {
    return AdherenceError(
      message: message ?? this.message,
      errorCode: errorCode ?? this.errorCode,
      isRetryable: isRetryable ?? this.isRetryable,
      occurredAt: occurredAt,
    );
  }
}

// Additional utility states
class AdherenceRefreshing extends AdherenceState {
  final AdherenceState currentState;

  const AdherenceRefreshing(this.currentState);

  @override
  List<Object> get props => [currentState];
}

class AdherencePartialUpdate extends AdherenceState {
  final AdherenceState currentState;
  final Map<String, dynamic> updates;

  const AdherencePartialUpdate(this.currentState, this.updates);

  @override
  List<Object> get props => [currentState, updates];
}