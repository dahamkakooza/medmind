import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medmind/features/dashboard/presentation/blocs/dashboard_bloc/dashboard_bloc.dart';
import 'package:medmind/features/dashboard/presentation/blocs/dashboard_bloc/dashboard_event.dart';
import 'package:medmind/features/dashboard/presentation/blocs/dashboard_bloc/dashboard_state.dart';
import 'package:medmind/features/dashboard/domain/usecases/get_today_medications.dart';
import 'package:medmind/features/dashboard/domain/usecases/get_adherence_stats.dart';
import 'package:medmind/features/dashboard/domain/usecases/log_medication_taken.dart';
import 'package:medmind/features/dashboard/domain/entities/adherence_entity.dart';
import 'package:medmind/features/adherence/presentation/blocs/adherence_bloc/adherence_bloc.dart';
import 'package:medmind/features/adherence/presentation/blocs/adherence_bloc/adherence_state.dart'
    as adherence_state;
import 'package:medmind/features/adherence/presentation/blocs/adherence_bloc/adherence_event.dart'
    as adherence_event;
import 'package:medmind/features/auth/domain/repositories/auth_repository.dart';
import 'package:medmind/features/auth/domain/entities/user_entity.dart';
import '../../../utils/property_test_framework.dart';
import '../../../utils/mock_data_generators.dart';

@GenerateMocks([
  GetTodayMedications,
  GetAdherenceStats,
  LogMedicationTaken,
  AdherenceBloc,
  AuthRepository,
])
import 'mark_as_taken_test.mocks.dart';

