import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/adherence_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAdherenceSummary implements UseCase<Map<String, dynamic>, NoParams> {
  final AdherenceRepository repository;

  GetAdherenceSummary(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.getAdherenceSummary();
  }
}