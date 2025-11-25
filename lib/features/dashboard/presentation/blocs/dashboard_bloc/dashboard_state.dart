import 'package:equatable/equatable.dart';
import 'package:medmind/features/medication/domain/entities/medication_entity.dart';
import 'package:medmind/features/dashboard/domain/entities/adherence_entity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<MedicationEntity> todayMedications;
  final AdherenceEntity adherenceStats;

  const DashboardLoaded({
    required this.todayMedications,
    required this.adherenceStats,
  });

  @override
  List<Object> get props => [todayMedications, adherenceStats];
}

class MedicationLoggedSuccess extends DashboardState {
  final String medicationId;

  const MedicationLoggedSuccess({required this.medicationId});

  @override
  List<Object> get props => [medicationId];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}
