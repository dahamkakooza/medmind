// import 'package:equatable/equatable.dart';
//
// abstract class Failure extends Equatable {
//   final String message;
//   final String code;
//
//   const Failure({required this.message, required this.code});
//
//   @override
//   List<Object> get props => [message, code];
// }
//
// // Network Failures
// class NetworkFailure extends Failure {
//   const NetworkFailure({String? message, String? code})
//       : super(
//           message: message ?? 'Network connection failed',
//           code: code ?? 'network_failure',
//         );
// }
//
// class ServerFailure extends Failure {
//   const ServerFailure({String? message, String? code})
//       : super(
//           message: message ?? 'Server error occurred',
//           code: code ?? 'server_failure',
//         );
// }
//
// // Authentication Failures
// class AuthenticationFailure extends Failure {
//   const AuthenticationFailure({String? message, String? code})
//       : super(
//           message: message ?? 'Authentication failed',
//           code: code ?? 'auth_failure',
//         );
// }
//
// class EmailAlreadyInUseFailure extends Failure {
//   const EmailAlreadyInUseFailure()
//       : super(
//           message: 'Email is already in use',
//           code: 'email_in_use',
//         );
// }
//
// class InvalidCredentialsFailure extends Failure {
//   const InvalidCredentialsFailure()
//       : super(
//           message: 'Invalid email or password',
//           code: 'invalid_credentials',
//         );
// }
//
// class UserNotFoundFailure extends Failure {
//   const UserNotFoundFailure()
//       : super(
//           message: 'User not found',
//           code: 'user_not_found',
//         );
// }
//
// // Data Failures
// class DataFailure extends Failure {
//   const DataFailure({String? message, String? code})
//       : super(
//           message: message ?? 'Data operation failed',
//           code: code ?? 'data_failure',
//         );
// }
//
// class CacheFailure extends Failure {
//   const CacheFailure({String? message, String? code})
//       : super(
//           message: message ?? 'Cache operation failed',
//           code: code ?? 'cache_failure',
//         );
// }
//
// // Permission Failures
// class PermissionFailure extends Failure {
//   const PermissionFailure({String? message, String? code})
//       : super(
//           message: message ?? 'Permission denied',
//           code: code ?? 'permission_failure',
//         );
// }
//
// class CameraPermissionFailure extends Failure {
//   const CameraPermissionFailure()
//       : super(
//           message: 'Camera permission is required',
//           code: 'camera_permission_denied',
//         );
// }
//
// // Validation Failures
// class ValidationFailure extends Failure {
//   const ValidationFailure({String? message, String? code})
//       : super(
//           message: message ?? 'Validation failed',
//           code: code ?? 'validation_failure',
//         );
// }
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String code;

  const Failure({required this.message, required this.code});

  @override
  List<Object> get props => [message, code];
}

// Network Failures
class NetworkFailure extends Failure {
  const NetworkFailure({String? message, String? code})
      : super(
    message: message ?? 'Network connection failed',
    code: code ?? 'network_failure',
  );
}

class ServerFailure extends Failure {
  const ServerFailure({String? message, String? code})
      : super(
    message: message ?? 'Server error occurred',
    code: code ?? 'server_failure',
  );
}

// Authentication Failures
class AuthFailure extends Failure {
  const AuthFailure({String? message, String? code})
      : super(
    message: message ?? 'Authentication failed',
    code: code ?? 'auth_failure',
  );
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({String? message, String? code})
      : super(
    message: message ?? 'Authentication failed',
    code: code ?? 'auth_failure',
  );
}

class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure()
      : super(
    message: 'Email is already in use',
    code: 'email_in_use',
  );
}

class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure()
      : super(
    message: 'Invalid email or password',
    code: 'invalid_credentials',
  );
}

class UserNotFoundFailure extends Failure {
  const UserNotFoundFailure()
      : super(
    message: 'User not found',
    code: 'user_not_found',
  );
}

// Data Failures
class DataFailure extends Failure {
  const DataFailure({String? message, String? code})
      : super(
    message: message ?? 'Data operation failed',
    code: code ?? 'data_failure',
  );
}

class CacheFailure extends Failure {
  const CacheFailure({String? message, String? code})
      : super(
    message: message ?? 'Cache operation failed',
    code: code ?? 'cache_failure',
  );
}

// Permission Failures
class PermissionFailure extends Failure {
  const PermissionFailure({String? message, String? code})
      : super(
    message: message ?? 'Permission denied',
    code: code ?? 'permission_failure',
  );
}

class CameraPermissionFailure extends Failure {
  const CameraPermissionFailure()
      : super(
    message: 'Camera permission is required',
    code: 'camera_permission_denied',
  );
}

// Validation Failures
class ValidationFailure extends Failure {
  const ValidationFailure({String? message, String? code})
      : super(
    message: message ?? 'Validation failed',
    code: code ?? 'validation_failure',
  );
}

// Timeout Failures
class TimeoutFailure extends Failure {
  const TimeoutFailure({String? message, String? code})
      : super(
    message: message ?? 'Request timeout',
    code: code ?? 'timeout_failure',
  );
}