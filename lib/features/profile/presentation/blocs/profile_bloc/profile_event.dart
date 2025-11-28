// import 'package:equatable/equatable.dart';
// import 'package:flutter/material.dart'; // ADD THIS
//
// // Corrected import paths
// import '../../../domain/entities/user_preferences_entity.dart';
//
// abstract class ProfileEvent extends Equatable {
//   const ProfileEvent();
//
//   @override
//   List<Object> get props => [];
// }
//
// // Load Preferences
// class LoadPreferences extends ProfileEvent {}
//
// // Update Preferences
// class UpdatePreferences extends ProfileEvent {
//   final UserPreferencesEntity preferences;
//
//   const UpdatePreferences({required this.preferences});
//
//   @override
//   List<Object> get props => [preferences];
// }
//
// // Update Individual Settings
// class UpdateThemeModeEvent extends ProfileEvent {
//   final ThemeMode themeMode; // CHANGED TO FLUTTER THEMEMODE
//
//   const UpdateThemeModeEvent({required this.themeMode});
//
//   @override
//   List<Object> get props => [themeMode];
// }
//
// class UpdateNotificationsEnabled extends ProfileEvent {
//   final bool enabled;
//
//   const UpdateNotificationsEnabled({required this.enabled});
//
//   @override
//   List<Object> get props => [enabled];
// }
//
// class UpdateReminderSnoozeDuration extends ProfileEvent {
//   final int duration; // in minutes
//
//   const UpdateReminderSnoozeDuration({required this.duration});
//
//   @override
//   List<Object> get props => [duration];
// }
//
// class UpdateLanguage extends ProfileEvent {
//   final String language; // CHANGED TO STRING
//
//   const UpdateLanguage({required this.language});
//
//   @override
//   List<Object> get props => [language];
// }
//
// class UpdateBiometricAuth extends ProfileEvent {
//   final bool enabled;
//
//   const UpdateBiometricAuth({required this.enabled});
//
//   @override
//   List<Object> get props => [enabled];
// }
//
// class UpdateDataBackup extends ProfileEvent {
//   final bool enabled;
//
//   const UpdateDataBackup({required this.enabled});
//
//   @override
//   List<Object> get props => [enabled];
// }
//
// // Reset to Defaults
// class ResetToDefaults extends ProfileEvent {}
//
// // Export Data
// class ExportUserData extends ProfileEvent {}
//
// // Clear All Data
// class ClearAllData extends ProfileEvent {}
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/user_preferences_entity.dart';

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
class UpdateThemeModeEvent extends ProfileEvent {
  final ThemeMode themeMode;

  const UpdateThemeModeEvent({required this.themeMode});

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
  final int duration;

  const UpdateReminderSnoozeDuration({required this.duration});

  @override
  List<Object> get props => [duration];
}

class UpdateLanguage extends ProfileEvent {
  final String language;

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

// NEW: Password Change Events
class ChangePasswordRequested extends ProfileEvent {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object> get props => [currentPassword, newPassword, confirmPassword];
}

// NEW: Two-Factor Authentication Events
class TwoFactorAuthRequested extends ProfileEvent {
  final bool enable;
  final String? phoneNumber;

  const TwoFactorAuthRequested({
    required this.enable,
    this.phoneNumber,
  });

  @override
  List<Object> get props => [enable, if (phoneNumber != null) phoneNumber!];
}

class VerifyTwoFactorCode extends ProfileEvent {
  final String code;
  final String verificationId;

  const VerifyTwoFactorCode({
    required this.code,
    required this.verificationId,
  });

  @override
  List<Object> get props => [code, verificationId];
}