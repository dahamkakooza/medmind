import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medication_entity.dart';
import 'package:flutter/material.dart';

class MedicationModel extends MedicationEntity {
  const MedicationModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.dosage,
    required super.form,
    required super.frequency,
    required super.times,
    required super.days,
    required super.startDate,
    super.isActive,
    super.barcodeData,
    super.refillReminder,
    super.instructions,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Convert entity to model
  factory MedicationModel.fromEntity(MedicationEntity entity) {
    return MedicationModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      dosage: entity.dosage,
      form: entity.form,
      frequency: entity.frequency,
      times: entity.times,
      days: entity.days,
      startDate: entity.startDate,
      isActive: entity.isActive,
      barcodeData: entity.barcodeData,
      refillReminder: entity.refillReminder,
      instructions: entity.instructions,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert from Firestore document
  factory MedicationModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicationModel(
      id: doc.id,
      userId: data['userId'] as String,
      name: data['name'] as String,
      dosage: data['dosage'] as String,
      form: MedicationForm.values.firstWhere(
        (e) => e.name == data['form'],
        orElse: () => MedicationForm.tablet,
      ),
      frequency: MedicationFrequency.values.firstWhere(
        (e) => e.name == data['frequency'],
        orElse: () => MedicationFrequency.daily,
      ),
      times: _timesFromFirestore(data['times']),
      days: List<int>.from(data['days'] ?? []),
      startDate: (data['startDate'] as Timestamp).toDate(),
      isActive: data['isActive'] as bool? ?? true,
      barcodeData: data['barcodeData'] as String?,
      refillReminder: data['refillReminder'] as bool? ?? false,
      instructions: data['instructions'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore document map
  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'form': form.name,
      'frequency': frequency.name,
      'times': _timesToFirestore(times),
      'days': days,
      'startDate': Timestamp.fromDate(startDate),
      'isActive': isActive,
      if (barcodeData != null) 'barcodeData': barcodeData,
      'refillReminder': refillReminder,
      if (instructions != null) 'instructions': instructions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to JSON (for local storage/caching)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'form': form.name,
      'frequency': frequency.name,
      'times': times.map((time) => '${time.hour}:${time.minute}').toList(),
      'days': days,
      'startDate': startDate.toIso8601String(),
      'isActive': isActive,
      if (barcodeData != null) 'barcodeData': barcodeData,
      'refillReminder': refillReminder,
      if (instructions != null) 'instructions': instructions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert from JSON (for local storage/caching)
  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      form: MedicationForm.values.firstWhere(
        (e) => e.name == json['form'],
        orElse: () => MedicationForm.tablet,
      ),
      frequency: MedicationFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => MedicationFrequency.daily,
      ),
      times: (json['times'] as List<dynamic>)
          .map((timeStr) => _timeFromString(timeStr as String))
          .toList(),
      days: List<int>.from(json['days'] ?? []),
      startDate: DateTime.parse(json['startDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      barcodeData: json['barcodeData'] as String?,
      refillReminder: json['refillReminder'] as bool? ?? false,
      instructions: json['instructions'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Helper method to convert TimeOfDay list to Firestore format
  static List<Map<String, int>> _timesToFirestore(List<TimeOfDay> times) {
    return times
        .map((time) => {'hour': time.hour, 'minute': time.minute})
        .toList();
  }

  /// Helper method to convert Firestore format to TimeOfDay list
  static List<TimeOfDay> _timesFromFirestore(dynamic timesData) {
    if (timesData == null) return [];

    final timesList = timesData as List<dynamic>;
    return timesList.map((timeMap) {
      final map = timeMap as Map<String, dynamic>;
      return TimeOfDay(hour: map['hour'] as int, minute: map['minute'] as int);
    }).toList();
  }

  /// Helper method to convert string to TimeOfDay
  static TimeOfDay _timeFromString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
