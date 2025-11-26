import 'package:equatable/equatable.dart';

class WeeklyStats extends Equatable {
  final int weekNumber;
  final double adherenceRate;
  final int takenCount;
  final int missedCount;

  const WeeklyStats({
    required this.weekNumber,
    required this.adherenceRate,
    required this.takenCount,
    required this.missedCount,
  });

  @override
  List<Object?> get props => [
    weekNumber,
    adherenceRate,
    takenCount,
    missedCount,
  ];
}

class MonthlyStats extends Equatable {
  final int month;
  final int year;
  final double adherenceRate;
  final int takenCount;
  final int missedCount;

  const MonthlyStats({
    required this.month,
    required this.year,
    required this.adherenceRate,
    required this.takenCount,
    required this.missedCount,
  });

  @override
  List<Object?> get props => [
    month,
    year,
    adherenceRate,
    takenCount,
    missedCount,
  ];
}

class AdherenceEntity extends Equatable {
  final double adherenceRate; // 0.0 to 1.0 (0% to 100%)
  final int totalMedications;
  final int takenCount;
  final int missedCount;
  final List<WeeklyStats> weeklyStats;
  final List<MonthlyStats> monthlyStats;
  final int streakDays;

  const AdherenceEntity({
    required this.adherenceRate,
    required this.totalMedications,
    required this.takenCount,
    required this.missedCount,
    this.weeklyStats = const [],
    this.monthlyStats = const [],
    this.streakDays = 0,
  });

  AdherenceEntity copyWith({
    double? adherenceRate,
    int? totalMedications,
    int? takenCount,
    int? missedCount,
    List<WeeklyStats>? weeklyStats,
    List<MonthlyStats>? monthlyStats,
    int? streakDays,
  }) {
    return AdherenceEntity(
      adherenceRate: adherenceRate ?? this.adherenceRate,
      totalMedications: totalMedications ?? this.totalMedications,
      takenCount: takenCount ?? this.takenCount,
      missedCount: missedCount ?? this.missedCount,
      weeklyStats: weeklyStats ?? this.weeklyStats,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      streakDays: streakDays ?? this.streakDays,
    );
  }

  @override
  List<Object?> get props => [
    adherenceRate,
    totalMedications,
    takenCount,
    missedCount,
    weeklyStats,
    monthlyStats,
    streakDays,
  ];

  double get weeklyPercentage {
    if (weeklyStats.isNotEmpty) {
      return weeklyStats.last.adherenceRate * 100;
    }
    return adherenceRate * 100;
  }

  double get monthlyPercentage {
    if (monthlyStats.isNotEmpty) {
      return monthlyStats.last.adherenceRate * 100;
    }
    return adherenceRate * 100;
  }

  int get currentStreak => streakDays;

  int get totalTaken => takenCount;
}
