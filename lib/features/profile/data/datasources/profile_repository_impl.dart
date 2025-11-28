import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/entities/emergency_contact_entity.dart';
import '../../domain/entities/user_preferences_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../models/user_preferences_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  // User Profile Methods - Using EXACT constructor parameters from UserProfileEntity
  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    try {
      final profile = UserProfileEntity(
        id: 'default_user_id',
        displayName: 'User',
        email: 'user@example.com',
        photoURL: null,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        dateOfBirth: DateTime(1990, 1, 1),
        gender: 'Prefer not to say',
        healthConditions: [],
        allergies: [],
        emergencyContacts: [],
      );
      return Right(profile);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get user profile: $e', code: 'profile_load_failure'));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateUserProfile(UserProfileEntity profile) async {
    try {
      // Return the updated profile (in real implementation, save to data source)
      return Right(profile);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update user profile: $e', code: 'profile_update_failure'));
    }
  }

  @override
  Future<Either<Failure, void>> updateDisplayName(String displayName) async {
    try {
      // TODO: Implement display name update logic
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update display name: $e', code: 'display_name_update_failure'));
    }
  }

  @override
  Future<Either<Failure, void>> updatePhotoURL(String photoURL) async {
    try {
      // TODO: Implement photo URL update logic
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update photo URL: $e', code: 'photo_update_failure'));
    }
  }

  @override
  Future<Either<Failure, void>> updateEmergencyContact(EmergencyContact contact) async {
    try {
      // TODO: Implement emergency contact update logic
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update emergency contact: $e', code: 'emergency_contact_update_failure'));
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
      // TODO: Implement health info update logic
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update health info: $e', code: 'health_info_update_failure'));
    }
  }

  // User Preferences Methods - PERFECT TYPE MATCHING between Model and Entity
  @override
  Future<Either<Failure, UserPreferencesEntity>> getPreferences() async {
    try {
      final preferencesModel = await localDataSource.getPreferences();

      // Convert model to entity with PERFECT type matching
      final preferencesEntity = UserPreferencesEntity(
        themeMode: preferencesModel.themeMode, // Both use ThemeMode - perfect match
        notificationsEnabled: preferencesModel.notificationsEnabled,
        reminderSnoozeDuration: preferencesModel.reminderSnoozeDuration,
        language: _convertLanguageToString(preferencesModel.language), // Convert Language enum to String
        biometricAuthEnabled: preferencesModel.biometricAuthEnabled,
        dataBackupEnabled: preferencesModel.dataBackupEnabled,
        lastBackup: preferencesModel.lastBackup,
      );
      return Right(preferencesEntity);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get preferences: $e', code: 'preferences_load_failure'));
    }
  }

  @override
  Future<Either<Failure, void>> savePreferences(UserPreferencesEntity preferences) async {
    try {
      // Convert entity to model for storage with PERFECT type matching
      final preferencesModel = UserPreferencesModel(
        themeMode: preferences.themeMode, // Both use ThemeMode - perfect match
        language: _convertStringToLanguage(preferences.language), // Convert String to Language enum
        notificationsEnabled: preferences.notificationsEnabled,
        reminderSnoozeDuration: preferences.reminderSnoozeDuration,
        biometricAuthEnabled: preferences.biometricAuthEnabled,
        dataBackupEnabled: preferences.dataBackupEnabled,
        lastBackup: preferences.lastBackup,
        // Set default values for other required fields
        medicationRemindersEnabled: true,
        refillRemindersEnabled: true,
        reminderAdvanceTime: 15,
        temperatureUnit: TemperatureUnit.celsius,
        distanceUnit: DistanceUnit.metric,
        analyticsEnabled: true,
      );

      await localDataSource.savePreferences(preferencesModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save preferences: $e', code: 'preferences_save_failure'));
    }
  }

  @override
  Future<Either<Failure, UserPreferencesEntity>> updateThemeMode(ThemeMode themeMode) async {
    try {
      final currentResult = await getPreferences();
      return currentResult.fold(
            (failure) => Left(failure),
            (preferences) async {
          final updatedPreferences = preferences.copyWith(themeMode: themeMode);
          final saveResult = await savePreferences(updatedPreferences);
          return saveResult.fold(
                (failure) => Left(failure),
                (_) => Right(updatedPreferences),
          );
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update theme mode: $e', code: 'theme_update_failure'));
    }
  }

  @override
  Future<Either<Failure, UserPreferencesEntity>> updateNotifications(bool enabled) async {
    try {
      final currentResult = await getPreferences();
      return currentResult.fold(
            (failure) => Left(failure),
            (preferences) async {
          final updatedPreferences = preferences.copyWith(notificationsEnabled: enabled);
          final saveResult = await savePreferences(updatedPreferences);
          return saveResult.fold(
                (failure) => Left(failure),
                (_) => Right(updatedPreferences),
          );
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update notifications: $e', code: 'notifications_update_failure'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllData() async {
    try {
      await localDataSource.clearPreferences();
      // TODO: Clear other profile data if needed
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear all data: $e', code: 'data_clear_failure'));
    }
  }

  // Account Management
  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      // TODO: Implement account deletion logic
      await clearAllData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete account: $e', code: 'account_delete_failure'));
    }
  }

  @override
  Future<Either<Failure, void>> exportUserData() async {
    try {
      // TODO: Implement user data export logic
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to export user data: $e', code: 'data_export_failure'));
    }
  }

  // Helper methods for Language conversion between String and enum
  String _convertLanguageToString(Language language) {
    switch (language) {
      case Language.spanish:
        return 'spanish';
      case Language.french:
        return 'french';
      case Language.english:
      default:
        return 'english';
    }
  }

  Language _convertStringToLanguage(String languageString) {
    switch (languageString) {
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