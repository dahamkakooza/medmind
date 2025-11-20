import '../models/adherence_log_model.dart';

abstract class AdherenceRemoteDataSource {
  Future<List<AdherenceLogModel>> getAdherenceLogs({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<AdherenceLogModel> logMedicationTaken({
    required String medicationId,
    required DateTime takenAt,
    String? notes,
  });
  Future<Map<String, dynamic>> getAdherenceSummary();
  Future<String> exportAdherenceData(String format);
}

class AdherenceRemoteDataSourceImpl implements AdherenceRemoteDataSource {
  @override
  Future<List<AdherenceLogModel>> getAdherenceLogs({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // TODO: Implement Firebase Firestore call
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<AdherenceLogModel> logMedicationTaken({
    required String medicationId,
    required DateTime takenAt,
    String? notes,
  }) async {
    // TODO: Implement Firebase Firestore add
    await Future.delayed(const Duration(milliseconds: 500));
    return AdherenceLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      medicationId: medicationId,
      medicationName: 'Sample Medication',
      takenAt: takenAt,
      notes: notes,
      wasOnTime: true,
    );
  }

  @override
  Future<Map<String, dynamic>> getAdherenceSummary() async {
    // TODO: Implement Firebase Firestore aggregation
    await Future.delayed(const Duration(seconds: 1));
    return {
      'overallAdherence': 85.0,
      'currentStreak': 12,
      'bestStreak': 28,
      'missedDoses': 3,
      'chartData': [],
    };
  }

  @override
  Future<String> exportAdherenceData(String format) async {
    // TODO: Implement data export
    await Future.delayed(const Duration(seconds: 2));
    return '/path/to/exported/file.$format';
  }
}