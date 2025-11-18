import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../medication/domain/entities/medication_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetTodayMedications implements UseCase<List<MedicationEntity>, NoParams> {
  final DashboardRepository repository;

  GetTodayMedications(this.repository);

  @override
  Future<Either<Failure, List<MedicationEntity>>> call(NoParams params) async {
    return await repository.getTodayMedications();
  }
}