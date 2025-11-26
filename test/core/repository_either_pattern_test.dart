import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medmind/core/errors/failures.dart';
import 'package:medmind/core/errors/exceptions.dart';
import 'package:medmind/features/medication/data/repositories/medication_repository_impl.dart';
import 'package:medmind/features/medication/data/datasources/medication_remote_data_source.dart';
import 'package:medmind/features/medication/data/models/medication_model.dart';
import '../utils/mock_data_generators.dart';

// Generate mocks for FirebaseAuth and User
@GenerateMocks([FirebaseAuth, User, MedicationRemoteDataSource])
import 'repository_either_pattern_test.mocks.dart';

/// Property tests for repository Either pattern
///
/// **Feature: system-verification, Property 24: Successful operations return Right(data)**
/// **Validates: Requirements 7.2**
///
/// **Feature: system-verification, Property 25: Failed operations return Left(failure)**
/// **Validates: Requirements 7.3**
///
/// **Feature: system-verification, Property 26: Network errors return NetworkFailure**
/// **Validates: Requirements 7.4**
///
/// **Feature: system-verification, Property 27: Exceptions convert to Failures**
/// **Validates: Requirements 7.5**
void main() {
  group('Repository Either Pattern Properties', () {
    test('Property 24: Successful operations return Right(data)', () async {
      // Test getMedications success
      for (int i = 0; i < 10; i++) {
        final mockDataSource = MockMedicationRemoteDataSource();
        final mockAuth = MockFirebaseAuth();
        final mockUser = MockUser();

        final medication = MockMedicationGenerator.generate();
        final model = MedicationModel.fromEntity(medication);

        // Setup mocks
        when(mockUser.uid).thenReturn('test-user-id');
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(
          mockDataSource.getMedications('test-user-id'),
        ).thenAnswer((_) async => [model]);

        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final result = await repository.getMedications();
        expect(result.isRight(), isTrue);
      }
    });

    test('Property 25: Failed operations return Left(failure)', () async {
      // Test getMedications failure
      for (int i = 0; i < 10; i++) {
        final mockDataSource = MockMedicationRemoteDataSource();
        final mockAuth = MockFirebaseAuth();
        final mockUser = MockUser();

        // Setup mocks
        when(mockUser.uid).thenReturn('test-user-id');
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(
          mockDataSource.getMedications('test-user-id'),
        ).thenThrow(ServerException(message: 'Server error'));

        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final result = await repository.getMedications();
        expect(result.isLeft(), isTrue);
      }
    });

    test('Property 26: Network errors return NetworkFailure', () async {
      // Test network exception conversion
      for (int i = 0; i < 10; i++) {
        final mockDataSource = MockMedicationRemoteDataSource();
        final mockAuth = MockFirebaseAuth();
        final mockUser = MockUser();

        // Setup mocks
        when(mockUser.uid).thenReturn('test-user-id');
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(
          mockDataSource.getMedications('test-user-id'),
        ).thenThrow(NetworkException(message: 'No internet'));

        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final result = await repository.getMedications();

        result.fold(
          (failure) => expect(failure, isA<NetworkFailure>()),
          (_) => fail('Should return failure'),
        );
      }
    });

    test('Property 27: Exceptions convert to Failures', () async {
      // Test ServerException -> ServerFailure
      for (int i = 0; i < 5; i++) {
        final mockDataSource = MockMedicationRemoteDataSource();
        final mockAuth = MockFirebaseAuth();
        final mockUser = MockUser();

        when(mockUser.uid).thenReturn('test-user-id');
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(
          mockDataSource.getMedications('test-user-id'),
        ).thenThrow(ServerException(message: 'Server error'));

        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final result = await repository.getMedications();
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Should return failure'),
        );
      }

      // Test AuthenticationException -> AuthenticationFailure
      for (int i = 0; i < 5; i++) {
        final mockDataSource = MockMedicationRemoteDataSource();
        final mockAuth = MockFirebaseAuth();
        final mockUser = MockUser();

        when(mockUser.uid).thenReturn('test-user-id');
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(
          mockDataSource.getMedications('test-user-id'),
        ).thenThrow(AuthenticationException(message: 'Not authenticated'));

        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final result = await repository.getMedications();
        result.fold(
          (failure) => expect(failure, isA<AuthenticationFailure>()),
          (_) => fail('Should return failure'),
        );
      }

      // Test PermissionException -> PermissionFailure
      for (int i = 0; i < 5; i++) {
        final mockDataSource = MockMedicationRemoteDataSource();
        final mockAuth = MockFirebaseAuth();
        final mockUser = MockUser();

        when(mockUser.uid).thenReturn('test-user-id');
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(
          mockDataSource.getMedications('test-user-id'),
        ).thenThrow(PermissionException(message: 'Permission denied'));

        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final result = await repository.getMedications();
        result.fold(
          (failure) => expect(failure, isA<PermissionFailure>()),
          (_) => fail('Should return failure'),
        );
      }

      // Test ValidationException -> ValidationFailure
      for (int i = 0; i < 5; i++) {
        final mockDataSource = MockMedicationRemoteDataSource();
        final mockAuth = MockFirebaseAuth();
        final mockUser = MockUser();

        when(mockUser.uid).thenReturn('test-user-id');
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(
          mockDataSource.getMedications('test-user-id'),
        ).thenThrow(ValidationException(message: 'Invalid data'));

        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final result = await repository.getMedications();
        result.fold(
          (failure) => expect(failure, isA<ValidationFailure>()),
          (_) => fail('Should return failure'),
        );
      }

      // Test generic Exception -> DataFailure
      for (int i = 0; i < 5; i++) {
        final mockDataSource = MockMedicationRemoteDataSource();
        final mockAuth = MockFirebaseAuth();
        final mockUser = MockUser();

        when(mockUser.uid).thenReturn('test-user-id');
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(
          mockDataSource.getMedications('test-user-id'),
        ).thenThrow(Exception('Unexpected error'));

        final repository = MedicationRepositoryImpl(
          remoteDataSource: mockDataSource,
          firebaseAuth: mockAuth,
        );

        final result = await repository.getMedications();
        result.fold(
          (failure) => expect(failure, isA<DataFailure>()),
          (_) => fail('Should return failure'),
        );
      }
    });
  });
}
