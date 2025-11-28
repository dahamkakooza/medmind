import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/adherence_log_entity.dart';
import '../repositories/adherence_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAdherenceLogs implements UseCase<List<AdherenceLogEntity>, GetAdherenceLogsParams> {
  final AdherenceRepository repository;

  GetAdherenceLogs(this.repository);

  @override
  Future<Either<Failure, List<AdherenceLogEntity>>> call(
    GetAdherenceLogsParams params,
  ) async {
    return await repository.getAdherenceLogs(
      userId: params.userId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetAdherenceLogsParams {
  final String userId;
  final DateTime startDate;
  final DateTime endDate;

  GetAdherenceLogsParams({
    required this.userId,
    required this.startDate,
    required this.endDate,
  });
}
