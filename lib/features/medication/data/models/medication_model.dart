import 'package:flutter/material.dart';
import '../../domain/entities/medication_entity.dart';

class MedicationModel extends MedicationEntity {
  const MedicationModel({
    required String id,
    required String name,
    required String dosage,
    required String frequency,
    required String instructions,
    required TimeOfDay reminderTime,
    required bool enableReminders,
    required DateTime createdAt,
    DateTime? updatedAt,
    bool isTakenToday = false,
  }) : super(
          id: id,
          name: name,
          dosage: dosage,
          frequency: frequency,
          instructions: instructions,
          reminderTime: reminderTime,
          enableReminders: enableReminders,
          createdAt: createdAt,
          updatedAt: updatedAt,
          isTakenToday: isTakenToday,
        );

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      frequency: json['frequency'] ?? '',
      instructions: json['instructions'] ?? '',
      reminderTime: TimeOfDay(
        hour: json['reminderHour'] ?? 8,
        minute: json['reminderMinute'] ?? 0,
      ),
      enableReminders: json['enableReminders'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isTakenToday: json['isTakenToday'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'instructions': instructions,
      'reminderHour': reminderTime.hour,
      'reminderMinute': reminderTime.minute,
      'enableReminders': enableReminders,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isTakenToday': isTakenToday,
    };
  }

  factory MedicationModel.fromEntity(MedicationEntity entity) {
    return MedicationModel(
      id: entity.id,
      name: entity.name,
      dosage: entity.dosage,
      frequency: entity.frequency,
      instructions: entity.instructions,
      reminderTime: entity.reminderTime,
      enableReminders: entity.enableReminders,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isTakenToday: entity.isTakenToday,
    );
  }
}