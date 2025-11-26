class FirebaseConstants {
  // Firestore Collection Paths
  static const String usersPath = 'users';
  static const String medicationsPath = 'medications';
  static const String adherenceLogsPath = 'adherence_logs';
  static const String pharmacyPricesPath = 'pharmacy_prices';

  // Storage Paths
  static const String userAvatarsPath = 'user_avatars';
  static const String barcodeImagesPath = 'barcode_images';
  static const String medicationImagesPath = 'medication_images';

  // Field Names
  static const String userIdField = 'userId';
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String isActiveField = 'isActive';
  static const String barcodeDataField = 'barcodeData';
  static const String scheduledTimeField = 'scheduledTime';

  // Error Codes
  static const String emailAlreadyInUse = 'email-already-in-use';
  static const String userNotFound = 'user-not-found';
  static const String wrongPassword = 'wrong-password';
  static const String networkRequestFailed = 'network-request-failed';
}
