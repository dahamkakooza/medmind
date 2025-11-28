import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../medication/domain/entities/medication_entity.dart';
import '../../domain/entities/adherence_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MedicationEntity>>> getTodayMedications() async {
    try {
      final medications = await remoteDataSource.getTodayMedications();
      return Right(medications);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AdherenceEntity>> getAdherenceStats() async {
    try {
      final stats = await remoteDataSource.getAdherenceStats();
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logMedicationTaken(String medicationId) async {
    try {
      await remoteDataSource.logMedicationTaken(medicationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

class ServerFailure extends Failure {}