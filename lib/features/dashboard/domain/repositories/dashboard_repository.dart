import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../medication/domain/entities/medication_entity.dart';
import '../entities/adherence_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, List<MedicationEntity>>> getTodayMedications();
  Future<Either<Failure, AdherenceEntity>> getAdherenceStats();
  Future<Either<Failure, void>> logMedicationTaken(String medicationId);
}