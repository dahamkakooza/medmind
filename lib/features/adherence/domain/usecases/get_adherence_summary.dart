import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/adherence_repository.dart';

class GetAdherenceSummary
    implements UseCase<Map<String, dynamic>, GetAdherenceSummaryParams> {
  final AdherenceRepository repository;

  GetAdherenceSummary(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    GetAdherenceSummaryParams params,
  ) async {
    final result = await repository.getAdherenceSummary(
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );

    // Convert AdherenceEntity to Map for backward compatibility
    return result.fold(
      (failure) => Left(failure),
      (adherenceEntity) => Right({
        'overallAdherence':
            adherenceEntity.adherenceRate * 100, // Convert to percentage
        'currentStreak': adherenceEntity.currentStreak,
        'bestStreak': adherenceEntity
            .currentStreak, // Using currentStreak as best for now
        'missedDoses': adherenceEntity.missedCount,
      }),
    );
  }
}

class GetAdherenceSummaryParams {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  GetAdherenceSummaryParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });
}
