import 'package:equatable/equatable.dart';

class AdherenceLogEntity extends Equatable {
  final String id;
  final String medicationId;
  final String medicationName;
  final DateTime takenAt;
  final String? notes;
  final bool wasOnTime;

  const AdherenceLogEntity({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.takenAt,
    this.notes,
    required this.wasOnTime,
  });

  @override
  List<Object?> get props => [
    id,
    medicationId,
    medicationName,
    takenAt,
    notes,
    wasOnTime,
  ];
}