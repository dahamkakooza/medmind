import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medication_entity.dart';
import '../repositories/medication_repository.dart';

class AddMedication implements UseCase<MedicationEntity, AddMedicationParams> {
  final MedicationRepository repository;

  AddMedication(this.repository);

  @override
  Future<Either<Failure, MedicationEntity>> call(AddMedicationParams params) async {
    return await repository.addMedication(params.medication);
  }
}

class AddMedicationParams {
  final MedicationEntity medication;

  AddMedicationParams({required this.medication});
}