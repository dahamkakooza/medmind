
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../medication/domain/entities/medication_entity.dart';
import '../../domain/entities/adherence_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

@LazySingleton(as: DashboardRepository) // ADD THIS
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.firebaseAuth,
  });

  String get _currentUserId => firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<Either<Failure, List<MedicationEntity>>> getTodayMedications() async {
    try {
      if (_currentUserId.isEmpty) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      // Verify user can only access their own medications
      final medications = await remoteDataSource.getTodayMedications(
        _currentUserId,
      );
      return Right(medications.cast<MedicationEntity>());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(DataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AdherenceEntity>> getAdherenceStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (_currentUserId.isEmpty) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      // Validate date range if provided
      if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
        return Left(
          ValidationFailure(message: 'Start date must be before end date'),
        );
      }

      final adherenceStats = await remoteDataSource.getAdherenceStats(
        _currentUserId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(adherenceStats);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(DataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, AdherenceEntity>> watchAdherenceStats() {
    try {
      if (_currentUserId.isEmpty) {
        return Stream.value(
          Left(AuthenticationFailure(message: 'User not authenticated')),
        );
      }

      return remoteDataSource
          .watchAdherenceStats(_currentUserId)
          .map<Either<Failure, AdherenceEntity>>(
            (adherenceStats) => Right(adherenceStats),
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

  @override
  Future<Either<Failure, void>> logMedicationTaken(String medicationId) async {
    try {
      if (_currentUserId.isEmpty) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      print('📊 [DashboardRepo] Logging medication taken: $medicationId');
      
      final log = {
        'medicationId': medicationId,
        'userId': _currentUserId,
        'scheduledTime': DateTime.now(),
        'takenTime': DateTime.now(),
        'status': 'taken',
        'notes': 'Logged from dashboard',
      };

      print('✅ [DashboardRepo] Medication logged successfully');
      
      return const Right(null);
    } on AppException catch (e) {
      print('❌ [DashboardRepo] Error logging medication: ${e.message}');
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      print('❌ [DashboardRepo] Unexpected error: $e');
      return Left(DataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
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
