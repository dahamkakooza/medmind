import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum Language { english, spanish, french }
enum TemperatureUnit { celsius, fahrenheit }
enum DistanceUnit { metric, imperial }

class UserPreferencesModel extends Equatable {
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool medicationRemindersEnabled;
  final bool refillRemindersEnabled;
  final int reminderSnoozeDuration;
  final int reminderAdvanceTime;
  final Language language;
  final TemperatureUnit temperatureUnit;
  final DistanceUnit distanceUnit;
  final bool biometricAuthEnabled;
  final bool dataBackupEnabled;
  final bool analyticsEnabled;
  final DateTime? lastBackup;
  final DateTime? lastSync;
  final Map<String, dynamic>? customSettings;

  const UserPreferencesModel({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.medicationRemindersEnabled = true,
    this.refillRemindersEnabled = true,
    this.reminderSnoozeDuration = 5,
    this.reminderAdvanceTime = 15,
    this.language = Language.english,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.distanceUnit = DistanceUnit.metric,
    this.biometricAuthEnabled = false,
    this.dataBackupEnabled = true,
    this.analyticsEnabled = true,
    this.lastBackup,
    this.lastSync,
    this.customSettings,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      themeMode: _parseThemeMode(json['themeMode']),
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      medicationRemindersEnabled: json['medicationRemindersEnabled'] as bool? ?? true,
      refillRemindersEnabled: json['refillRemindersEnabled'] as bool? ?? true,
      reminderSnoozeDuration: json['reminderSnoozeDuration'] as int? ?? 5,
      reminderAdvanceTime: json['reminderAdvanceTime'] as int? ?? 15,
      language: _parseLanguage(json['language']),
      temperatureUnit: _parseTemperatureUnit(json['temperatureUnit']),
      distanceUnit: _parseDistanceUnit(json['distanceUnit']),
      biometricAuthEnabled: json['biometricAuthEnabled'] as bool? ?? false,
      dataBackupEnabled: json['dataBackupEnabled'] as bool? ?? true,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
      lastBackup: json['lastBackup'] != null
          ? DateTime.parse(json['lastBackup'] as String)
          : null,
      lastSync: json['lastSync'] != null
          ? DateTime.parse(json['lastSync'] as String)
          : null,
      customSettings: json['customSettings'] != null
          ? Map<String, dynamic>.from(json['customSettings'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': _themeModeToString(themeMode),
      'notificationsEnabled': notificationsEnabled,
      'medicationRemindersEnabled': medicationRemindersEnabled,
      'refillRemindersEnabled': refillRemindersEnabled,
      'reminderSnoozeDuration': reminderSnoozeDuration,
      'reminderAdvanceTime': reminderAdvanceTime,
      'language': _languageToString(language),
      'temperatureUnit': _temperatureUnitToString(temperatureUnit),
      'distanceUnit': _distanceUnitToString(distanceUnit),
      'biometricAuthEnabled': biometricAuthEnabled,
      'dataBackupEnabled': dataBackupEnabled,
      'analyticsEnabled': analyticsEnabled,
      'lastBackup': lastBackup?.toIso8601String(),
      'lastSync': lastSync?.toIso8601String(),
      'customSettings': customSettings,
    };
  }

  UserPreferencesModel copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? medicationRemindersEnabled,
    bool? refillRemindersEnabled,
    int? reminderSnoozeDuration,
    int? reminderAdvanceTime,
    Language? language,
    TemperatureUnit? temperatureUnit,
    DistanceUnit? distanceUnit,
    bool? biometricAuthEnabled,
    bool? dataBackupEnabled,
    bool? analyticsEnabled,
    DateTime? lastBackup,
    DateTime? lastSync,
    Map<String, dynamic>? customSettings,
  }) {
    return UserPreferencesModel(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      medicationRemindersEnabled: medicationRemindersEnabled ?? this.medicationRemindersEnabled,
      refillRemindersEnabled: refillRemindersEnabled ?? this.refillRemindersEnabled,
      reminderSnoozeDuration: reminderSnoozeDuration ?? this.reminderSnoozeDuration,
      reminderAdvanceTime: reminderAdvanceTime ?? this.reminderAdvanceTime,
      language: language ?? this.language,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      biometricAuthEnabled: biometricAuthEnabled ?? this.biometricAuthEnabled,
      dataBackupEnabled: dataBackupEnabled ?? this.dataBackupEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      lastBackup: lastBackup ?? this.lastBackup,
      lastSync: lastSync ?? this.lastSync,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  // Helper methods for parsing enums from strings
  static ThemeMode _parseThemeMode(String? themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static Language _parseLanguage(String? language) {
    switch (language) {
      case 'spanish':
        return Language.spanish;
      case 'french':
        return Language.french;
      case 'english':
      default:
        return Language.english;
    }
  }

  static String _languageToString(Language language) {
    switch (language) {
      case Language.spanish:
        return 'spanish';
      case Language.french:
        return 'french';
      case Language.english:
        return 'english';
    }
  }

  static TemperatureUnit _parseTemperatureUnit(String? unit) {
    switch (unit) {
      case 'fahrenheit':
        return TemperatureUnit.fahrenheit;
      case 'celsius':
      default:
        return TemperatureUnit.celsius;
    }
  }

  static String _temperatureUnitToString(TemperatureUnit unit) {
    switch (unit) {
      case TemperatureUnit.fahrenheit:
        return 'fahrenheit';
      case TemperatureUnit.celsius:
        return 'celsius';
    }
  }

  static DistanceUnit _parseDistanceUnit(String? unit) {
    switch (unit) {
      case 'imperial':
        return DistanceUnit.imperial;
      case 'metric':
      default:
        return DistanceUnit.metric;
    }
  }

  static String _distanceUnitToString(DistanceUnit unit) {
    switch (unit) {
      case DistanceUnit.imperial:
        return 'imperial';
      case DistanceUnit.metric:
        return 'metric';
    }
  }

  // Convenience getters for UI
  String get themeDisplayName {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  String get languageDisplayName {
    switch (language) {
      case Language.spanish:
        return 'Español';
      case Language.french:
        return 'Français';
      case Language.english:
        return 'English';
    }
  }

  String get temperatureDisplayName {
    switch (temperatureUnit) {
      case TemperatureUnit.fahrenheit:
        return 'Fahrenheit (°F)';
      case TemperatureUnit.celsius:
        return 'Celsius (°C)';
    }
  }

  String get distanceDisplayName {
    switch (distanceUnit) {
      case DistanceUnit.imperial:
        return 'Imperial (miles)';
      case DistanceUnit.metric:
        return 'Metric (kilometers)';
    }
  }

  // Validation methods
  bool get hasValidSnoozeDuration => reminderSnoozeDuration >= 1 && reminderSnoozeDuration <= 60;
  bool get hasValidAdvanceTime => reminderAdvanceTime >= 1 && reminderAdvanceTime <= 120;

  // Factory method for default preferences
  static const UserPreferencesModel defaultPreferences = UserPreferencesModel();

  @override
  List<Object?> get props => [
    themeMode,
    notificationsEnabled,
    medicationRemindersEnabled,
    refillRemindersEnabled,
    reminderSnoozeDuration,
    reminderAdvanceTime,
    language,
    temperatureUnit,
    distanceUnit,
    biometricAuthEnabled,
    dataBackupEnabled,
    analyticsEnabled,
    lastBackup,
    lastSync,
    customSettings,
  ];

  @override
  String toString() {
    return 'UserPreferencesModel('
        'themeMode: $themeMode, '
        'language: $language, '
        'notifications: $notificationsEnabled, '
        'biometricAuth: $biometricAuthEnabled'
        ')';
  }
}

// Extension for additional functionality
extension UserPreferencesModelExtensions on UserPreferencesModel {
  // Convert language to locale code
  String get languageCode {
    switch (language) {
      case Language.spanish:
        return 'es';
      case Language.french:
        return 'fr';
      case Language.english:
        return 'en';
    }
  }

  // Check if preferences have been modified from defaults
  bool get isModified {
    return this != UserPreferencesModel.defaultPreferences;
  }

  // Get a simple map of display values for UI
  Map<String, String> get displayValues {
    return {
      'theme': themeDisplayName,
      'language': languageDisplayName,
      'temperature': temperatureDisplayName,
      'distance': distanceDisplayName,
      'snooze': '$reminderSnoozeDuration minutes',
      'advance': '$reminderAdvanceTime minutes',
    };
  }
}