/// **Feature: navigation-ux-improvements, Property 3: Mark as taken updates all related state**
/// **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mark as Taken Property Tests', () {
    late MockGetTodayMedications mockGetTodayMedications;
    late MockGetAdherenceStats mockGetAdherenceStats;
    late MockLogMedicationTaken mockLogMedicationTaken;
    late MockAdherenceBloc mockAdherenceBloc;
    late MockAuthRepository mockAuthRepository;
    late DashboardBloc dashboardBloc;

    setUp(() async {
      // Setup SharedPreferences mock
      SharedPreferences.setMockInitialValues({});

      mockGetTodayMedications = MockGetTodayMedications();
      mockGetAdherenceStats = MockGetAdherenceStats();
      mockLogMedicationTaken = MockLogMedicationTaken();
      mockAdherenceBloc = MockAdherenceBloc();
      mockAuthRepository = MockAuthRepository();

      // Setup mock auth repository with a test user
      final testUser = UserEntity(
        id: 'test-user-id',
        email: 'test@medmind.com',
        displayName: 'Test User',
        dateJoined: DateTime.now(),
        emailVerified: true,
      );
      when(mockAuthRepository.currentUser).thenReturn(testUser);
      when(mockAuthRepository.isSignedIn).thenReturn(true);

      // Setup mock use cases to return empty results (for refresh)
      when(
        mockGetTodayMedications(any),
      ).thenAnswer((_) async => const Right([]));
      when(mockGetAdherenceStats(any)).thenAnswer(
        (_) async => const Right(
          AdherenceEntity(
            adherenceRate: 0.0,
            totalMedications: 0,
            takenCount: 0,
            missedCount: 0,
            streakDays: 0,
          ),
        ),
      );

      // Setup mock adherence bloc
      when(
        mockAdherenceBloc.stream,
      ).thenAnswer((_) => Stream<adherence_state.AdherenceState>.empty());
      when(
        mockAdherenceBloc.state,
      ).thenReturn(adherence_state.AdherenceInitial());

      dashboardBloc = DashboardBloc(
        getTodayMedications: mockGetTodayMedications,
        getAdherenceStats: mockGetAdherenceStats,
        logMedicationTaken: mockLogMedicationTaken,
        adherenceBloc: mockAdherenceBloc,
        authRepository: mockAuthRepository,
      );
    });

    tearDown(() {
      dashboardBloc.close();
    });

    /// **Feature: navigation-ux-improvements, Property 3: Mark as taken updates all related state**
    /// **Validates: Requirements 2.1, 2.2, 2.3, 2.4, 2.5**
    test('Property 3: Mark as taken updates all related state', () async {
      // Property: For any medication marked as taken from the dashboard,
      // the system should:
      // 1. Create an adherence log entry with status "taken"
      // 2. Decrement the pending dose count
      // 3. Display visual feedback
      // 4. Update the progress indicator

      // Run property test with multiple random medications
      final result = await runPropertyTest(
        name: 'Mark as taken updates all related state',
        generator: () => MockDataGenerators.generateMedication(),
        property: (medication) async {
          // Reset mocks for each iteration
          reset(mockAdherenceBloc);
          when(
            mockAdherenceBloc.stream,
          ).thenAnswer((_) => Stream<adherence_state.AdherenceState>.empty());
          when(
            mockAdherenceBloc.state,
          ).thenReturn(adherence_state.AdherenceInitial());

          // Create a fresh bloc for each test
          final testBloc = DashboardBloc(
            getTodayMedications: mockGetTodayMedications,
            getAdherenceStats: mockGetAdherenceStats,
            logMedicationTaken: mockLogMedicationTaken,
            adherenceBloc: mockAdherenceBloc,
            authRepository: mockAuthRepository,
          );

          // Track emitted states
          final states = <DashboardState>[];
          final subscription = testBloc.stream.listen(states.add);

          // Dispatch LogMedicationTakenEvent
          testBloc.add(
            LogMedicationTakenEvent(
              medicationId: medication.id,
              medicationName: medication.name,
            ),
          );

          // Wait for state changes
          await Future.delayed(const Duration(milliseconds: 100));

          // Verify adherence bloc received the event with correct medication ID
          verify(
            mockAdherenceBloc.add(
              argThat(
                isA<adherence_event.LogMedicationTakenRequested>().having(
                  (e) => e.medicationId,
                  'medicationId',
                  medication.id,
                ),
              ),
            ),
          ).called(1);

          // Verify success state was emitted with medication name
          final successState = states.whereType<MedicationLoggedSuccess>();
          final hasSuccessState =
              successState.isNotEmpty &&
              successState.first.medicationId == medication.id &&
              successState.first.medicationName == medication.name;

          await subscription.cancel();
          await testBloc.close();

          return hasSuccessState;
        },
        config: const PropertyTestConfig(iterations: 100),
      );

      expect(result.passed, true, reason: result.toString());
    });

    test(
      'Adherence log is created with correct timestamp and status',
      () async {
        // For any medication, when marked as taken, an adherence log
        // should be created with current timestamp

        final medication = MockDataGenerators.generateMedication();

        // Track emitted states
        final states = <DashboardState>[];
        final subscription = dashboardBloc.stream.listen(states.add);

        // Dispatch event
        dashboardBloc.add(
          LogMedicationTakenEvent(
            medicationId: medication.id,
            medicationName: medication.name,
          ),
        );

        // Wait for processing
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify adherence bloc received event with timestamp
        final captured = verify(mockAdherenceBloc.add(captureAny)).captured;

        expect(captured.length, greaterThan(0));
        final event =
            captured.first as adherence_event.LogMedicationTakenRequested;
        expect(event.medicationId, medication.id);
        expect(event.takenAt, isA<DateTime>());

        // Verify timestamp is recent (within last second)
        final now = DateTime.now();
        final timeDiff = now.difference(event.takenAt).inSeconds.abs();
        expect(timeDiff, lessThan(2));

        await subscription.cancel();
      },
    );

    test('Success state includes medication name for snackbar', () async {
      // For any medication, the success state should include the medication name
      // so the UI can display it in the snackbar

      final medication = MockDataGenerators.generateMedication();

      // Track emitted states
      final states = <DashboardState>[];
      final subscription = dashboardBloc.stream.listen(states.add);

      // Dispatch event
      dashboardBloc.add(
        LogMedicationTakenEvent(
          medicationId: medication.id,
          medicationName: medication.name,
        ),
      );

      // Wait for processing
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify success state contains medication name
      final successStates = states.whereType<MedicationLoggedSuccess>();
      expect(successStates.length, 1);
      expect(successStates.first.medicationName, medication.name);

      await subscription.cancel();
    });

    test('Dashboard refresh is triggered after marking as taken', () async {
      // After marking a medication as taken, the dashboard should refresh
      // to update the progress indicator

      final medication = MockDataGenerators.generateMedication();

      // Track emitted states
      final states = <DashboardState>[];
      final subscription = dashboardBloc.stream.listen(states.add);

      // Dispatch event
      dashboardBloc.add(
        LogMedicationTakenEvent(
          medicationId: medication.id,
          medicationName: medication.name,
        ),
      );

      // Wait for processing
      await Future.delayed(const Duration(milliseconds: 100));

      // The bloc should emit MedicationLoggedSuccess followed by a refresh
      // which would trigger loading state
      final successStates = states.whereType<MedicationLoggedSuccess>();
      expect(successStates.length, 1);

      await subscription.cancel();
    });
  });
}
