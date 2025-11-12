import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/adherence_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetAdherenceStats implements UseCase<AdherenceEntity, NoParams> {
  final DashboardRepository repository;

  GetAdherenceStats(this.repository);

  @override
  Future<Either<Failure, AdherenceEntity>> call(NoParams params) async {
    return await repository.getAdherenceStats();
  }
}