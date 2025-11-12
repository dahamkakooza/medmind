import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medication_entity.dart';
import '../repositories/medication_repository.dart';

class GetMedications implements UseCase<List<MedicationEntity>, NoParams> {
  final MedicationRepository repository;

  GetMedications(this.repository);

  @override
  Future<Either<Failure, List<MedicationEntity>>> call(NoParams params) async {
    return await repository.getMedications();
  }
}