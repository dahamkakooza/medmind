// import '../../../medication/data/models/medication_model.dart';
// import '../models/adherence_model.dart';
//
// abstract class DashboardRemoteDataSource {
//   Future<List<MedicationModel>> getTodayMedications();
//   Future<AdherenceModel> getAdherenceStats();
//   Future<void> logMedicationTaken(String medicationId);
// }
//
// class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
//   @override
//   Future<List<MedicationModel>> getTodayMedications() async {
//     // TODO: Implement Firebase Firestore call
//     await Future.delayed(const Duration(seconds: 1));
//     return [];
//   }
//
//   @override
//   Future<AdherenceModel> getAdherenceStats() async {
//     // TODO: Implement Firebase Firestore call
//     await Future.delayed(const Duration(seconds: 1));
//     return const AdherenceModel(
//       weeklyPercentage: 85.0,
//       monthlyPercentage: 78.0,
//       currentStreak: 12,
//       totalTaken: 45,
//       totalMissed: 3,
//     );
//   }
//
//   @override
//   Future<void> logMedicationTaken(String medicationId) async {
//     // TODO: Implement Firebase Firestore update
//     await Future.delayed(const Duration(milliseconds: 500));
//   }
// }
import 'package:injectable/injectable.dart'; // ADD THIS
import '../../../medication/data/models/medication_model.dart';
import '../models/adherence_model.dart';

abstract class DashboardRemoteDataSource {
  Future<List<MedicationModel>> getTodayMedications();
  Future<AdherenceModel> getAdherenceStats();
  Future<void> logMedicationTaken(String medicationId);
}

@LazySingleton(as: DashboardRemoteDataSource) // ADD THIS
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  @override
  Future<List<MedicationModel>> getTodayMedications() async {
    // TODO: Implement Firebase Firestore call
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<AdherenceModel> getAdherenceStats() async {
    // TODO: Implement Firebase Firestore call
    await Future.delayed(const Duration(seconds: 1));
    return const AdherenceModel(
      weeklyPercentage: 85.0,
      monthlyPercentage: 78.0,
      currentStreak: 12,
      totalTaken: 45,
      totalMissed: 3,
    );
  }

  @override
  Future<void> logMedicationTaken(String medicationId) async {
    // TODO: Implement Firebase Firestore update
    await Future.delayed(const Duration(milliseconds: 500));
  }
}