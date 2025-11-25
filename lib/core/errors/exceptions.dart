class AppException implements Exception {
  final String message;
  final String code;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    required this.code,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message (code: $code)';
}

class NetworkException extends AppException {
  const NetworkException({String? message, String? code, super.stackTrace})
    : super(
        message: message ?? 'Network connection failed',
        code: code ?? 'network_exception',
      );
}

class ServerException extends AppException {
  final int statusCode;

  const ServerException({
    String? message,
    String? code,
    this.statusCode = 500,
    super.stackTrace,
  }) : super(
         message: message ?? 'Server error occurred',
         code: code ?? 'server_exception',
       );
}

class AuthenticationException extends AppException {
  const AuthenticationException({
    String? message,
    String? code,
    super.stackTrace,
  }) : super(
         message: message ?? 'Authentication failed',
         code: code ?? 'auth_exception',
       );
}

class CacheException extends AppException {
  const CacheException({String? message, String? code, super.stackTrace})
    : super(
        message: message ?? 'Cache operation failed',
        code: code ?? 'cache_exception',
      );
}

class PermissionException extends AppException {
  const PermissionException({String? message, String? code, super.stackTrace})
    : super(
        message: message ?? 'Permission denied',
        code: code ?? 'permission_exception',
      );
}

class FirestoreException extends AppException {
  final String? originalCode;

  const FirestoreException({
    String? message,
    String? code,
    this.originalCode,
    super.stackTrace,
  }) : super(
         message: message ?? 'Firestore operation failed',
         code: code ?? 'firestore_exception',
       );
}

class NotFoundException extends AppException {
  const NotFoundException({String? message, String? code, super.stackTrace})
    : super(
        message: message ?? 'Resource not found',
        code: code ?? 'not_found_exception',
      );
}

class DataException extends AppException {
  const DataException({
    required super.message,
    required super.code,
    super.stackTrace,
  });
}

class ValidationException extends AppException {
  const ValidationException({String? message, String? code, super.stackTrace})
    : super(
        message: message ?? 'Validation error occurred',
        code: code ?? 'validation_exception',
      );
}
