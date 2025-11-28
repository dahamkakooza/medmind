import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/user_preferences_entity.dart';
import '../../../domain/usecases/get_user_preferences.dart';
import '../../../domain/usecases/save_user_preferences.dart';
import '../../../domain/usecases/update_theme_mode.dart';
import '../../../domain/usecases/update_notifications.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserPreferences getUserPreferences;
  final SaveUserPreferences saveUserPreferences;
  final UpdateThemeMode updateThemeMode;
  final UpdateNotifications updateNotifications;

  ProfileBloc({
    required this.getUserPreferences,
    required this.saveUserPreferences,
    required this.updateThemeMode,
    required this.updateNotifications,
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
    final result = await updateNotifications(event.enabled as UpdateNotificationsParams);
    result.fold(
          (failure) => emit(PreferencesSaveError(message: failure.message)),
          (preferences) => emit(PreferencesUpdated(preferences: preferences)),
    );
  }

  void _onUpdateReminderSnoozeDuration(UpdateReminderSnoozeDuration event, Emitter<ProfileState> emit) async {
    if (state is PreferencesLoaded) {
      final currentState = state as PreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        reminderSnoozeDuration: event.duration,
      );
      add(UpdatePreferences(preferences: updatedPreferences));
    }
  }

  void _onUpdateLanguage(UpdateLanguage event, Emitter<ProfileState> emit) async {
    if (state is PreferencesLoaded) {
      final currentState = state as PreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
        language: event.language, // NOW STRING
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
    }
  }

  void _onUpdateDataBackup(UpdateDataBackup event, Emitter<ProfileState> emit) async {
    if (state is PreferencesLoaded) {
      final currentState = state as PreferencesLoaded;
      final updatedPreferences = currentState.preferences.copyWith(
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
}