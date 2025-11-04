class AppConstants {
  // App Information
  static const String appName = 'MedMind';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String medicationsCollection = 'medications';
  static const String adherenceLogsCollection = 'adherence_logs';
  static const String pharmacyPricesCollection = 'pharmacy_prices';
  
  // Shared Preferences Keys
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'language';
  static const String notificationEnabledKey = 'notification_enabled';
  static const String reminderSnoozeKey = 'reminder_snooze_duration';
  static const String userPreferencesKey = 'user_preferences';
  
  // Animation Durations
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
  
  // API Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  
  // Validation Constants
  static const int minPasswordLength = 6;
  static const int maxEmailLength = 254;
  static const int maxMedicationNameLength = 100;
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';
}