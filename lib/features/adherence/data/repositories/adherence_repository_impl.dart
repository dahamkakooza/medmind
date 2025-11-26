import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/adherence_log_entity.dart';
import '../../domain/repositories/adherence_repository.dart';
import '../../../dashboard/domain/entities/adherence_entity.dart';
import '../datasources/adherence_remote_data_source.dart';
import '../models/adherence_log_model.dart';
import '../../../dashboard/data/models/adherence_model.dart';

class AdherenceRepositoryImpl implements AdherenceRepository {
  final AdherenceRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth;

  AdherenceRepositoryImpl({
    required this.remoteDataSource,
    required this.firebaseAuth,
  });

  String get _currentUserId => firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<Either<Failure, List<AdherenceLogEntity>>> getAdherenceLogs({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (_currentUserId.isEmpty) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      // Verify user can only access their own logs
      if (userId != _currentUserId) {
        return Left(
          PermissionFailure(message: 'Access denied to adherence logs'),
        );
      }

      final logs = await remoteDataSource.getAdherenceLogs(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return Right(logs.cast<AdherenceLogEntity>());
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(DataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AdherenceLogEntity>> logMedicationTaken(
    AdherenceLogEntity log,
  ) async {
    try {
      if (_currentUserId.isEmpty) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      // Validate log data
      final validationResult = _validateAdherenceLog(log);
      if (validationResult != null) {
        return Left(validationResult);
      }

      // Ensure the log belongs to the current user
      final logWithUserId = log.copyWith(userId: _currentUserId);
      final logModel = AdherenceLogModel.fromEntity(logWithUserId);

      final addedLog = await remoteDataSource.logMedicationTaken(logModel);
      return Right(addedLog);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(DataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AdherenceEntity>> getAdherenceSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (_currentUserId.isEmpty) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      // Verify user can only access their own summary
      if (userId != _currentUserId) {
        return Left(
          PermissionFailure(message: 'Access denied to adherence summary'),
        );
      }

      // Validate date range
      if (startDate.isAfter(endDate)) {
        return Left(
          ValidationFailure(message: 'Start date must be before end date'),
        );
      }

      final summaryData = await remoteDataSource.getAdherenceSummary(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      // Convert summary data to AdherenceEntity
      final adherenceEntity = AdherenceModel.fromAggregatedData(
        adherenceRate: (summaryData['adherenceRate'] as num).toDouble(),
        totalMedications: summaryData['totalMedications'] as int,
        takenCount: summaryData['takenCount'] as int,
        missedCount: summaryData['missedCount'] as int,
        streakDays: summaryData['streakDays'] as int,
      );

      return Right(adherenceEntity);
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(DataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> exportAdherenceData(String userId) async {
    try {
      if (_currentUserId.isEmpty) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      // Verify user can only export their own data
      if (userId != _currentUserId) {
        return Left(PermissionFailure(message: 'Access denied to export data'));
      }

      // Get all adherence logs for the user
      final logsResult = await getAdherenceLogs(userId: userId);

      return logsResult.fold((failure) => Left(failure), (logs) {
        // Generate CSV format export
        final csvHeader =
            'Date,Time,Medication ID,Status,Snooze Duration,Notes\n';
        final csvRows = logs
            .map((log) {
              final scheduledTime = log.scheduledTime;
              final date =
                  '${scheduledTime.year}-${scheduledTime.month.toString().padLeft(2, '0')}-${scheduledTime.day.toString().padLeft(2, '0')}';
              final time =
                  '${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}';
              final status = log.status.name;
              final snoozeDuration = log.snoozeDuration?.toString() ?? '';

              return '$date,$time,${log.medicationId},$status,$snoozeDuration,';
            })
            .join('\n');

        final csvContent = csvHeader + csvRows;
        return Right(csvContent);
      });
    } on AppException catch (e) {
      return Left(_mapExceptionToFailure(e));
    } catch (e) {
      return Left(DataFailure(message: 'Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<AdherenceLogEntity>>> watchAdherenceLogs(
    String userId,
  ) {
    try {
      if (_currentUserId.isEmpty) {
        return Stream.value(
          Left(AuthenticationFailure(message: 'User not authenticated')),
        );
      }

      // Verify user can only watch their own logs
      if (userId != _currentUserId) {
        return Stream.value(
          Left(PermissionFailure(message: 'Access denied to adherence logs')),
        );
      }

      return remoteDataSource
          .watchAdherenceLogs(userId)
          .map<Either<Failure, List<AdherenceLogEntity>>>(
            (logs) => Right(logs.cast<AdherenceLogEntity>()),
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

  /// Validate adherence log entity
  ValidationFailure? _validateAdherenceLog(AdherenceLogEntity log) {
    if (log.medicationId.trim().isEmpty) {
      return ValidationFailure(message: 'Medication ID cannot be empty');
    }

    if (log.scheduledTime.isAfter(
      DateTime.now().add(const Duration(days: 1)),
    )) {
      return ValidationFailure(
        message: 'Scheduled time cannot be more than 1 day in the future',
      );
    }

    if (log.status == AdherenceStatus.taken && log.takenTime == null) {
      return ValidationFailure(
        message: 'Taken time must be provided when status is taken',
      );
    }

    if (log.status == AdherenceStatus.snoozed && log.snoozeDuration == null) {
      return ValidationFailure(
        message: 'Snooze duration must be provided when status is snoozed',
      );
    }

    if (log.snoozeDuration != null &&
        (log.snoozeDuration! < 1 || log.snoozeDuration! > 1440)) {
      return ValidationFailure(
        message: 'Snooze duration must be between 1 and 1440 minutes',
      );
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
