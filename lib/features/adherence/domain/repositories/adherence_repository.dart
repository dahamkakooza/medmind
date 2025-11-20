import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/adherence_log_entity.dart';

abstract class AdherenceRepository {
  Future<Either<Failure, List<AdherenceLogEntity>>> getAdherenceLogs({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<Either<Failure, AdherenceLogEntity>> logMedicationTaken({
    required String medicationId,
    required DateTime takenAt,
    String? notes,
  });
  Future<Either<Failure, Map<String, dynamic>>> getAdherenceSummary();
  Future<Either<Failure, String>> exportAdherenceData(String format);
}