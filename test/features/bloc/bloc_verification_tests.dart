import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:medmind/features/auth/presentation/blocs/auth_bloc.dart';
import 'package:medmind/features/auth/presentation/blocs/auth_event.dart';
import 'package:medmind/features/auth/presentation/blocs/auth_state.dart';
import 'package:medmind/features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:medmind/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:medmind/features/auth/domain/usecases/sign_up.dart';
import 'package:medmind/features/auth/domain/usecases/sign_out.dart';
import 'package:medmind/features/medication/presentation/blocs/medication_bloc/medication_bloc.dart';
import 'package:medmind/features/medication/presentation/blocs/medication_bloc/medication_event.dart';
import 'package:medmind/features/medication/presentation/blocs/medication_bloc/medication_state.dart';
import 'package:medmind/features/medication/domain/usecases/get_medications.dart';
import 'package:medmind/features/medication/domain/usecases/add_medication.dart';
import 'package:medmind/features/medication/domain/usecases/update_medication.dart';
import 'package:medmind/features/medication/domain/usecases/delete_medication.dart';
import 'package:medmind/features/dashboard/presentation/blocs/dashboard_bloc/dashboard_bloc.dart';
import 'package:medmind/features/dashboard/presentation/blocs/dashboard_bloc/dashboard_event.dart';
import 'package:medmind/features/dashboard/presentation/blocs/dashboard_bloc/dashboard_state.dart';
import 'package:medmind/features/dashboard/domain/usecases/get_today_medications.dart';
import 'package:medmind/features/dashboard/domain/usecases/get_adherence_stats.dart';
import 'package:medmind/features/dashboard/domain/usecases/log_medication_taken.dart';
import 'package:medmind/core/errors/failures.dart';
import 'package:medmind/core/usecases/usecase.dart';
import '../../utils/property_test_framework.dart';
import '../../utils/mock_data_generators.dart';

@GenerateMocks([
  SignInWithEmailAndPassword,
  SignInWithGoogle,
  SignUp,
  SignOut,
  GetMedications,
  AddMedication,
  UpdateMedication,
  DeleteMedication,
  GetTodayMedications,
  GetAdherenceStats,
  LogMedicationTaken,
])
import 'bloc_verification_tests.mocks.dart';

