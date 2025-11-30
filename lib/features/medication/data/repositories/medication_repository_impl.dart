import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_data_source.dart';
import '../datasources/medication_local_data_source.dart';
import '../models/medication_model.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final MedicationLocalDataSource localDataSource;

  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  get localDataSource => null;

  @override
  Future<Either<Failure, List<MedicationEntity>>> getMedications() async {
    try {
      final medications = await remoteDataSource.getMedications();
      await localDataSource.cacheMedications(medications);
      return Right(medications);
    } catch (e) {
      try {
        final cachedMedications = await localDataSource.getCachedMedications();
        return Right(cachedMedications);
      } catch (e) {
        return Left(ServerFailure());
      }
    }
  }

  @override
  Future<Either<Failure, MedicationEntity>> addMedication(MedicationEntity medication) async {
    try {
      final medicationModel = MedicationModel.fromEntity(medication);
      final result = await remoteDataSource.addMedication(medicationModel);
      await localDataSource.cacheMedication(result);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, MedicationEntity>> updateMedication(MedicationEntity medication) async {
    try {
      final medicationModel = MedicationModel.fromEntity(medication);
      final result = await remoteDataSource.updateMedication(medicationModel);
      await localDataSource.cacheMedication(result);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedication(String id) async {
    try {
      await remoteDataSource.deleteMedication(id);
      await localDataSource.removeCachedMedication(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> scanBarcode() async {
    try {
      final result = await remoteDataSource.scanBarcode();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

class ServerFailure extends Failure {}