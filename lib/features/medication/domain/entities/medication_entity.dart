import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum MedicationForm { tablet, capsule, liquid, injection }

enum MedicationFrequency { daily, weekly, custom }

class MedicationEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final MedicationForm form;
  final MedicationFrequency frequency;
  final List<TimeOfDay> times;
  final List<int> days; // 0-6 for Sunday-Saturday, used for weekly/custom
  final DateTime startDate;
  final bool isActive;
  final String? barcodeData;
  final bool refillReminder;
  final String? instructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MedicationEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    required this.form,
    required this.frequency,
    required this.times,
    required this.days,
    required this.startDate,
    this.isActive = true,
    this.barcodeData,
    this.refillReminder = false,
    this.instructions,
    required this.createdAt,
    required this.updatedAt,
  });

  MedicationEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    MedicationForm? form,
    MedicationFrequency? frequency,
    List<TimeOfDay>? times,
    List<int>? days,
    DateTime? startDate,
    bool? isActive,
    String? barcodeData,
    bool? refillReminder,
    String? instructions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicationEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      days: days ?? this.days,
      startDate: startDate ?? this.startDate,
      isActive: isActive ?? this.isActive,
      barcodeData: barcodeData ?? this.barcodeData,
      refillReminder: refillReminder ?? this.refillReminder,
      instructions: instructions ?? this.instructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    dosage,
    form,
    frequency,
    times,
    days,
    startDate,
    isActive,
    barcodeData,
    refillReminder,
    instructions,
    createdAt,
    updatedAt,
  ];

  /// Convenience getters used by UI layers until adherence tracking integrates
  bool get enableReminders => times.isNotEmpty;

  TimeOfDay get reminderTime =>
      times.isNotEmpty ? times.first : const TimeOfDay(hour: 8, minute: 0);

  // Placeholder flag – real implementation should come from adherence logs
  bool get isTakenToday => false;
}
