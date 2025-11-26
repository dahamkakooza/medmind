import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/adherence_log_entity.dart';

class AdherenceLogModel extends AdherenceLogEntity {
  const AdherenceLogModel({
    required super.id,
    required super.userId,
    required super.medicationId,
    required super.scheduledTime,
    super.takenTime,
    super.status,
    super.snoozeDuration,
    required super.createdAt,
    super.deviceInfo,
  });

  /// Convert entity to model
  factory AdherenceLogModel.fromEntity(AdherenceLogEntity entity) {
    return AdherenceLogModel(
      id: entity.id,
      userId: entity.userId,
      medicationId: entity.medicationId,
      scheduledTime: entity.scheduledTime,
      takenTime: entity.takenTime,
      status: entity.status,
      snoozeDuration: entity.snoozeDuration,
      createdAt: entity.createdAt,
      deviceInfo: entity.deviceInfo,
    );
  }

  /// Convert from Firestore document
  factory AdherenceLogModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdherenceLogModel(
      id: doc.id,
      userId: data['userId'] as String,
      medicationId: data['medicationId'] as String,
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      takenTime: data['takenTime'] != null
          ? (data['takenTime'] as Timestamp).toDate()
          : null,
      status: AdherenceStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AdherenceStatus.missed,
      ),
      snoozeDuration: data['snoozeDuration'] as int?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deviceInfo: data['deviceInfo'] as Map<String, dynamic>?,
    );
  }

  /// Convert to Firestore document map
  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'medicationId': medicationId,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      if (takenTime != null) 'takenTime': Timestamp.fromDate(takenTime!),
      'status': status.name,
      if (snoozeDuration != null) 'snoozeDuration': snoozeDuration,
      'createdAt': Timestamp.fromDate(createdAt),
      if (deviceInfo != null) 'deviceInfo': deviceInfo,
    };
  }

  /// Convert to JSON (for local storage/caching)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'medicationId': medicationId,
      'scheduledTime': scheduledTime.toIso8601String(),
      if (takenTime != null) 'takenTime': takenTime!.toIso8601String(),
      'status': status.name,
      if (snoozeDuration != null) 'snoozeDuration': snoozeDuration,
      'createdAt': createdAt.toIso8601String(),
      if (deviceInfo != null) 'deviceInfo': deviceInfo,
    };
  }

  /// Convert from JSON (for local storage/caching)
  factory AdherenceLogModel.fromJson(Map<String, dynamic> json) {
    return AdherenceLogModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      medicationId: json['medicationId'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      takenTime: json['takenTime'] != null
          ? DateTime.parse(json['takenTime'] as String)
          : null,
      status: AdherenceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AdherenceStatus.missed,
      ),
      snoozeDuration: json['snoozeDuration'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      deviceInfo: json['deviceInfo'] as Map<String, dynamic>?,
    );
  }
}

/// Extension to convert AdherenceStatus enum to/from string
extension AdherenceStatusExtension on AdherenceStatus {
  String get name {
    switch (this) {
      case AdherenceStatus.taken:
        return 'taken';
      case AdherenceStatus.missed:
        return 'missed';
      case AdherenceStatus.snoozed:
        return 'snoozed';
    }
  }

  static AdherenceStatus fromString(String value) {
    switch (value) {
      case 'taken':
        return AdherenceStatus.taken;
      case 'missed':
        return AdherenceStatus.missed;
      case 'snoozed':
        return AdherenceStatus.snoozed;
      default:
        return AdherenceStatus.missed;
    }
  }
}
