import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/entities/emergency_contact_entity.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../models/user_preferences_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  // User Profile Methods - TEMPORARY MOCK IMPLEMENTATIONS
  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    try {
      // TODO: Backend Dev 2 - Implement real user profile from Firestore
      // For now, return a mock user profile
      final mockProfile = UserProfileEntity(
        id: 'mock-user-id',
        displayName: 'MedMind User',
        email: 'user@medmind.com',
        photoURL: null,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      return Right(mockProfile);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get user profile: $e'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateUserProfile(UserProfileEntity profile) async {
    try {
      // TODO: Backend Dev 2 - Implement real profile update
      // For now, just return the same profile
      return Right(profile);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update user profile: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDisplayName(String displayName) async {
    try {
      // TODO: Backend Dev 2 - Implement real display name update
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update display name: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePhotoURL(String photoURL) async {
    try {
      // TODO: Backend Dev 2 - Implement real photo URL update
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update photo URL: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmergencyContact(EmergencyContact contact) async {
    try {
      // TODO: Backend Dev 2 - Implement real emergency contact update
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update emergency contact: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateHealthInfo({
    List<String>? healthConditions,
    List<String>? allergies,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    try {
      // TODO: Backend Dev 2 - Implement real health info update
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update health info: $e'));
    }
  }

  // User Preferences Methods - WORKING WITH LOCAL STORAGE
  @override
  Future<Either<Failure, UserPreferencesEntity>> getPreferences() async {
    try {
      final preferencesModel = await localDataSource.getPreferences();
      // Convert model to entity (using Flutter ThemeMode)
      final preferencesEntity = UserPreferencesEntity(
        themeMode: _convertToEntityThemeMode(preferencesModel.themeMode),
        notificationsEnabled: preferencesModel.notificationsEnabled,
        reminderSnoozeDuration: preferencesModel.reminderSnoozeDuration,
        language: _convertToEntityLanguage(preferencesModel.language),
        biometricAuthEnabled: preferencesModel.biometricAuthEnabled,
        dataBackupEnabled: preferencesModel.dataBackupEnabled,
        lastBackup: preferencesModel.lastBackup,
      );
      return Right(preferencesEntity);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get preferences: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> savePreferences(UserPreferencesEntity preferences) async {
    try {
      // Convert entity to model (using Flutter ThemeMode)
      final preferencesModel = UserPreferencesModel(
        themeMode: _convertToModelThemeMode(preferences.themeMode),
        notificationsEnabled: preferences.notificationsEnabled,
        reminderSnoozeDuration: preferences.reminderSnoozeDuration,
        language: _convertToModelLanguage(preferences.language),
        biometricAuthEnabled: preferences.biometricAuthEnabled,
        dataBackupEnabled: preferences.dataBackupEnabled,
        lastBackup: preferences.lastBackup,
      );
      await localDataSource.savePreferences(preferencesModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save preferences: $e'));
    }
  }

  @override
  Future<Either<Failure, UserPreferencesEntity>> updateThemeMode(ThemeMode themeMode) async {
    try {
      // Update individual preference
      final currentModel = await localDataSource.getPreferences();
      final updatedModel = currentModel.copyWith(
        themeMode: _convertToModelThemeMode(themeMode),
      );
      await localDataSource.savePreferences(updatedModel);

      // Return updated preferences entity
      final updatedEntity = UserPreferencesEntity(
        themeMode: themeMode,
        notificationsEnabled: currentModel.notificationsEnabled,
        reminderSnoozeDuration: currentModel.reminderSnoozeDuration,
        language: _convertToEntityLanguage(currentModel.language),
        biometricAuthEnabled: currentModel.biometricAuthEnabled,
        dataBackupEnabled: currentModel.dataBackupEnabled,
        lastBackup: currentModel.lastBackup,
      );
      return Right(updatedEntity);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update theme mode: $e'));
    }
  }

  @override
  Future<Either<Failure, UserPreferencesEntity>> updateNotifications(bool enabled) async {
    try {
      // Update individual preference
      final currentModel = await localDataSource.getPreferences();
      final updatedModel = currentModel.copyWith(
        notificationsEnabled: enabled,
      );
      await localDataSource.savePreferences(updatedModel);

      // Return updated preferences entity
      final updatedEntity = UserPreferencesEntity(
        themeMode: _convertToEntityThemeMode(currentModel.themeMode),
        notificationsEnabled: enabled,
        reminderSnoozeDuration: currentModel.reminderSnoozeDuration,
        language: _convertToEntityLanguage(currentModel.language),
        biometricAuthEnabled: currentModel.biometricAuthEnabled,
        dataBackupEnabled: currentModel.dataBackupEnabled,
        lastBackup: currentModel.lastBackup,
      );
      return Right(updatedEntity);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update notifications: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllData() async {
    try {
      await localDataSource.clearPreferences();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear data: $e'));
    }
  }

  // Account Management - TEMPORARY MOCK IMPLEMENTATIONS
  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      // TODO: Backend Dev 1 - Implement real account deletion
      await Future.delayed(const Duration(seconds: 1));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete account: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> exportUserData() async {
    try {
      // TODO: Backend Dev 2 - Implement real data export
      await Future.delayed(const Duration(seconds: 2));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to export data: $e'));
    }
  }

  // Helper methods to convert between model and entity enums
  ThemeMode _convertToEntityThemeMode(dynamic modelThemeMode) {
    if (modelThemeMode is ThemeMode) {
      return modelThemeMode; // Already Flutter ThemeMode
    }
    if (modelThemeMode.toString().contains('light')) return ThemeMode.light;
    if (modelThemeMode.toString().contains('dark')) return ThemeMode.dark;
    return ThemeMode.system;
  }

  ThemeMode _convertToModelThemeMode(ThemeMode entityThemeMode) {
    return entityThemeMode; // Now returns Flutter ThemeMode directly
  }

  String _convertToEntityLanguage(dynamic modelLanguage) {
    if (modelLanguage is Language) {
      switch (modelLanguage) {
        case Language.spanish:
          return 'spanish';
        case Language.french:
          return 'french';
        case Language.english:
        default:
          return 'english';
      }
    }
    if (modelLanguage.toString().contains('spanish')) return 'spanish';
    if (modelLanguage.toString().contains('french')) return 'french';
    return 'english';
  }

  Language _convertToModelLanguage(String entityLanguage) {
    switch (entityLanguage) {
      case 'spanish':
        return Language.spanish;
      case 'french':
        return Language.french;
      case 'english':
      default:
        return Language.english;
    }
  }
}