import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class UserPreferencesEntity extends Equatable {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final int reminderSnoozeDuration;
  final String language; // CHANGED FROM ENUM TO STRING
  final bool biometricAuthEnabled;
  final bool dataBackupEnabled;
  final DateTime? lastBackup;

  const UserPreferencesEntity({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.reminderSnoozeDuration = 5,
    this.language = 'english', // CHANGED FROM ENUM TO STRING
    this.biometricAuthEnabled = false,
    this.dataBackupEnabled = true,
    this.lastBackup,
  });

  @override
  List<Object?> get props => [
    themeMode,
    notificationsEnabled,
    reminderSnoozeDuration,
    language,
    biometricAuthEnabled,
    dataBackupEnabled,
    lastBackup,
  ];

  UserPreferencesEntity copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    int? reminderSnoozeDuration,
    String? language, // CHANGED FROM ENUM TO STRING
    bool? biometricAuthEnabled,
    bool? dataBackupEnabled,
    DateTime? lastBackup,
  }) {
    return UserPreferencesEntity(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderSnoozeDuration: reminderSnoozeDuration ?? this.reminderSnoozeDuration,
      language: language ?? this.language,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      dataBackupEnabled: dataBackupEnabled ?? this.dataBackupEnabled,
      lastBackup: lastBackup ?? this.lastBackup,
    );
  }

  static const defaultPreferences = UserPreferencesEntity();
}