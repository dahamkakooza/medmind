import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/medication_entity.dart';

abstract class MedicationRepository {
  /// Get all medications for the current user
  Future<Either<Failure, List<MedicationEntity>>> getMedications();

  /// Get a single medication by ID
  Future<Either<Failure, MedicationEntity>> getMedicationById(String id);

  /// Add a new medication
  Future<Either<Failure, MedicationEntity>> addMedication(
    MedicationEntity medication,
  );

  /// Update an existing medication
  Future<Either<Failure, MedicationEntity>> updateMedication(
    MedicationEntity medication,
  );

  /// Delete a medication (soft delete by setting isActive = false)
  Future<Either<Failure, void>> deleteMedication(String id);

  /// Scan barcode and lookup medication information
  Future<Either<Failure, String>> scanBarcode();

  /// Watch medications in real-time for the current user
  Stream<Either<Failure, List<MedicationEntity>>> watchMedications();
}
