import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/medication_entity.dart';
import '../repositories/medication_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateMedication implements UseCase<MedicationEntity, UpdateMedicationParams> {
  final MedicationRepository repository;

  UpdateMedication(this.repository);

  @override
  Future<Either<Failure, MedicationEntity>> call(UpdateMedicationParams params) async {
    return await repository.updateMedication(params.medication);
  }
}

class UpdateMedicationParams {
  final MedicationEntity medication;

  UpdateMedicationParams({required this.medication});
}