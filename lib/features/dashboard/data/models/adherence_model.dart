import '../../domain/entities/adherence_entity.dart';

class AdherenceModel extends AdherenceEntity {
  const AdherenceModel({
    required super.adherenceRate,
    required super.totalMedications,
    required super.takenCount,
    required super.missedCount,
    super.weeklyStats,
    super.monthlyStats,
    super.streakDays,
  });

  /// Convert entity to model
  factory AdherenceModel.fromEntity(AdherenceEntity entity) {
    return AdherenceModel(
      adherenceRate: entity.adherenceRate,
      totalMedications: entity.totalMedications,
      takenCount: entity.takenCount,
      missedCount: entity.missedCount,
      weeklyStats: entity.weeklyStats,
      monthlyStats: entity.monthlyStats,
      streakDays: entity.streakDays,
    );
  }

  /// Convert to JSON (for caching)
  Map<String, dynamic> toJson() {
    return {
      'adherenceRate': adherenceRate,
      'totalMedications': totalMedications,
      'takenCount': takenCount,
      'missedCount': missedCount,
      'weeklyStats': weeklyStats
          .map(
            (s) => {
              'weekNumber': s.weekNumber,
              'adherenceRate': s.adherenceRate,
              'takenCount': s.takenCount,
              'missedCount': s.missedCount,
            },
          )
          .toList(),
      'monthlyStats': monthlyStats
          .map(
            (s) => {
              'month': s.month,
              'year': s.year,
              'adherenceRate': s.adherenceRate,
              'takenCount': s.takenCount,
              'missedCount': s.missedCount,
            },
          )
          .toList(),
      'streakDays': streakDays,
    };
  }

  /// Convert from JSON (for caching)
  factory AdherenceModel.fromJson(Map<String, dynamic> json) {
    return AdherenceModel(
      adherenceRate: (json['adherenceRate'] as num).toDouble(),
      totalMedications: json['totalMedications'] as int,
      takenCount: json['takenCount'] as int,
      missedCount: json['missedCount'] as int,
      weeklyStats: (json['weeklyStats'] as List<dynamic>)
          .map(
            (s) => WeeklyStats(
              weekNumber: s['weekNumber'] as int,
              adherenceRate: (s['adherenceRate'] as num).toDouble(),
              takenCount: s['takenCount'] as int,
              missedCount: s['missedCount'] as int,
            ),
          )
          .toList(),
      monthlyStats: (json['monthlyStats'] as List<dynamic>)
          .map(
            (s) => MonthlyStats(
              month: s['month'] as int,
              year: s['year'] as int,
              adherenceRate: (s['adherenceRate'] as num).toDouble(),
              takenCount: s['takenCount'] as int,
              missedCount: s['missedCount'] as int,
            ),
          )
          .toList(),
      streakDays: json['streakDays'] as int,
    );
  }

  /// Create from aggregated data (used in data sources)
  factory AdherenceModel.fromAggregatedData({
    required double adherenceRate,
    required int totalMedications,
    required int takenCount,
    required int missedCount,
    List<WeeklyStats> weeklyStats = const [],
    List<MonthlyStats> monthlyStats = const [],
    int streakDays = 0,
  }) {
    return AdherenceModel(
      adherenceRate: adherenceRate,
      totalMedications: totalMedications,
      takenCount: takenCount,
      missedCount: missedCount,
      weeklyStats: weeklyStats,
      monthlyStats: monthlyStats,
      streakDays: streakDays,
    );
  }
}
