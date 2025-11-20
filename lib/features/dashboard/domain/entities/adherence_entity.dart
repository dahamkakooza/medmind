import 'package:equatable/equatable.dart';

class AdherenceEntity extends Equatable {
  final double weeklyPercentage;
  final double monthlyPercentage;
  final int currentStreak;
  final int totalTaken;
  final int totalMissed;

  const AdherenceEntity({
    required this.weeklyPercentage,
    required this.monthlyPercentage,
    required this.currentStreak,
    required this.totalTaken,
    required this.totalMissed,
  });

  @override
  List<Object> get props => [
    weeklyPercentage,
    monthlyPercentage,
    currentStreak,
    totalTaken,
    totalMissed,
  ];
}