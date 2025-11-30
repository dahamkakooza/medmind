import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import 'package:medmind/features/medication/domain/entities/medication_entity.dart';
import 'package:medmind/features/adherence/domain/entities/adherence_log_entity.dart';
import '../../../medication/data/models/medication_model.dart';
import '../../../adherence/data/models/adherence_log_model.dart';
import '../models/adherence_model.dart';
import '../../domain/entities/adherence_entity.dart';

abstract class DashboardRemoteDataSource {
  Future<List<MedicationModel>> getTodayMedications(String userId);
  Future<AdherenceModel> getAdherenceStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Stream<AdherenceModel> watchAdherenceStats(String userId);
}

@LazySingleton(as: DashboardRemoteDataSource) // ADD THIS
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  DashboardRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  CollectionReference get _medicationsCollection =>
      firestore.collection(FirebaseConstants.medicationsPath);

  CollectionReference get _adherenceLogsCollection =>
      firestore.collection(FirebaseConstants.adherenceLogsPath);

  String get _currentUserId => firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<List<MedicationModel>> getTodayMedications(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final currentDayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday

      // Get all active medications for the user
      final querySnapshot = await _medicationsCollection
          .where(FirebaseConstants.userIdField, isEqualTo: userId)
          .where(FirebaseConstants.isActiveField, isEqualTo: true)
          .get();

      final allMedications = querySnapshot.docs
          .map((doc) => MedicationModel.fromDocument(doc))
          .toList();

      // Filter medications that should be taken today
      final todayMedications = <MedicationModel>[];

      for (final medication in allMedications) {
        // Check if medication should be taken today based on frequency and days
        bool shouldTakeToday = false;

        switch (medication.frequency) {
          case MedicationFrequency.daily:
            shouldTakeToday = true;
            break;
          case MedicationFrequency.weekly:
            // Check if current day is in the medication's days list
            // Convert Flutter weekday (1-7, Mon-Sun) to our format (0-6, Sun-Sat)
            final dayIndex = currentDayOfWeek == 7 ? 0 : currentDayOfWeek;
            shouldTakeToday = medication.days.contains(dayIndex);
            break;
          case MedicationFrequency.custom:
            // For custom frequency, check if today is in the specified days
            final dayIndex = currentDayOfWeek == 7 ? 0 : currentDayOfWeek;
            shouldTakeToday = medication.days.contains(dayIndex);
            break;
        }

        // Also check if the medication start date has passed
        if (shouldTakeToday && medication.startDate.isBefore(now)) {
          todayMedications.add(medication);
        }
      }

      return todayMedications;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw DataException(
        message: 'Failed to get today\'s medications: ${e.toString()}',
        code: 'get_today_medications_error',
      );
    }
  }

  @override
  Future<AdherenceModel> getAdherenceStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final now = DateTime.now();
      final effectiveStartDate =
          startDate ?? now.subtract(const Duration(days: 30));
      final effectiveEndDate = endDate ?? now;

      // Get adherence logs for the specified period
      final querySnapshot = await _adherenceLogsCollection
          .where(FirebaseConstants.userIdField, isEqualTo: userId)
          .where(
            FirebaseConstants.scheduledTimeField,
            isGreaterThanOrEqualTo: Timestamp.fromDate(effectiveStartDate),
          )
          .where(
            FirebaseConstants.scheduledTimeField,
            isLessThanOrEqualTo: Timestamp.fromDate(effectiveEndDate),
          )
          .get();

      final logs = querySnapshot.docs
          .map((doc) => AdherenceLogModel.fromDocument(doc))
          .toList();

      // Calculate basic statistics
      final totalLogs = logs.length;
      final takenLogs = logs
          .where((log) => log.status == AdherenceStatus.taken)
          .length;
      final missedLogs = logs
          .where((log) => log.status == AdherenceStatus.missed)
          .length;

      final adherenceRate = totalLogs > 0 ? takenLogs / totalLogs : 0.0;

      // Calculate weekly statistics
      final weeklyStats = _calculateWeeklyStats(logs);

      // Calculate monthly statistics
      final monthlyStats = _calculateMonthlyStats(logs);

      // Calculate current streak
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

      return AdherenceModel.fromAggregatedData(
        adherenceRate: adherenceRate,
        totalMedications: totalLogs,
        takenCount: takenLogs,
        missedCount: missedLogs,
        weeklyStats: weeklyStats,
        monthlyStats: monthlyStats,
        streakDays: currentStreak,
      );
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw DataException(
        message: 'Failed to get adherence stats: ${e.toString()}',
        code: 'get_adherence_stats_error',
      );
    }
  }

  @override
  Stream<AdherenceModel> watchAdherenceStats(String userId) {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));

      return _adherenceLogsCollection
          .where(FirebaseConstants.userIdField, isEqualTo: userId)
          .where(
            FirebaseConstants.scheduledTimeField,
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .snapshots()
          .asyncMap((querySnapshot) async {
            final logs = querySnapshot.docs
                .map((doc) => AdherenceLogModel.fromDocument(doc))
                .toList();

            // Calculate statistics (same logic as getAdherenceStats)
            final totalLogs = logs.length;
            final takenLogs = logs
                .where((log) => log.status == AdherenceStatus.taken)
                .length;
            final missedLogs = logs
                .where((log) => log.status == AdherenceStatus.missed)
                .length;

            final adherenceRate = totalLogs > 0 ? takenLogs / totalLogs : 0.0;

            final weeklyStats = _calculateWeeklyStats(logs);
            final monthlyStats = _calculateMonthlyStats(logs);

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

            return AdherenceModel.fromAggregatedData(
              adherenceRate: adherenceRate,
              totalMedications: totalLogs,
              takenCount: takenLogs,
              missedCount: missedLogs,
              weeklyStats: weeklyStats,
              monthlyStats: monthlyStats,
              streakDays: currentStreak,
            );
          })
          .handleError((error) {
            if (error is FirebaseException) {
              throw _handleFirebaseException(error);
            }
            throw DataException(
              message: 'Failed to watch adherence stats: ${error.toString()}',
              code: 'watch_adherence_stats_error',
            );
          });
    } catch (e) {
      throw DataException(
        message: 'Failed to setup adherence stats stream: ${e.toString()}',
        code: 'adherence_stats_stream_error',
      );
    }
  }

  /// Calculate weekly statistics from adherence logs
  List<WeeklyStats> _calculateWeeklyStats(List<AdherenceLogModel> logs) {
    final weeklyMap = <int, List<AdherenceLogModel>>{};

    for (final log in logs) {
      final weekNumber = _getWeekNumber(log.scheduledTime);
      weeklyMap.putIfAbsent(weekNumber, () => []).add(log);
    }

    return weeklyMap.entries.map((entry) {
      final weekLogs = entry.value;
      final takenCount = weekLogs
          .where((log) => log.status == AdherenceStatus.taken)
          .length;
      final missedCount = weekLogs
          .where((log) => log.status == AdherenceStatus.missed)
          .length;
      final totalCount = weekLogs.length;
      final adherenceRate = totalCount > 0 ? takenCount / totalCount : 0.0;

      return WeeklyStats(
        weekNumber: entry.key,
        adherenceRate: adherenceRate,
        takenCount: takenCount,
        missedCount: missedCount,
      );
    }).toList()..sort((a, b) => a.weekNumber.compareTo(b.weekNumber));
  }

  /// Calculate monthly statistics from adherence logs
  List<MonthlyStats> _calculateMonthlyStats(List<AdherenceLogModel> logs) {
    final monthlyMap = <String, List<AdherenceLogModel>>{};

    for (final log in logs) {
      final monthKey = '${log.scheduledTime.year}-${log.scheduledTime.month}';
      monthlyMap.putIfAbsent(monthKey, () => []).add(log);
    }

    return monthlyMap.entries.map((entry) {
      final monthLogs = entry.value;
      final takenCount = monthLogs
          .where((log) => log.status == AdherenceStatus.taken)
          .length;
      final missedCount = monthLogs
          .where((log) => log.status == AdherenceStatus.missed)
          .length;
      final totalCount = monthLogs.length;
      final adherenceRate = totalCount > 0 ? takenCount / totalCount : 0.0;

      final parts = entry.key.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      return MonthlyStats(
        month: month,
        year: year,
        adherenceRate: adherenceRate,
        takenCount: takenCount,
        missedCount: missedCount,
      );
    }).toList()..sort((a, b) {
      final aDate = DateTime(a.year, a.month);
      final bDate = DateTime(b.year, b.month);
      return aDate.compareTo(bDate);
    });
  }

  /// Get week number for a given date
  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(startOfYear).inDays;
    return (daysSinceStart / 7).ceil();
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
