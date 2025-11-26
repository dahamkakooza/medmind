// import 'package:dartz/dartz.dart';
// import '../../../../core/errors/failures.dart';
// import '../../../../core/usecases/usecase.dart';
// import '../entities/adherence_log_entity.dart';
// import '../repositories/adherence_repository.dart';
// import 'package:injectable/injectable.dart';
//
// @injectable
// class LogMedicationTaken implements UseCase<AdherenceLogEntity, LogMedicationTakenParams> {
//   final AdherenceRepository repository;
//
//   LogMedicationTaken(this.repository);
//
//   String? get medicationId => null;
//
//   @override
//   Future<Either<Failure, AdherenceLogEntity>> call(LogMedicationTakenParams params) async {
//     return await repository.logMedicationTaken(
//       medicationId: params.medicationId,
//       takenAt: params.takenAt,
//       notes: params.notes,
//     );
//   }
// }
//
// class LogMedicationTakenParams {
//   final String medicationId;
//   final DateTime takenAt;
//   final String? notes;
//
//   LogMedicationTakenParams({
//     required this.medicationId,
//     required this.takenAt,
//     this.notes,
//   });
// }
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/adherence_log_entity.dart';
import '../repositories/adherence_repository.dart';

@injectable
class LogMedicationTaken implements UseCase<AdherenceLogEntity, LogMedicationTakenParams> {
  final AdherenceRepository repository;

  LogMedicationTaken(this.repository);

  @override
  Future<Either<Failure, AdherenceLogEntity>> call(LogMedicationTakenParams params) async {
    return await repository.logMedicationTaken(
      medicationId: params.medicationId,
      takenAt: params.takenAt,
      notes: params.notes,
    );
  }
}

class LogMedicationTakenParams {
  final String medicationId;
  final DateTime takenAt;
  final String? notes;

  LogMedicationTakenParams({
    required this.medicationId,
    required this.takenAt,
    this.notes,
  });
}