/// **Feature: system-verification, Property 12: BLoC events emit states in correct sequence**
/// **Validates: Requirements 4.1**
void main() {
  group('BLoC State Management Verification Tests', () {
    late MockSignInWithEmailAndPassword mockSignIn;
    late MockSignInWithGoogle mockGoogleSignIn;
    late MockSignUp mockSignUp;
    late MockSignOut mockSignOut;
    late MockGetMedications mockGetMedications;
    late MockAddMedication mockAddMedication;
    late MockUpdateMedication mockUpdateMedication;
    late MockDeleteMedication mockDeleteMedication;
    late MockGetTodayMedications mockGetTodayMedications;
    late MockGetAdherenceStats mockGetAdherenceStats;
    late MockLogMedicationTaken mockLogMedicationTaken;

    setUp(() {
      mockSignIn = MockSignInWithEmailAndPassword();
      mockGoogleSignIn = MockSignInWithGoogle();
      mockSignUp = MockSignUp();
      mockSignOut = MockSignOut();
      mockGetMedications = MockGetMedications();
      mockAddMedication = MockAddMedication();
      mockUpdateMedication = MockUpdateMedication();
      mockDeleteMedication = MockDeleteMedication();
      mockGetTodayMedications = MockGetTodayMedications();
      mockGetAdherenceStats = MockGetAdherenceStats();
      mockLogMedicationTaken = MockLogMedicationTaken();
    });

    group('Property 12: BLoC events emit states in correct sequence', () {
      propertyTest<Map<String, dynamic>>(
        'Auth BLoC emits Loading then Success for successful sign in',
        generator: () => MockDataGenerators.generateUserCredentials(),
        property: (credentials) async {
          // Arrange
          final user = MockDataGenerators.generateUser(
            email: credentials['email'] as String,
          );
          when(mockSignIn.call(any)).thenAnswer((_) async => Right(user));

          final bloc = AuthBloc(
            signInWithEmailAndPassword: mockSignIn,
            signInWithGoogle: mockGoogleSignIn,
            signUp: mockSignUp,
            signOut: mockSignOut,
          );

          // Act & Assert
          final states = <AuthState>[];
          final subscription = bloc.stream.listen(states.add);

          bloc.add(
            SignInRequested(
              email: credentials['email'] as String,
              password: credentials['password'] as String,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 100));
          await subscription.cancel();
          await bloc.close();

          // Verify sequence: Loading -> Success (never both Success and Error)
          if (states.isEmpty) return false;

          // First state should be loading
          if (states.first is! SignInLoading) return false;

          // Should have a success state
          final hasSuccess = states.any((s) => s is Authenticated);
          final hasError = states.any((s) => s is SignInError);

          // Should not have both success and error
          if (hasSuccess && hasError) return false;

          // Should have success for this test case
          return hasSuccess;
        },
        config: const PropertyTestConfig(iterations: 100),
      );

      propertyTest<Map<String, dynamic>>(
        'Auth BLoC emits Loading then Error for failed sign in',
        generator: () => MockDataGenerators.generateUserCredentials(),
        property: (credentials) async {
          // Arrange
          when(mockSignIn.call(any)).thenAnswer(
            (_) async => Left(
              AuthenticationFailure(
                message: 'Invalid credentials',
                code: 'invalid-credentials',
              ),
            ),
          );

          final bloc = AuthBloc(
            signInWithEmailAndPassword: mockSignIn,
            signInWithGoogle: mockGoogleSignIn,
            signUp: mockSignUp,
            signOut: mockSignOut,
          );

          // Act & Assert
          final states = <AuthState>[];
          final subscription = bloc.stream.listen(states.add);

          bloc.add(
            SignInRequested(
              email: credentials['email'] as String,
              password: credentials['password'] as String,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 100));
          await subscription.cancel();
          await bloc.close();

          // Verify sequence: Loading -> Error (never both Success and Error)
          if (states.isEmpty) return false;

          // First state should be loading
          if (states.first is! SignInLoading) return false;

          // Should have an error state
          final hasError = states.any((s) => s is SignInError);
          final hasSuccess = states.any((s) => s is Authenticated);

          // Should not have both success and error
          if (hasSuccess && hasError) return false;

          // Should have error for this test case
          return hasError;
        },
        config: const PropertyTestConfig(iterations: 100),
      );

      propertyTest<Map<String, dynamic>>(
        'Medication BLoC emits Loading then Success for successful operations',
        generator: () => {
          'medication': MockDataGenerators.generateMedication(),
        },
        property: (data) async {
          // Arrange
          final medication = data['medication'];
          when(
            mockAddMedication.call(any),
          ).thenAnswer((_) async => Right(medication));

          final bloc = MedicationBloc(
            getMedications: mockGetMedications,
            addMedication: mockAddMedication,
            updateMedication: mockUpdateMedication,
            deleteMedication: mockDeleteMedication,
          );

          // Act & Assert
          final states = <MedicationState>[];
          final subscription = bloc.stream.listen(states.add);

          bloc.add(AddMedicationRequested(medication: medication));

          await Future.delayed(const Duration(milliseconds: 100));
          await subscription.cancel();
          await bloc.close();

          // Verify sequence: Loading -> Success
          if (states.isEmpty) return false;

          // First state should be loading
          if (states.first is! MedicationLoading) return false;

          // Should have a success state
          final hasSuccess = states.any((s) => s is MedicationAdded);
          final hasError = states.any((s) => s is MedicationError);

          // Should not have both success and error
          if (hasSuccess && hasError) return false;

          return hasSuccess;
        },
        config: const PropertyTestConfig(iterations: 100),
      );
    });

    group('Property 14: Data changes update dependent UI', () {
      // This property is tested through widget tests and integration tests
      // Here we verify that BLoC emits new states when data changes
      propertyTest<Map<String, dynamic>>(
        'Medication BLoC emits new state when medication is updated',
        generator: () => {
          'medication': MockDataGenerators.generateMedication(),
        },
        property: (data) async {
          // Arrange
          final medication = data['medication'];
          when(
            mockUpdateMedication.call(any),
          ).thenAnswer((_) async => Right(medication));

          final bloc = MedicationBloc(
            getMedications: mockGetMedications,
            addMedication: mockAddMedication,
            updateMedication: mockUpdateMedication,
            deleteMedication: mockDeleteMedication,
          );

          // Act
          final states = <MedicationState>[];
          final subscription = bloc.stream.listen(states.add);

          bloc.add(UpdateMedicationRequested(medication: medication));

          await Future.delayed(const Duration(milliseconds: 100));
          await subscription.cancel();
          await bloc.close();

          // Assert - BLoC should emit updated state
          final hasUpdatedState = states.any((s) => s is MedicationUpdated);
          return hasUpdatedState;
        },
        config: const PropertyTestConfig(iterations: 100),
      );
    });

    group('Property 15: Network errors emit descriptive failures', () {
      propertyTest<Map<String, dynamic>>(
        'Auth BLoC emits error state with descriptive message on network failure',
        generator: () => MockDataGenerators.generateUserCredentials(),
        property: (credentials) async {
          // Arrange
          when(mockSignIn.call(any)).thenAnswer(
            (_) async => Left(
              NetworkFailure(
                message: 'No internet connection',
                code: 'network-error',
              ),
            ),
          );

          final bloc = AuthBloc(
            signInWithEmailAndPassword: mockSignIn,
            signInWithGoogle: mockGoogleSignIn,
            signUp: mockSignUp,
            signOut: mockSignOut,
          );

          // Act
          final states = <AuthState>[];
          final subscription = bloc.stream.listen(states.add);

          bloc.add(
            SignInRequested(
              email: credentials['email'] as String,
              password: credentials['password'] as String,
            ),
          );

          await Future.delayed(const Duration(milliseconds: 100));
          await subscription.cancel();
          await bloc.close();

          // Assert - Should have error state with descriptive message
          final errorStates = states.whereType<SignInError>().toList();
          if (errorStates.isEmpty) return false;

          final errorState = errorStates.first;
          // Message should be descriptive (not empty)
          return errorState.message.isNotEmpty;
        },
        config: const PropertyTestConfig(iterations: 100),
      );

      propertyTest<Map<String, dynamic>>(
        'Medication BLoC emits error state with message on network failure',
        generator: () => {
          'medication': MockDataGenerators.generateMedication(),
        },
        property: (data) async {
          // Arrange
          when(mockGetMedications.call(any)).thenAnswer(
            (_) async => Left(
              NetworkFailure(
                message: 'Failed to connect to server',
                code: 'network-error',
              ),
            ),
          );

          final bloc = MedicationBloc(
            getMedications: mockGetMedications,
            addMedication: mockAddMedication,
            updateMedication: mockUpdateMedication,
            deleteMedication: mockDeleteMedication,
          );

          // Act
          final states = <MedicationState>[];
          final subscription = bloc.stream.listen(states.add);

          bloc.add(GetMedicationsRequested());

          await Future.delayed(const Duration(milliseconds: 100));
          await subscription.cancel();
          await bloc.close();

          // Assert - Should have error state with message
          final errorStates = states.whereType<MedicationError>().toList();
          if (errorStates.isEmpty) return false;

          return errorStates.first.message.isNotEmpty;
        },
        config: const PropertyTestConfig(iterations: 100),
      );
    });

    group('Property 16: Concurrent events maintain state consistency', () {
      propertyTest<List<Map<String, dynamic>>>(
        'Medication BLoC handles concurrent add events consistently',
        generator: () => List.generate(
          3,
          (_) => {'medication': MockDataGenerators.generateMedication()},
        ),
        property: (medications) async {
          // Arrange
          for (var medData in medications) {
            when(
              mockAddMedication.call(any),
            ).thenAnswer((_) async => Right(medData['medication']));
          }

          final bloc = MedicationBloc(
            getMedications: mockGetMedications,
            addMedication: mockAddMedication,
            updateMedication: mockUpdateMedication,
            deleteMedication: mockDeleteMedication,
          );

          // Act - Dispatch multiple events rapidly
          final states = <MedicationState>[];
          final subscription = bloc.stream.listen(states.add);

          for (var medData in medications) {
            bloc.add(AddMedicationRequested(medication: medData['medication']));
          }

          await Future.delayed(const Duration(milliseconds: 300));
          await subscription.cancel();
          await bloc.close();

          // Assert - Final state should be deterministic
          // All events should have been processed
          final addedStates = states.whereType<MedicationAdded>().toList();

          // Should have processed all medications
          return addedStates.length == medications.length;
        },
        config: const PropertyTestConfig(iterations: 50),
      );
    });

    group('Property 70: Concurrent events process sequentially', () {
      propertyTest<List<Map<String, dynamic>>>(
        'Auth BLoC processes concurrent sign-in events sequentially',
        generator: () => List.generate(
          3,
          (_) => MockDataGenerators.generateUserCredentials(),
        ),
        property: (credentialsList) async {
          // Arrange
          final users = credentialsList.map((creds) {
            return MockDataGenerators.generateUser(
              email: creds['email'] as String,
            );
          }).toList();

          var callCount = 0;
          when(mockSignIn.call(any)).thenAnswer((_) async {
            final user = users[callCount % users.length];
            callCount++;
            return Right(user);
          });

          final bloc = AuthBloc(
            signInWithEmailAndPassword: mockSignIn,
            signInWithGoogle: mockGoogleSignIn,
            signUp: mockSignUp,
            signOut: mockSignOut,
          );

          // Act - Dispatch multiple events rapidly
          final states = <AuthState>[];
          final subscription = bloc.stream.listen(states.add);

          for (var creds in credentialsList) {
            bloc.add(
              SignInRequested(
                email: creds['email'] as String,
                password: creds['password'] as String,
              ),
            );
          }

          await Future.delayed(const Duration(milliseconds: 300));
          await subscription.cancel();
          await bloc.close();

          // Assert - Events should be processed sequentially
          // Each event should have a loading state followed by success/error
          final loadingStates = states.whereType<SignInLoading>().toList();

          // Should have loading states for each event
          return loadingStates.length >= credentialsList.length;
        },
        config: const PropertyTestConfig(iterations: 50),
      );

      propertyTest<List<Map<String, dynamic>>>(
        'Dashboard BLoC processes concurrent log events sequentially',
        generator: () => List.generate(
          3,
          (_) => {'medicationId': MockDataGenerators.generateId()},
        ),
        property: (logEvents) async {
          // Arrange
          when(
            mockLogMedicationTaken.call(any),
          ).thenAnswer((_) async => const Right(null));
          when(
            mockGetTodayMedications.call(any),
          ).thenAnswer((_) async => const Right([]));
          when(mockGetAdherenceStats.call(any)).thenAnswer(
            (_) async => Right(MockDataGenerators.generateAdherenceStats()),
          );

          final bloc = DashboardBloc(
            getTodayMedications: mockGetTodayMedications,
            getAdherenceStats: mockGetAdherenceStats,
            logMedicationTaken: mockLogMedicationTaken,
          );

          // Act - Dispatch multiple log events rapidly
          final states = <DashboardState>[];
          final subscription = bloc.stream.listen(states.add);

          for (var event in logEvents) {
            bloc.add(
              LogMedicationTakenEvent(
                medicationId: event['medicationId'] as String,
              ),
            );
          }

          await Future.delayed(const Duration(milliseconds: 500));
          await subscription.cancel();
          await bloc.close();

          // Assert - All events should be processed
          final loggedStates = states
              .whereType<MedicationLoggedSuccess>()
              .toList();

          // Should have processed all log events
          return loggedStates.length >= logEvents.length;
        },
        config: const PropertyTestConfig(iterations: 50),
      );
    });
  });
}
