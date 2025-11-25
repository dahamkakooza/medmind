import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/adherence_log_entity.dart';
import 'package:medmind/features/dashboard/domain/entities/adherence_entity.dart';

abstract class AdherenceRepository {
  /// Get adherence logs for a user with optional date range
  Future<Either<Failure, List<AdherenceLogEntity>>> getAdherenceLogs({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Log that a medication was taken
  Future<Either<Failure, AdherenceLogEntity>> logMedicationTaken(
    AdherenceLogEntity log,
  );

  /// Get adherence summary/statistics for a date range
  Future<Either<Failure, AdherenceEntity>> getAdherenceSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Export adherence data (for data export feature)
  Future<Either<Failure, String>> exportAdherenceData(String userId);

  /// Watch adherence logs in real-time
  Stream<Either<Failure, List<AdherenceLogEntity>>> watchAdherenceLogs(
    String userId,
  );
}
