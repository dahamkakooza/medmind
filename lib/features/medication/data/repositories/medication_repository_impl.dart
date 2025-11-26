import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/medication_entity.dart';
import '../../domain/repositories/medication_repository.dart';
import '../datasources/medication_remote_data_source.dart';
import '../models/medication_model.dart';

@LazySingleton(as: MedicationRepository) // ADD THIS
class MedicationRepositoryImpl implements MedicationRepository {
  final MedicationRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth;

  MedicationRepositoryImpl({
    required this.remoteDataSource,
    required this.firebaseAuth,
  });

  String get _currentUserId => firebaseAuth.currentUser?.uid ?? '';

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
        return Left(ServerFailure(message: '', code: ''));
      }

      final medications = await remoteDataSource.getMedications(_currentUserId);
      return Right(medications);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(DataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MedicationEntity>> getMedicationById(String id) async {
    try {
      if (_currentUserId.isEmpty) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      final medication = await remoteDataSource.getMedicationById(id);
      return Right(medication);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(DataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MedicationEntity>> addMedication(
    MedicationEntity medication,
  ) async {
    try {
      if (_currentUserId.isEmpty) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      // Validate medication data
      final validationResult = _validateMedication(medication);
      if (validationResult != null) {
        return Left(validationResult);
      }

      final medicationModel = MedicationModel.fromEntity(medication);
      final addedMedication = await remoteDataSource.addMedication(
        medicationModel,
      );
      return Right(addedMedication);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(DataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, MedicationEntity>> updateMedication(
    MedicationEntity medication,
  ) async {
    try {
      if (_currentUserId.isEmpty) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      // Validate medication data
      final validationResult = _validateMedication(medication);
      if (validationResult != null) {
        return Left(validationResult);
      }

      final medicationModel = MedicationModel.fromEntity(medication);
      await remoteDataSource.updateMedication(medicationModel);
      return Right(medication);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(DataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMedication(String id) async {
    try {
      if (_currentUserId.isEmpty) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      if (id.isEmpty) {
        return Left(
          ValidationFailure(message: 'Medication ID cannot be empty'),
        );
      }

      await remoteDataSource.deleteMedication(id);
      return const Right(null);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(DataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> scanBarcode() async {
    try {
      // Note: This method should be called from the presentation layer
      // where the actual barcode scanning UI is implemented using mobile_scanner
      // The presentation layer will handle camera permissions and UI
      // This repository method is primarily for validation and error handling

      // For now, return an error indicating this should be handled at the UI level
      return Left(
        ValidationFailure(
          message:
              'Barcode scanning should be initiated from the presentation layer with proper camera permissions and UI',
        ),
      );
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(
        DataFailure(message: 'Barcode scanning failed: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<Either<Failure, List<MedicationEntity>>> watchMedications() {
    try {
      if (_currentUserId.isEmpty) {
        return Stream.value(
          Left(AuthenticationFailure(message: 'User not authenticated')),
        );
      }

      return remoteDataSource
          .watchMedications(_currentUserId)
          .map<Either<Failure, List<MedicationEntity>>>(
            (medications) => Right(medications.cast<MedicationEntity>()),
          )
          .handleError((error) {
            if (error is AppException) {
              return Left(_mapExceptionToFailure(error));
            }
            return Left(
              DataFailure(message: 'Stream error: ${error.toString()}'),
            );
          });
    } catch (e) {
      return Stream.value(
        Left(DataFailure(message: 'Failed to setup stream: ${e.toString()}')),
      );
    }
  }

  /// Validate medication entity
  ValidationFailure? _validateMedication(MedicationEntity medication) {
    if (medication.name.trim().isEmpty) {
      return ValidationFailure(message: 'Medication name cannot be empty');
    }

    if (medication.dosage.trim().isEmpty) {
      return ValidationFailure(message: 'Medication dosage cannot be empty');
    }

    if (medication.times.isEmpty) {
      return ValidationFailure(
        message: 'At least one reminder time must be set',
      );
    }

    if (medication.frequency == MedicationFrequency.weekly &&
        medication.days.isEmpty) {
      return ValidationFailure(
        message: 'Days must be specified for weekly frequency',
      );
    }

    if (medication.frequency == MedicationFrequency.custom &&
        medication.days.isEmpty) {
      return ValidationFailure(
        message: 'Days must be specified for custom frequency',
      );
    }

    // Validate days are in valid range (0-6 for Sun-Sat)
    for (final day in medication.days) {
      if (day < 0 || day > 6) {
        return ValidationFailure(message: 'Invalid day specified: $day');
      }
    }

    return null;
  }

  /// Map exceptions to failures
  Failure _mapExceptionToFailure(AppException exception) {
    if (exception is NetworkException) {
      return NetworkFailure(message: exception.message);
    } else if (exception is ServerException) {
      return ServerFailure(message: exception.message);
    } else if (exception is AuthenticationException) {
      return AuthenticationFailure(message: exception.message);
    } else if (exception is PermissionException) {
      return PermissionFailure(message: exception.message);
    } else if (exception is NotFoundException) {
      return DataFailure(message: exception.message);
    } else if (exception is ValidationException) {
      return ValidationFailure(message: exception.message);
    } else if (exception is FirestoreException) {
      return DataFailure(message: exception.message);
    } else if (exception is DataException) {
      return DataFailure(message: exception.message);
    } else {
      return DataFailure(message: exception.message);
    }
  }
}
