import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class LogMedicationTaken implements UseCase<void, LogMedicationTakenParams> {
  final DashboardRepository repository;

  LogMedicationTaken(this.repository);

  @override
  Future<Either<Failure, void>> call(LogMedicationTakenParams params) async {
    return await repository.logMedicationTaken(params.medicationId);
  }
}

class LogMedicationTakenParams {
  final String medicationId;

  LogMedicationTakenParams({required this.medicationId});
}