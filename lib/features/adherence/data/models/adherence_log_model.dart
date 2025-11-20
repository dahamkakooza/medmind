import '../../domain/entities/adherence_log_entity.dart';

class AdherenceLogModel extends AdherenceLogEntity {
  const AdherenceLogModel({
    required String id,
    required String medicationId,
    required String medicationName,
    required DateTime takenAt,
    String? notes,
    required bool wasOnTime,
  }) : super(
          id: id,
          medicationId: medicationId,
          medicationName: medicationName,
          takenAt: takenAt,
          notes: notes,
          wasOnTime: wasOnTime,
        );

  factory AdherenceLogModel.fromJson(Map<String, dynamic> json) {
    return AdherenceLogModel(
      id: json['id'] ?? '',
      medicationId: json['medicationId'] ?? '',
      medicationName: json['medicationName'] ?? '',
      takenAt: DateTime.parse(json['takenAt']),
      notes: json['notes'],
      wasOnTime: json['wasOnTime'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'takenAt': takenAt.toIso8601String(),
      'notes': notes,
      'wasOnTime': wasOnTime,
    };
  }

  factory AdherenceLogModel.fromEntity(AdherenceLogEntity entity) {
    return AdherenceLogModel(
      id: entity.id,
      medicationId: entity.medicationId,
      medicationName: entity.medicationName,
      takenAt: entity.takenAt,
      notes: entity.notes,
      wasOnTime: entity.wasOnTime,
    );
  }
}