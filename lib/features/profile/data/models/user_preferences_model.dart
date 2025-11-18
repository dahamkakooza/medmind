import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart'; // ADD THIS

// Remove ThemeMode enum since we're using Flutter's
enum Language { english, spanish, french }
enum TemperatureUnit { celsius, fahrenheit }
enum DistanceUnit { metric, imperial }

class UserPreferencesModel extends Equatable {
  final ThemeMode themeMode; // CHANGED TO FLUTTER THEMEMODE
  final bool notificationsEnabled;
  final bool medicationRemindersEnabled;
  final bool refillRemindersEnabled;
  final int reminderSnoozeDuration; // in minutes
  final int reminderAdvanceTime; // in minutes
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
    this.themeMode = ThemeMode.system, // CHANGED TO FLUTTER THEMEMODE
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
      themeMode: _parseThemeMode(json['themeMode']), // UPDATED
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
      'themeMode': _themeModeToString(themeMode), // UPDATED
      'notificationsEnabled': notificationsEnabled,
      'medicationRemindersEnabled': medicationRemindersEnabled,
      'refillRemindersEnabled': refillRemindersEnabled,
      'reminderSnoozeDuration': reminderSnoozeDuration,
      'reminderAdvanceTime': reminderAdvanceTime,
      'language': language.name,
      'temperatureUnit': temperatureUnit.name,
      'distanceUnit': distanceUnit.name,
      'biometricAuthEnabled': biometricAuthEnabled,
      'dataBackupEnabled': dataBackupEnabled,
      'analyticsEnabled': analyticsEnabled,
      'lastBackup': lastBackup?.toIso8601String(),
      'lastSync': lastSync?.toIso8601String(),
      'customSettings': customSettings,
    };
  }

  UserPreferencesModel copyWith({
    ThemeMode? themeMode, // CHANGED TO FLUTTER THEMEMODE
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
      default:
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

  static TemperatureUnit _parseTemperatureUnit(String? unit) {
    switch (unit) {
      case 'fahrenheit':
        return TemperatureUnit.fahrenheit;
      case 'celsius':
      default:
        return TemperatureUnit.celsius;
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

  // Convenience getters
  bool get isDarkMode => themeMode == ThemeMode.dark;
  bool get isLightMode => themeMode == ThemeMode.light;
  bool get isSystemTheme => themeMode == ThemeMode.system;

  String get languageCode {
    switch (language) {
      case Language.spanish:
        return 'es';
      case Language.french:
        return 'fr';
      case Language.english:
      default:
        return 'en';
    }
  }

  String get temperatureSymbol {
    switch (temperatureUnit) {
      case TemperatureUnit.fahrenheit:
        return '°F';
      case TemperatureUnit.celsius:
      default:
        return '°C';
    }
  }

  String get distanceSymbol {
    switch (distanceUnit) {
      case DistanceUnit.imperial:
        return 'mi';
      case DistanceUnit.metric:
      default:
        return 'km';
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
        'notificationsEnabled: $notificationsEnabled, '
        'medicationRemindersEnabled: $medicationRemindersEnabled, '
        'refillRemindersEnabled: $refillRemindersEnabled, '
        'reminderSnoozeDuration: $reminderSnoozeDuration, '
        'reminderAdvanceTime: $reminderAdvanceTime, '
        'language: $language, '
        'temperatureUnit: $temperatureUnit, '
        'distanceUnit: $distanceUnit, '
        'biometricAuthEnabled: $biometricAuthEnabled, '
        'dataBackupEnabled: $dataBackupEnabled, '
        'analyticsEnabled: $analyticsEnabled, '
        'lastBackup: $lastBackup, '
        'lastSync: $lastSync'
        ')';
  }
}

// Extension methods for easy conversion
extension UserPreferencesModelExtensions on UserPreferencesModel {
  // Convert to entity (if using separate entity classes)
  Map<String, dynamic> toEntityMap() {
    return toJson();
  }

  // Check if preferences have been modified from defaults
  bool get isModified {
    return this != UserPreferencesModel.defaultPreferences;
  }

  // Get modified fields compared to another preferences model
  Map<String, dynamic> getModifiedFields(UserPreferencesModel other) {
    final modifiedFields = <String, dynamic>{};

    if (themeMode != other.themeMode) {
      modifiedFields['themeMode'] = UserPreferencesModel._themeModeToString(themeMode);
    }
    if (notificationsEnabled != other.notificationsEnabled) {
      modifiedFields['notificationsEnabled'] = notificationsEnabled;
    }
    if (medicationRemindersEnabled != other.medicationRemindersEnabled) {
      modifiedFields['medicationRemindersEnabled'] = medicationRemindersEnabled;
    }
    if (refillRemindersEnabled != other.refillRemindersEnabled) {
      modifiedFields['refillRemindersEnabled'] = refillRemindersEnabled;
    }
    if (reminderSnoozeDuration != other.reminderSnoozeDuration) {
      modifiedFields['reminderSnoozeDuration'] = reminderSnoozeDuration;
    }
    if (reminderAdvanceTime != other.reminderAdvanceTime) {
      modifiedFields['reminderAdvanceTime'] = reminderAdvanceTime;
    }
    if (language != other.language) {
      modifiedFields['language'] = language.name;
    }
    if (temperatureUnit != other.temperatureUnit) {
      modifiedFields['temperatureUnit'] = temperatureUnit.name;
    }
    if (distanceUnit != other.distanceUnit) {
      modifiedFields['distanceUnit'] = distanceUnit.name;
    }
    if (biometricAuthEnabled != other.biometricAuthEnabled) {
      modifiedFields['biometricAuthEnabled'] = biometricAuthEnabled;
    }
    if (dataBackupEnabled != other.dataBackupEnabled) {
      modifiedFields['dataBackupEnabled'] = dataBackupEnabled;
    }
    if (analyticsEnabled != other.analyticsEnabled) {
      modifiedFields['analyticsEnabled'] = analyticsEnabled;
    }

    return modifiedFields;
  }
}

// Helper class for preference updates
class PreferenceUpdate {
  final String key;
  final dynamic value;
  final DateTime timestamp;

  PreferenceUpdate({
    required this.key,
    required this.value,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory PreferenceUpdate.fromJson(Map<String, dynamic> json) {
    return PreferenceUpdate(
      key: json['key'] as String,
      value: json['value'],
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
