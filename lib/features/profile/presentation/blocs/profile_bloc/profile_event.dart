import 'package:equatable/equatable.dart';
import '../../domain/entities/user_preferences_entity.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

// Load Preferences
class LoadPreferences extends ProfileEvent {}

// Update Preferences
class UpdatePreferences extends ProfileEvent {
  final UserPreferencesEntity preferences;

  const UpdatePreferences({required this.preferences});

  @override
  List<Object> get props => [preferences];
}

// Update Individual Settings
class UpdateThemeMode extends ProfileEvent {
  final ThemeMode themeMode;

  const UpdateThemeMode({required this.themeMode});

  @override
  List<Object> get props => [themeMode];
}

class UpdateNotificationsEnabled extends ProfileEvent {
  final bool enabled;

  const UpdateNotificationsEnabled({required this.enabled});

  @override
  List<Object> get props => [enabled];
}

class UpdateReminderSnoozeDuration extends ProfileEvent {
  final int duration; // in minutes

  const UpdateReminderSnoozeDuration({required this.duration});

  @override
  List<Object> get props => [duration];
}

class UpdateLanguage extends ProfileEvent {
  final Language language;

  const UpdateLanguage({required this.language});

  @override
  List<Object> get props => [language];
}

class UpdateBiometricAuth extends ProfileEvent {
  final bool enabled;

  const UpdateBiometricAuth({required this.enabled});

  @override
  List<Object> get props => [enabled];
}

class UpdateDataBackup extends ProfileEvent {
  final bool enabled;

  const UpdateDataBackup({required this.enabled});

  @override
  List<Object> get props => [enabled];
}

// Reset to Defaults
class ResetToDefaults extends ProfileEvent {}

// Export Data
class ExportUserData extends ProfileEvent {}

// Clear All Data
class ClearAllData extends ProfileEvent {}
