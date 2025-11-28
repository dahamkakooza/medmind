import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/adherence_log_entity.dart';
import '../../domain/repositories/adherence_repository.dart';
import '../datasources/adherence_remote_data_source.dart';
import '../models/adherence_log_model.dart';

class AdherenceRepositoryImpl implements AdherenceRepository {
  final AdherenceRemoteDataSource remoteDataSource;

  AdherenceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AdherenceLogEntity>>> getAdherenceLogs({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final logs = await remoteDataSource.getAdherenceLogs(
        startDate: startDate,
        endDate: endDate,
      );
      return Right(logs);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, AdherenceLogEntity>> logMedicationTaken({
    required String medicationId,
    required DateTime takenAt,
    String? notes,
  }) async {
    try {
      final log = await remoteDataSource.logMedicationTaken(
        medicationId: medicationId,
        takenAt: takenAt,
        notes: notes,
      );
      return Right(log);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAdherenceSummary() async {
    try {
      final summary = await remoteDataSource.getAdherenceSummary();
      return Right(summary);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> exportAdherenceData(String format) async {
    try {
      final filePath = await remoteDataSource.exportAdherenceData(format);
      return Right(filePath);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

class ServerFailure extends Failure {}