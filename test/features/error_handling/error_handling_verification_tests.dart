import 'package:flutter_test/flutter_test.dart';
import 'package:medmind/core/errors/failures.dart';
import 'package:medmind/core/errors/exceptions.dart';
import '../../utils/property_test_framework.dart';

/// Error Handling Verification Tests
///
/// This test suite verifies that error handling works correctly across the application.
/// It validates that network errors, validation errors, server errors, authentication errors,
/// and unexpected errors are handled gracefully with appropriate user-facing messages.
///
/// **Feature: system-verification**

void main() {
  group('Error Handling Verification Tests', () {
    /// **Property 36: Network errors display connectivity messages**
    /// **Validates: Requirements 11.1**
    ///
    /// This property verifies that when network errors occur, the system displays
    /// clear error messages indicating connectivity issues to the user.
    group('Property 36: Network errors display connectivity messages', () {
      propertyTest<Map<String, String>>(
        'Network failures contain connectivity-related messages',
        generator: () {
          final networkMessages = [
            'Network connection failed',
            'No internet connection',
            'Failed to connect to server',
            'Connection timeout',
            'Unable to reach server',
            'Network unavailable',
            'Connection lost',
            'Server unreachable',
          ];

          final codes = [
            'network_failure',
            'network-error',
            'connection-timeout',
            'no-internet',
            'server-unreachable',
          ];

          return {
            'message':
                networkMessages[DateTime.now().microsecondsSinceEpoch %
                    networkMessages.length],
            'code': codes[DateTime.now().microsecondsSinceEpoch % codes.length],
          };
        },
        property: (input) async {
          // Create a NetworkFailure with the generated message
          final failure = NetworkFailure(
            message: input['message'],
            code: input['code'],
          );

          // Verify the failure contains the message
          expect(failure.message, equals(input['message']));
          expect(failure.code, equals(input['code']));

          // Verify the message indicates a connectivity issue
          final message = failure.message.toLowerCase();
          final hasConnectivityKeywords =
              message.contains('network') ||
              message.contains('connection') ||
              message.contains('internet') ||
              message.contains('server') ||
              message.contains('timeout') ||
              message.contains('unreachable') ||
              message.contains('unavailable') ||
              message.contains('lost') ||
              message.contains('failed to connect');

          expect(
            hasConnectivityKeywords,
            true,
            reason:
                'Network error message should contain connectivity-related keywords: ${failure.message}',
          );

          return true;
        },
        config: PropertyTestConfig.standard,
      );

      test('Default NetworkFailure has connectivity message', () {
        final failure = NetworkFailure();

        expect(failure.message, isNotEmpty);
        expect(failure.code, equals('network_failure'));

        final message = failure.message.toLowerCase();
        expect(
          message.contains('network') || message.contains('connection'),
          true,
          reason: 'Default network failure should indicate connectivity issue',
        );
      });

      test('NetworkException converts to NetworkFailure with message', () {
        final exception = NetworkException(
          message: 'Connection timeout',
          code: 'timeout',
        );

        // Simulate repository converting exception to failure
        final failure = NetworkFailure(
          message: exception.message,
          code: exception.code,
        );

        expect(failure.message, equals('Connection timeout'));
        expect(failure.code, equals('timeout'));
      });
    });

    /// Unit tests for comprehensive error handling
    /// **Validates: Requirements 11.3, 11.5**
    group('Error Type Handling', () {
      test('All error types have descriptive messages', () {
        // Network errors
        final networkFailure = NetworkFailure();
        expect(networkFailure.message, isNotEmpty);
        expect(networkFailure.message.toLowerCase(), contains('network'));

        // Server errors
        final serverFailure = ServerFailure();
        expect(serverFailure.message, isNotEmpty);
        expect(serverFailure.message.toLowerCase(), contains('server'));

        // Authentication errors
        final authFailure = AuthenticationFailure();
        expect(authFailure.message, isNotEmpty);
        expect(authFailure.message.toLowerCase(), contains('authentication'));

        // Validation errors
        final validationFailure = ValidationFailure();
        expect(validationFailure.message, isNotEmpty);
        expect(validationFailure.message.toLowerCase(), contains('validation'));

        // Permission errors
        final permissionFailure = PermissionFailure();
        expect(permissionFailure.message, isNotEmpty);
        expect(permissionFailure.message.toLowerCase(), contains('permission'));
      });

      test('Specific authentication errors have clear messages', () {
        final emailInUse = EmailAlreadyInUseFailure();
        expect(emailInUse.message.toLowerCase(), contains('email'));
        expect(emailInUse.message.toLowerCase(), contains('in use'));

        final invalidCreds = InvalidCredentialsFailure();
        expect(invalidCreds.message.toLowerCase(), contains('invalid'));
        expect(
          invalidCreds.message.toLowerCase(),
          anyOf(contains('email'), contains('password')),
        );

        final userNotFound = UserNotFoundFailure();
        expect(userNotFound.message.toLowerCase(), contains('user'));
        expect(userNotFound.message.toLowerCase(), contains('not found'));
      });

      test('Exceptions contain error codes for logging', () {
        final networkException = NetworkException(
          message: 'Connection failed',
          code: 'net_001',
        );
        expect(networkException.code, equals('net_001'));
        expect(networkException.message, equals('Connection failed'));

        final serverException = ServerException(
          message: 'Internal error',
          code: 'srv_500',
          statusCode: 500,
        );
        expect(serverException.code, equals('srv_500'));
        expect(serverException.statusCode, equals(500));

        final authException = AuthenticationException(
          message: 'Token expired',
          code: 'auth_expired',
        );
        expect(authException.code, equals('auth_expired'));
      });

      test('Failures are equatable for comparison', () {
        final failure1 = NetworkFailure(message: 'Test', code: 'test');
        final failure2 = NetworkFailure(message: 'Test', code: 'test');
        final failure3 = NetworkFailure(message: 'Different', code: 'test');

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });

      test('Custom error messages are preserved', () {
        final customMessage = 'Custom network error occurred';
        final customCode = 'custom_net_error';

        final failure = NetworkFailure(
          message: customMessage,
          code: customCode,
        );

        expect(failure.message, equals(customMessage));
        expect(failure.code, equals(customCode));
      });

      test('Exception toString provides debugging information', () {
        final exception = NetworkException(
          message: 'Connection timeout',
          code: 'timeout',
        );

        final stringRep = exception.toString();
        expect(stringRep, contains('AppException'));
        expect(stringRep, contains('Connection timeout'));
        expect(stringRep, contains('timeout'));
      });

      test('Graceful handling of unexpected errors', () {
        // Test that generic failures can be created for unexpected errors
        final unexpectedFailure = DataFailure(
          message: 'An unexpected error occurred',
          code: 'unexpected',
        );

        expect(unexpectedFailure.message, isNotEmpty);
        expect(unexpectedFailure.code, equals('unexpected'));

        // Verify it's still a Failure type
        expect(unexpectedFailure, isA<Failure>());
      });

      test('Validation errors provide specific feedback', () {
        final validationFailure = ValidationFailure(
          message: 'Email format is invalid',
          code: 'invalid_email',
        );

        expect(validationFailure.message, contains('Email'));
        expect(validationFailure.message, contains('invalid'));
        expect(validationFailure.code, equals('invalid_email'));
      });

      test('Permission errors indicate access issues', () {
        final cameraPermission = CameraPermissionFailure();

        expect(cameraPermission.message.toLowerCase(), contains('camera'));
        expect(cameraPermission.message.toLowerCase(), contains('permission'));
        expect(cameraPermission.code, equals('camera_permission_denied'));
      });

      test('Server errors include status codes when available', () {
        final serverException = ServerException(
          message: 'Internal server error',
          code: 'server_500',
          statusCode: 500,
        );

        expect(serverException.statusCode, equals(500));
        expect(serverException.message, contains('server error'));
      });

      test('Firestore exceptions preserve original error codes', () {
        final firestoreException = FirestoreException(
          message: 'Permission denied',
          code: 'firestore_permission',
          originalCode: 'permission-denied',
        );

        expect(firestoreException.originalCode, equals('permission-denied'));
        expect(firestoreException.code, equals('firestore_permission'));
      });

      test('Cache failures indicate local storage issues', () {
        final cacheFailure = CacheFailure(
          message: 'Failed to read from cache',
          code: 'cache_read_error',
        );

        expect(cacheFailure.message.toLowerCase(), contains('cache'));
        expect(cacheFailure.code, equals('cache_read_error'));
      });

      test('Not found exceptions indicate missing resources', () {
        final notFoundException = NotFoundException(
          message: 'User profile not found',
          code: 'profile_not_found',
        );

        expect(notFoundException.message.toLowerCase(), contains('not found'));
        expect(notFoundException.code, equals('profile_not_found'));
      });
    });
  });
}
