import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/firebase_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/medication_model.dart';

abstract class MedicationRemoteDataSource {
  Future<List<MedicationModel>> getMedications(String userId);
  Future<MedicationModel> getMedicationById(String id);
  Future<MedicationModel> addMedication(MedicationModel medication);
  Future<void> updateMedication(MedicationModel medication);
  Future<void> deleteMedication(String id);
  Future<MedicationModel?> lookupBarcode(String barcodeData);
  Stream<List<MedicationModel>> watchMedications(String userId);
}

class MedicationRemoteDataSourceImpl implements MedicationRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  MedicationRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  CollectionReference get _medicationsCollection =>
      firestore.collection(FirebaseConstants.medicationsPath);

  String get _currentUserId => firebaseAuth.currentUser?.uid ?? '';

  @override
  Future<List<MedicationModel>> getMedications(String userId) async {
    try {
      final querySnapshot = await _medicationsCollection
          .where(FirebaseConstants.userIdField, isEqualTo: userId)
          .where(FirebaseConstants.isActiveField, isEqualTo: true)
          .orderBy(FirebaseConstants.createdAtField, descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MedicationModel.fromDocument(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw DataException(
        message: 'Failed to get medications: ${e.toString()}',
        code: 'get_medications_error',
      );
    }
  }

  @override
  Future<MedicationModel> getMedicationById(String id) async {
    try {
      final docSnapshot = await _medicationsCollection.doc(id).get();

      if (!docSnapshot.exists) {
        throw NotFoundException(
          message: 'Medication with ID $id not found',
          code: 'medication_not_found',
        );
      }

      final medication = MedicationModel.fromDocument(docSnapshot);

      // Verify user ownership
      if (medication.userId != _currentUserId) {
        throw PermissionException(
          message: 'Access denied to medication',
          code: 'medication_access_denied',
        );
      }

      return medication;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DataException(
        message: 'Failed to get medication: ${e.toString()}',
        code: 'get_medication_error',
      );
    }
  }

  @override
  Future<MedicationModel> addMedication(MedicationModel medication) async {
    try {
      // Ensure the medication belongs to the current user
      final medicationWithUserId = MedicationModel.fromEntity(
        medication.copyWith(userId: _currentUserId),
      );

      final docRef = _medicationsCollection.doc();
      final medicationWithId = MedicationModel.fromEntity(
        medicationWithUserId.copyWith(id: docRef.id),
      );

      await docRef.set(medicationWithId.toDocument());

      return medicationWithId;
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw DataException(
        message: 'Failed to add medication: ${e.toString()}',
        code: 'add_medication_error',
      );
    }
  }

  @override
  Future<void> updateMedication(MedicationModel medication) async {
    try {
      // Verify user ownership
      if (medication.userId != _currentUserId) {
        throw PermissionException(
          message: 'Access denied to update medication',
          code: 'medication_update_denied',
        );
      }

      // Update the updatedAt timestamp
      final updatedMedication = MedicationModel.fromEntity(
        medication.copyWith(updatedAt: DateTime.now()),
      );

      await _medicationsCollection
          .doc(medication.id)
          .update(updatedMedication.toDocument());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DataException(
        message: 'Failed to update medication: ${e.toString()}',
        code: 'update_medication_error',
      );
    }
  }

  @override
  Future<void> deleteMedication(String id) async {
    try {
      // First verify the medication exists and user owns it
      final medication = await getMedicationById(id);

      // Soft delete by setting isActive to false
      final updatedMedication = MedicationModel.fromEntity(
        medication.copyWith(isActive: false, updatedAt: DateTime.now()),
      );

      await _medicationsCollection
          .doc(id)
          .update(updatedMedication.toDocument());
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw DataException(
        message: 'Failed to delete medication: ${e.toString()}',
        code: 'delete_medication_error',
      );
    }
  }

  @override
  Future<MedicationModel?> lookupBarcode(String barcodeData) async {
    try {
      final querySnapshot = await _medicationsCollection
          .where(FirebaseConstants.barcodeDataField, isEqualTo: barcodeData)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return MedicationModel.fromDocument(querySnapshot.docs.first);
    } on FirebaseException catch (e) {
      throw _handleFirebaseException(e);
    } catch (e) {
      throw DataException(
        message: 'Failed to lookup barcode: ${e.toString()}',
        code: 'barcode_lookup_error',
      );
    }
  }

  @override
  Stream<List<MedicationModel>> watchMedications(String userId) {
    try {
      return _medicationsCollection
          .where(FirebaseConstants.userIdField, isEqualTo: userId)
          .where(FirebaseConstants.isActiveField, isEqualTo: true)
          .orderBy(FirebaseConstants.createdAtField, descending: true)
          .snapshots()
          .map((querySnapshot) {
            return querySnapshot.docs
                .map((doc) => MedicationModel.fromDocument(doc))
                .toList();
          })
          .handleError((error) {
            if (error is FirebaseException) {
              throw _handleFirebaseException(error);
            }
            throw DataException(
              message: 'Failed to watch medications: ${error.toString()}',
              code: 'watch_medications_error',
            );
          });
    } catch (e) {
      throw DataException(
        message: 'Failed to setup medications stream: ${e.toString()}',
        code: 'medications_stream_error',
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
