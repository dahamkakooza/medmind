// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:dartz/dartz.dart';
// import 'package:flutter/material.dart';
// import 'package:medmind/features/profile/presentation/blocs/profile_bloc/profile_event.dart';
// import 'package:medmind/features/profile/presentation/blocs/profile_bloc/profile_state.dart';
// import '../../../../../core/errors/failures.dart';
// import '../../../../../core/usecases/usecase.dart';
// import '../../../domain/entities/user_preferences_entity.dart';
// import '../../../domain/usecases/get_user_preferences.dart';
// import '../../../domain/usecases/save_user_preferences.dart';
// import '../../../domain/usecases/update_theme_mode.dart';
// import '../../../domain/usecases/update_notifications.dart';
//
//
// class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
//   final GetUserPreferences getUserPreferences;
//   final SaveUserPreferences saveUserPreferences;
//   final UpdateThemeMode updateThemeMode;
//   final UpdateNotifications updateNotifications;
//
//   ProfileBloc({
//     required this.getUserPreferences,
//     required this.saveUserPreferences,
//     required this.updateThemeMode,
//     required this.updateNotifications,
//   }) : super(ProfileInitial()) {
//     on<LoadPreferences>(_onLoadPreferences);
//     on<UpdatePreferences>(_onUpdatePreferences);
//     on<UpdateThemeModeEvent>(_onUpdateThemeMode);
//     on<UpdateNotificationsEnabled>(_onUpdateNotificationsEnabled);
//     on<UpdateReminderSnoozeDuration>(_onUpdateReminderSnoozeDuration);
//     on<UpdateLanguage>(_onUpdateLanguage);
//     on<UpdateBiometricAuth>(_onUpdateBiometricAuth);
//     on<UpdateDataBackup>(_onUpdateDataBackup);
//     on<ResetToDefaults>(_onResetToDefaults);
//     on<ExportUserData>(_onExportUserData);
//     on<ClearAllData>(_onClearAllData);
//   }
//
//   void _onLoadPreferences(LoadPreferences event, Emitter<ProfileState> emit) async {
//     emit(PreferencesLoading());
//     final result = await getUserPreferences(NoParams());
//     result.fold(
//           (failure) => emit(PreferencesLoadError(message: failure.message)),
//           (preferences) => emit(PreferencesLoaded(preferences: preferences)),
//     );
//   }
//
//   void _onUpdatePreferences(UpdatePreferences event, Emitter<ProfileState> emit) async {
//     emit(PreferencesSaving());
//     final result = await saveUserPreferences(event.preferences);
//     result.fold(
//           (failure) => emit(PreferencesSaveError(message: failure.message)),
//           (_) => emit(PreferencesUpdated(preferences: event.preferences)),
//     );
//   }
//
//   void _onUpdateThemeMode(UpdateThemeModeEvent event, Emitter<ProfileState> emit) async {
//     final result = await updateThemeMode(event.themeMode);
//     result.fold(
//           (failure) => emit(PreferencesSaveError(message: failure.message)),
//           (preferences) => emit(PreferencesUpdated(preferences: preferences)),
//     );
//   }
//
//   void _onUpdateNotificationsEnabled(UpdateNotificationsEnabled event, Emitter<ProfileState> emit) async {
//     if (state is PreferencesLoaded) {
//       final currentState = state as PreferencesLoaded;
//       final updatedPreferences = currentState.preferences.copyWith(
//         notificationsEnabled: event.enabled,
//       );
//       add(UpdatePreferences(preferences: updatedPreferences));
//     } else {
//       // If no preferences loaded yet, create new ones
//       final updatedPreferences = UserPreferencesEntity.defaultPreferences.copyWith(
//         notificationsEnabled: event.enabled,
//       );
//       add(UpdatePreferences(preferences: updatedPreferences));
//     }
//   }
//
//   void _onUpdateReminderSnoozeDuration(UpdateReminderSnoozeDuration event, Emitter<ProfileState> emit) async {
//     if (state is PreferencesLoaded) {
//       final currentState = state as PreferencesLoaded;
//       final updatedPreferences = currentState.preferences.copyWith(
//         reminderSnoozeDuration: event.duration,
//       );
//       add(UpdatePreferences(preferences: updatedPreferences));
//     } else {
//       final updatedPreferences = UserPreferencesEntity.defaultPreferences.copyWith(
//         reminderSnoozeDuration: event.duration,
//       );
//       add(UpdatePreferences(preferences: updatedPreferences));
//     }
//   }
//
//   void _onUpdateLanguage(UpdateLanguage event, Emitter<ProfileState> emit) async {
//     if (state is PreferencesLoaded) {
//       final currentState = state as PreferencesLoaded;
//       final updatedPreferences = currentState.preferences.copyWith(
//         language: event.language,
//       );
//       add(UpdatePreferences(preferences: updatedPreferences));
//     } else {
//       final updatedPreferences = UserPreferencesEntity.defaultPreferences.copyWith(
//         language: event.language,
//       );
//       add(UpdatePreferences(preferences: updatedPreferences));
//     }
//   }
//
//   void _onUpdateBiometricAuth(UpdateBiometricAuth event, Emitter<ProfileState> emit) async {
//     if (state is PreferencesLoaded) {
//       final currentState = state as PreferencesLoaded;
//       final updatedPreferences = currentState.preferences.copyWith(
//         biometricAuthEnabled: event.enabled,
//       );
//       add(UpdatePreferences(preferences: updatedPreferences));
//     } else {
//       final updatedPreferences = UserPreferencesEntity.defaultPreferences.copyWith(
//         biometricAuthEnabled: event.enabled,
//       );
//       add(UpdatePreferences(preferences: updatedPreferences));
//     }
//   }
//
//   void _onUpdateDataBackup(UpdateDataBackup event, Emitter<ProfileState> emit) async {
//     if (state is PreferencesLoaded) {
//       final currentState = state as PreferencesLoaded;
//       final updatedPreferences = currentState.preferences.copyWith(
//         dataBackupEnabled: event.enabled,
//       );
//       add(UpdatePreferences(preferences: updatedPreferences));
//     } else {
//       final updatedPreferences = UserPreferencesEntity.defaultPreferences.copyWith(
//         dataBackupEnabled: event.enabled,
//       );
//       add(UpdatePreferences(preferences: updatedPreferences));
//     }
//   }
//
//   void _onResetToDefaults(ResetToDefaults event, Emitter<ProfileState> emit) async {
//     emit(PreferencesSaving());
//     final defaultPreferences = UserPreferencesEntity.defaultPreferences;
//     final result = await saveUserPreferences(defaultPreferences);
//     result.fold(
//           (failure) => emit(PreferencesSaveError(message: failure.message)),
//           (_) => emit(PreferencesReset(preferences: defaultPreferences)),
//     );
//   }
//
//   void _onExportUserData(ExportUserData event, Emitter<ProfileState> emit) async {
//     emit(DataExporting());
//     await Future.delayed(const Duration(seconds: 2));
//     const filePath = '/storage/emulated/0/Download/medmind_backup.json';
//     emit(DataExported(filePath: filePath));
//     if (state is PreferencesLoaded) {
//       final currentState = state as PreferencesLoaded;
//       emit(PreferencesLoaded(preferences: currentState.preferences));
//     }
//   }
//
//   void _onClearAllData(ClearAllData event, Emitter<ProfileState> emit) async {
//     emit(DataClearing());
//     await Future.delayed(const Duration(seconds: 1));
//     emit(DataCleared());
//     final defaultPreferences = UserPreferencesEntity.defaultPreferences;
//     emit(PreferencesReset(preferences: defaultPreferences));
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:medmind/features/profile/presentation/blocs/profile_bloc/profile_event.dart';
import 'package:medmind/features/profile/presentation/blocs/profile_bloc/profile_state.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/user_preferences_entity.dart';
import '../../../domain/usecases/get_user_preferences.dart';
import '../../../domain/usecases/save_user_preferences.dart';
import '../../../domain/usecases/update_theme_mode.dart';
import '../../../domain/usecases/update_notifications.dart';
// NEW: Import auth repository
import 'package:medmind/features/auth/domain/repositories/auth_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserPreferences getUserPreferences;
  final SaveUserPreferences saveUserPreferences;
  final UpdateThemeMode updateThemeMode;
  final UpdateNotifications updateNotifications;
  // NEW: Add auth repository
  final AuthRepository authRepository;

  ProfileBloc({
    required this.getUserPreferences,
    required this.saveUserPreferences,
    required this.updateThemeMode,
    required this.updateNotifications,
    required this.authRepository, // NEW
  }) : super(ProfileInitial()) {
    on<LoadPreferences>(_onLoadPreferences);
    on<UpdatePreferences>(_onUpdatePreferences);
    on<UpdateThemeModeEvent>(_onUpdateThemeMode);
    on<UpdateNotificationsEnabled>(_onUpdateNotificationsEnabled);
    on<UpdateReminderSnoozeDuration>(_onUpdateReminderSnoozeDuration);
    on<UpdateLanguage>(_onUpdateLanguage);
    on<UpdateBiometricAuth>(_onUpdateBiometricAuth);
    on<UpdateDataBackup>(_onUpdateDataBackup);
    on<ResetToDefaults>(_onResetToDefaults);
    on<ExportUserData>(_onExportUserData);
    on<ClearAllData>(_onClearAllData);
    // NEW: Add password change and 2FA events
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<TwoFactorAuthRequested>(_onTwoFactorAuthRequested);
    on<VerifyTwoFactorCode>(_onVerifyTwoFactorCode);
  }

  void _onLoadPreferences(LoadPreferences event, Emitter<ProfileState> emit) async {
    emit(PreferencesLoading());
    final result = await getUserPreferences(NoParams());
    result.fold(
          (failure) => emit(PreferencesLoadError(message: failure.message)),
          (preferences) => emit(PreferencesLoaded(preferences: preferences)),
    );
  }

  void _onUpdatePreferences(UpdatePreferences event, Emitter<ProfileState> emit) async {
    emit(PreferencesSaving());
    final result = await saveUserPreferences(event.preferences);
    result.fold(
          (failure) => emit(PreferencesSaveError(message: failure.message)),
          (_) => emit(PreferencesUpdated(preferences: event.preferences)),
    );
  }

  void _onUpdateThemeMode(UpdateThemeModeEvent event, Emitter<ProfileState> emit) async {
    final result = await updateThemeMode(event.themeMode);
    result.fold(
          (failure) => emit(PreferencesSaveError(message: failure.message)),
          (preferences) => emit(PreferencesUpdated(preferences: preferences)),
    );
  }

  void _onUpdateNotificationsEnabled(UpdateNotificationsEnabled event, Emitter<ProfileState> emit) async {
    if (state is PreferencesLoaded) {
      final currentState = state as PreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        notificationsEnabled: event.enabled,
      );
      add(UpdatePreferences(preferences: updatedPreferences));
    } else {
      final updatedPreferences = UserPreferencesEntity.defaultPreferences.copyWith(
        notificationsEnabled: event.enabled,
      );
      add(UpdatePreferences(preferences: updatedPreferences));
    }
  }

  void _onUpdateReminderSnoozeDuration(UpdateReminderSnoozeDuration event, Emitter<ProfileState> emit) async {
    if (state is PreferencesLoaded) {
      final currentState = state as PreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        reminderSnoozeDuration: event.duration,
      );
      add(UpdatePreferences(preferences: updatedPreferences));
    } else {
      final updatedPreferences = UserPreferencesEntity.defaultPreferences.copyWith(
        reminderSnoozeDuration: event.duration,
      );
      add(UpdatePreferences(preferences: updatedPreferences));
    }
  }

  void _onUpdateLanguage(UpdateLanguage event, Emitter<ProfileState> emit) async {
    if (state is PreferencesLoaded) {
      final currentState = state as PreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        language: event.language,
      );
      add(UpdatePreferences(preferences: updatedPreferences));
    } else {
      final updatedPreferences = UserPreferencesEntity.defaultPreferences.copyWith(
        language: event.language,
      );
      add(UpdatePreferences(preferences: updatedPreferences));
    }
  }

  void _onUpdateBiometricAuth(UpdateBiometricAuth event, Emitter<ProfileState> emit) async {
    if (state is PreferencesLoaded) {
      final currentState = state as PreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        biometricAuthEnabled: event.enabled,
      );
      add(UpdatePreferences(preferences: updatedPreferences));
    } else {
      final updatedPreferences = UserPreferencesEntity.defaultPreferences.copyWith(
        biometricAuthEnabled: event.enabled,
      );
      add(UpdatePreferences(preferences: updatedPreferences));
    }
  }

  void _onUpdateDataBackup(UpdateDataBackup event, Emitter<ProfileState> emit) async {
    if (state is PreferencesLoaded) {
      final currentState = state as PreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        dataBackupEnabled: event.enabled,
      );
      add(UpdatePreferences(preferences: updatedPreferences));
    } else {
      final updatedPreferences = UserPreferencesEntity.defaultPreferences.copyWith(
        dataBackupEnabled: event.enabled,
      );
      add(UpdatePreferences(preferences: updatedPreferences));
    }
  }

  void _onResetToDefaults(ResetToDefaults event, Emitter<ProfileState> emit) async {
    emit(PreferencesSaving());
    final defaultPreferences = UserPreferencesEntity.defaultPreferences;
    final result = await saveUserPreferences(defaultPreferences);
    result.fold(
          (failure) => emit(PreferencesSaveError(message: failure.message)),
          (_) => emit(PreferencesReset(preferences: defaultPreferences)),
    );
  }

  void _onExportUserData(ExportUserData event, Emitter<ProfileState> emit) async {
    emit(DataExporting());
    await Future.delayed(const Duration(seconds: 2));
    const filePath = '/storage/emulated/0/Download/medmind_backup.json';
    emit(DataExported(filePath: filePath));
    if (state is PreferencesLoaded) {
      final currentState = state as PreferencesLoaded;
      emit(PreferencesLoaded(preferences: currentState.preferences));
    }
  }

  void _onClearAllData(ClearAllData event, Emitter<ProfileState> emit) async {
    emit(DataClearing());
    await Future.delayed(const Duration(seconds: 1));
    emit(DataCleared());
    final defaultPreferences = UserPreferencesEntity.defaultPreferences;
    emit(PreferencesReset(preferences: defaultPreferences));
  }

  // NEW: Password Change Handler
  void _onChangePasswordRequested(ChangePasswordRequested event, Emitter<ProfileState> emit) async {
    emit(PasswordChanging());

    try {
      // Validate passwords match
      if (event.newPassword != event.confirmPassword) {
        emit(PasswordChangeError(message: 'New passwords do not match'));
        return;
      }

      // Validate password strength
      if (event.newPassword.length < 6) {
        emit(PasswordChangeError(message: 'Password must be at least 6 characters long'));
        return;
      }

      // Call auth repository to change password
      final result = await authRepository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
      );

      result.fold(
            (failure) => emit(PasswordChangeError(message: failure.message)),
            (_) {
          emit(PasswordChangeSuccess(message: 'Password changed successfully'));
          // Return to loaded state after delay
          Future.delayed(const Duration(seconds: 2), () {
            if (state is PasswordChangeSuccess) {
              add(LoadPreferences());
            }
          });
        },
      );
    } catch (e) {
      emit(PasswordChangeError(message: 'Failed to change password: $e'));
    }
  }

  // NEW: Two-Factor Authentication Handler
  void _onTwoFactorAuthRequested(TwoFactorAuthRequested event, Emitter<ProfileState> emit) async {
    emit(TwoFactorLoading());

    try {
      if (event.enable) {
        // Validate phone number
        if (event.phoneNumber == null || event.phoneNumber!.isEmpty) {
          emit(TwoFactorError(message: 'Phone number is required'));
          return;
        }

        // Validate phone number format
        if (!_isValidPhoneNumber(event.phoneNumber!)) {
          emit(TwoFactorError(message: 'Please enter a valid phone number'));
          return;
        }

        // Call auth repository to enable 2FA
        final result = await authRepository.enableTwoFactorAuth(event.phoneNumber!);

        result.fold(
              (failure) => emit(TwoFactorError(message: failure.message)),
              (verificationId) {
            emit(TwoFactorVerificationRequired(
              verificationId: verificationId,
              phoneNumber: event.phoneNumber!,
            ));
          },
        );
      } else {
        // Disable 2FA
        await Future.delayed(const Duration(seconds: 1)); // Simulate API call
        emit(TwoFactorSuccess(message: 'Two-factor authentication disabled'));

        // Return to loaded state
        Future.delayed(const Duration(seconds: 1), () {
          if (state is TwoFactorSuccess) {
            add(LoadPreferences());
          }
        });
      }
    } catch (e) {
      emit(TwoFactorError(message: 'Failed to update two-factor authentication: $e'));
    }
  }

  // NEW: Two-Factor Verification Handler
  void _onVerifyTwoFactorCode(VerifyTwoFactorCode event, Emitter<ProfileState> emit) async {
    emit(TwoFactorLoading());

    try {
      // Validate code
      if (event.code.isEmpty || event.code.length != 6) {
        emit(TwoFactorError(message: 'Please enter a valid 6-digit code'));
        return;
      }

      // Simulate verification (in production, verify with your 2FA service)
      await Future.delayed(const Duration(seconds: 2));

      // Check if code is valid (in production, this would be actual verification)
      if (event.code == '123456') { // Simple demo validation
        emit(TwoFactorSuccess(message: 'Two-factor authentication enabled successfully'));

        // Return to loaded state
        Future.delayed(const Duration(seconds: 1), () {
          if (state is TwoFactorSuccess) {
            add(LoadPreferences());
          }
        });
      } else {
        emit(TwoFactorError(message: 'Invalid verification code'));
      }
    } catch (e) {
      emit(TwoFactorError(message: 'Verification failed: $e'));
    }
  }

  // Helper method to validate phone number
  bool _isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phoneNumber);
  }
}