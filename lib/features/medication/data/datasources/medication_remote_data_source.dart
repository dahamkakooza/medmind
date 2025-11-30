import '../models/medication_model.dart';

abstract class MedicationRemoteDataSource {
  Future<List<MedicationModel>> getMedications();
  Future<MedicationModel> addMedication(MedicationModel medication);
  Future<MedicationModel> updateMedication(MedicationModel medication);
  Future<void> deleteMedication(String id);
  Future<String> scanBarcode();
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  @override
  Future<List<MedicationModel>> getMedications() async {
    // TODO: Implement Firebase Firestore call
    await Future.delayed(const Duration(seconds: 1));
    return [];
  }

  @override
  Future<MedicationModel> addMedication(MedicationModel medication) async {
    // TODO: Implement Firebase Firestore add
    await Future.delayed(const Duration(seconds: 1));
    return medication;
  }

  @override
  Future<MedicationModel> updateMedication(MedicationModel medication) async {
    // TODO: Implement Firebase Firestore update
    await Future.delayed(const Duration(seconds: 1));
    return medication;
  }

  @override
  Future<void> deleteMedication(String id) async {
    // TODO: Implement Firebase Firestore delete
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<String> scanBarcode() async {
    // TODO: Implement barcode scanning
    await Future.delayed(const Duration(seconds: 2));
    return 'Sample Medication';
  }
}
