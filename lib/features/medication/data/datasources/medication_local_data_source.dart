import '../models/medication_model.dart';

abstract class MedicationLocalDataSource {
  Future<List<MedicationModel>> getCachedMedications();
  Future<void> cacheMedications(List<MedicationModel> medications);
  Future<void> cacheMedication(MedicationModel medication);
  Future<void> removeCachedMedication(String id);
}

class MedicationLocalDataSourceImpl implements MedicationLocalDataSource {
  @override
  Future<List<MedicationModel>> getCachedMedications() async {
    // TODO: Implement SharedPreferences/Hive cache
    return [];
  }

  @override
  Future<void> cacheMedications(List<MedicationModel> medications) async {
    // TODO: Implement cache storage
  }

  @override
  Future<void> cacheMedication(MedicationModel medication) async {
    // TODO: Implement single medication cache
  }

  @override
  Future<void> removeCachedMedication(String id) async {
    // TODO: Implement cache removal
  }
}