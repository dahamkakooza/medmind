import '../../domain/entities/adherence_entity.dart';

class AdherenceModel extends AdherenceEntity {
  const AdherenceModel({
    required double weeklyPercentage,
    required double monthlyPercentage,
    required int currentStreak,
    required int totalTaken,
    required int totalMissed,
  }) : super(
          weeklyPercentage: weeklyPercentage,
          monthlyPercentage: monthlyPercentage,
          currentStreak: currentStreak,
          totalTaken: totalTaken,
          totalMissed: totalMissed,
        );

  factory AdherenceModel.fromJson(Map<String, dynamic> json) {
    return AdherenceModel(
      weeklyPercentage: (json['weeklyPercentage'] ?? 0.0).toDouble(),
      monthlyPercentage: (json['monthlyPercentage'] ?? 0.0).toDouble(),
      currentStreak: json['currentStreak'] ?? 0,
      totalTaken: json['totalTaken'] ?? 0,
      totalMissed: json['totalMissed'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weeklyPercentage': weeklyPercentage,
      'monthlyPercentage': monthlyPercentage,
      'currentStreak': currentStreak,
      'totalTaken': totalTaken,
      'totalMissed': totalMissed,
    };
  }
}