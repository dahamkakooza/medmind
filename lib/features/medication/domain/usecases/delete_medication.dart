import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/medication_repository.dart';

class DeleteMedication implements UseCase<void, DeleteMedicationParams> {
  final MedicationRepository repository;

  DeleteMedication(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteMedicationParams params) async {
    return await repository.deleteMedication(params.medicationId);
  }
}

class DeleteMedicationParams {
  final String medicationId;

  DeleteMedicationParams({required this.medicationId});
}