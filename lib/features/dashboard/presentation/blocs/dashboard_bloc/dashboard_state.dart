import 'package:equatable/equatable.dart';
import '../../../../medication/domain/entities/medication_entity.dart';
import '../../../domain/entities/adherence_entity.dart';
import '../../../domain/entities/adherence_entity.dart'; // Fixed path

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
  final String medicationName;

  const MedicationLoggedSuccess({
    required this.medicationId,
    required this.medicationName,
  });

  @override
  List<Object> get props => [medicationId, medicationName];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});

  @override
  List<Object> get props => [message];
}
