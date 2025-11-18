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
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException({String? message, String? code, StackTrace? stackTrace})
      : super(
          message: message ?? 'Network connection failed',
          code: code ?? 'network_exception',
          stackTrace: stackTrace,
        );
}

class ServerException extends AppException {
  final int statusCode;

  const ServerException({
    String? message,
    String? code,
    this.statusCode = 500,
    StackTrace? stackTrace,
  }) : super(
          message: message ?? 'Server error occurred',
          code: code ?? 'server_exception',
          stackTrace: stackTrace,
        );
}

class AuthenticationException extends AppException {
  const AuthenticationException({String? message, String? code, StackTrace? stackTrace})
      : super(
          message: message ?? 'Authentication failed',
          code: code ?? 'auth_exception',
          stackTrace: stackTrace,
        );
}

class CacheException extends AppException {
  const CacheException({String? message, String? code, StackTrace? stackTrace})
      : super(
          message: message ?? 'Cache operation failed',
          code: code ?? 'cache_exception',
          stackTrace: stackTrace,
        );
}

class PermissionException extends AppException {
  const PermissionException({String? message, String? code, StackTrace? stackTrace})
      : super(
          message: message ?? 'Permission denied',
          code: code ?? 'permission_exception',
          stackTrace: stackTrace,
        );
}