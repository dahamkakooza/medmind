import 'package:equatable/equatable.dart';

enum AdherenceStatus { taken, missed, snoozed }

class AdherenceLogEntity extends Equatable {
  final String id;
  final String userId;
  final String medicationId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final AdherenceStatus status;
  final int? snoozeDuration; // in minutes
  final DateTime createdAt;
  final Map<String, dynamic>? deviceInfo;

  const AdherenceLogEntity({
    required this.id,
    required this.userId,
    required this.medicationId,
    required this.scheduledTime,
    this.takenTime,
    this.status = AdherenceStatus.missed,
    this.snoozeDuration,
    required this.createdAt,
    this.deviceInfo,
  });

  AdherenceLogEntity copyWith({
    String? id,
    String? userId,
    String? medicationId,
    DateTime? scheduledTime,
    DateTime? takenTime,
    AdherenceStatus? status,
    int? snoozeDuration,
    DateTime? createdAt,
    Map<String, dynamic>? deviceInfo,
  }) {
    return AdherenceLogEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicationId: medicationId ?? this.medicationId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      createdAt: createdAt ?? this.createdAt,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    medicationId,
    scheduledTime,
    takenTime,
    status,
    snoozeDuration,
    createdAt,
    deviceInfo,
  ];
}
