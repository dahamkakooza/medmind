import 'package:equatable/equatable.dart';

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboardData extends DashboardEvent {}

class RefreshDashboardData extends DashboardEvent {}

class LogMedicationTakenEvent extends DashboardEvent {
  final String medicationId;
  final String medicationName;

  const LogMedicationTakenEvent({
    required this.medicationId,
    required this.medicationName,
  });

  @override
  List<Object> get props => [medicationId, medicationName];
}
