import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medication_entity.dart';

abstract class MedicationRepository {
  Future<Either<Failure, List<MedicationEntity>>> getMedications();
  Future<Either<Failure, MedicationEntity>> addMedication(MedicationEntity medication);
  Future<Either<Failure, MedicationEntity>> updateMedication(MedicationEntity medication);
  Future<Either<Failure, void>> deleteMedication(String id);
  Future<Either<Failure, String>> scanBarcode();
}