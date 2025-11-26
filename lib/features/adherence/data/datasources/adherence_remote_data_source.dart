import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/adherence_log_model.dart';
import '../../domain/entities/adherence_log_entity.dart';

abstract class AdherenceRemoteDataSource {
  Future<List<AdherenceLogModel>> getAdherenceLogs({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<AdherenceLogModel> logMedicationTaken(AdherenceLogModel log);
  Future<void> updateAdherenceLog(AdherenceLogModel log);
  Future<Map<String, dynamic>> getAdherenceSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
  Stream<List<AdherenceLogModel>> watchAdherenceLogs(String userId);
}

class AdherenceRemoteDataSourceImpl implements AdherenceRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  AdherenceRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  CollectionReference get _adherenceLogsCollection =>
      firestore.collection(FirebaseConstants.adherenceLogsPath);

  String get _currentUserId => firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<List<AdherenceLogModel>> getAdherenceLogs({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _adherenceLogsCollection.where(
        FirebaseConstants.userIdField,
        isEqualTo: userId,
      );

      if (startDate != null) {
        query = query.where(
          FirebaseConstants.scheduledTimeField,
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          FirebaseConstants.scheduledTimeField,
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final querySnapshot = await query
          .orderBy(FirebaseConstants.scheduledTimeField, descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AdherenceLogModel.fromDocument(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw DataException(
        message: 'Failed to get adherence logs: ${e.toString()}',
        code: 'get_adherence_logs_error',
      );
    }
  }

  @override
  Future<AdherenceLogModel> logMedicationTaken(AdherenceLogModel log) async {
    try {
      // Ensure the log belongs to the current user
      final logWithUserId = AdherenceLogModel.fromEntity(
        log.copyWith(userId: _currentUserId),
      );

      final docRef = _adherenceLogsCollection.doc();
      final logWithId = AdherenceLogModel.fromEntity(
        logWithUserId.copyWith(id: docRef.id),
      );

      await docRef.set(logWithId.toDocument());

      return logWithId;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw DataException(
        message: 'Failed to log medication taken: ${e.toString()}',
        code: 'log_medication_error',
      );
    }
  }

  @override
  Future<void> updateAdherenceLog(AdherenceLogModel log) async {
    try {
      // Verify user ownership
      if (log.userId != _currentUserId) {
        throw PermissionException(
          message: 'Access denied to update adherence log',
          code: 'adherence_log_update_denied',
        );
      }

      await _adherenceLogsCollection.doc(log.id).update(log.toDocument());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DataException(
        message: 'Failed to update adherence log: ${e.toString()}',
        code: 'update_adherence_log_error',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getAdherenceSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final querySnapshot = await _adherenceLogsCollection
          .where(FirebaseConstants.userIdField, isEqualTo: userId)
          .where(
            FirebaseConstants.scheduledTimeField,
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where(
            FirebaseConstants.scheduledTimeField,
            isLessThanOrEqualTo: Timestamp.fromDate(endDate),
          )
          .get();

      final logs = querySnapshot.docs
          .map((doc) => AdherenceLogModel.fromDocument(doc))
          .toList();

      // Calculate statistics
      final totalLogs = logs.length;
      final takenLogs = logs
          .where((log) => log.status == AdherenceStatus.taken)
          .length;
      final missedLogs = logs
          .where((log) => log.status == AdherenceStatus.missed)
          .length;
      final snoozedLogs = logs
          .where((log) => log.status == AdherenceStatus.snoozed)
          .length;

      final adherenceRate = totalLogs > 0 ? takenLogs / totalLogs : 0.0;

      // Calculate streak
      final sortedLogs = logs
        ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
      int currentStreak = 0;

      for (final log in sortedLogs) {
        if (log.status == AdherenceStatus.taken) {
          currentStreak++;
        } else {
          break;
        }
      }

      return {
        'adherenceRate': adherenceRate,
        'totalMedications': totalLogs,
        'takenCount': takenLogs,
        'missedCount': missedLogs,
        'snoozedCount': snoozedLogs,
        'streakDays': currentStreak,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw DataException(
        message: 'Failed to get adherence summary: ${e.toString()}',
        code: 'get_adherence_summary_error',
      );
    }
  }

  @override
  Stream<List<AdherenceLogModel>> watchAdherenceLogs(String userId) {
    try {
      return _adherenceLogsCollection
          .where(FirebaseConstants.userIdField, isEqualTo: userId)
          .orderBy(FirebaseConstants.scheduledTimeField, descending: true)
          .limit(100) // Limit to recent logs for performance
          .snapshots()
          .map((querySnapshot) {
            return querySnapshot.docs
                .map((doc) => AdherenceLogModel.fromDocument(doc))
                .toList();
          })
          .handleError((error) {
            if (error is FirebaseException) {
              throw _handleFirebaseException(error);
            }
            throw DataException(
              message: 'Failed to watch adherence logs: ${error.toString()}',
              code: 'watch_adherence_logs_error',
            );
          });
    } catch (e) {
      throw DataException(
        message: 'Failed to setup adherence logs stream: ${e.toString()}',
        code: 'adherence_logs_stream_error',
      );
    }
  }

  /// Handle Firebase exceptions and convert to custom exceptions
  AppException _handleFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return PermissionException(
          message: 'Permission denied: ${e.message}',
          code: e.code,
        );
      case 'not-found':
        return NotFoundException(
          message: 'Resource not found: ${e.message}',
          code: e.code,
        );
      case 'unavailable':
        return NetworkException(
          message: 'Service unavailable: ${e.message}',
          code: e.code,
        );
      case 'deadline-exceeded':
        return NetworkException(
          message: 'Request timeout: ${e.message}',
          code: e.code,
        );
      default:
        return FirestoreException(
          message: e.message ?? 'Unknown Firestore error',
          code: e.code,
          originalCode: e.code,
        );
    }
  }
}
