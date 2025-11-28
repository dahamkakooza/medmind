import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:medmind/features/medication/presentation/pages/medication_list_page.dart';
import 'package:medmind/features/medication/presentation/blocs/medication_bloc/medication_bloc.dart';
import 'package:medmind/features/medication/presentation/blocs/medication_bloc/medication_state.dart';
import 'package:medmind/features/medication/presentation/blocs/medication_bloc/medication_event.dart';
import '../../utils/mock_data_generators.dart';

@GenerateMocks([MedicationBloc])
import 'medication_delete_completion_test.mocks.dart';

/// **Feature: navigation-ux-improvements**
/// Medication Delete Completion Tests
///
/// This test suite verifies that confirmed deletions remove medications
/// and provide appropriate feedback to the user.

void main() {
  group('Medication Delete Completion Tests', () {
    late MockMedicationBloc mockBloc;
    late StreamController<MedicationState> stateController;

    setUp(() {
      mockBloc = MockMedicationBloc();
      stateController = StreamController<MedicationState>.broadcast();
    });

    tearDown(() {
      stateController.close();
    });

    Widget makeTestableWidget(Widget child) {
      return MaterialApp(
        home: BlocProvider<MedicationBloc>.value(value: mockBloc, child: child),
      );
    }

    /// **Feature: navigation-ux-improvements, Property 5: Confirmed deletion removes medication and provides feedback**
    /// **Validates: Requirements 3.3, 3.4, 3.5**
    testWidgets(
      'Property 5: Confirmed deletion removes medication and provides feedback',
      (tester) async {
        // Property: For any confirmed medication deletion, the medication should
        // no longer appear in subsequent queries, and a confirmation message
        // should be displayed

        // Test with multiple random medications
        for (int i = 0; i < 10; i++) {
          final medications = MockMedicationGenerator.generateList(
            count: 3,
            userId: 'test_user_id',
          );

          final medicationToDelete = medications[0];

          // Set up the bloc to return loaded state with medications
          when(mockBloc.stream).thenAnswer((_) => stateController.stream);
          when(
            mockBloc.state,
          ).thenReturn(MedicationLoaded(medications: medications));

          // Build the medication list page
          await tester.pumpWidget(
            makeTestableWidget(const MedicationListPage()),
          );
          await tester.pumpAndSettle();

          // Verify medication is initially displayed
          expect(
            find.text(medicationToDelete.name),
            findsAtLeastNWidgets(1),
            reason: 'Medication should be displayed initially for iteration $i',
          );

          // Find the delete button for the first medication
          final deleteButtons = find.byIcon(Icons.delete_outline);

          // Tap the delete button
          await tester.tap(deleteButtons.first);
          await tester.pumpAndSettle();

          // Verify confirmation dialog is shown
          expect(
            find.text('Delete Medication'),
            findsOneWidget,
            reason:
                'Delete confirmation dialog should be shown for iteration $i',
          );

          // Find the Delete button in the dialog
          final dialogDeleteButton = find.ancestor(
            of: find.text('Delete'),
            matching: find.byType(TextButton),
          );

          // Tap the Delete button in the dialog
          await tester.tap(dialogDeleteButton.first);
          await tester.pumpAndSettle();

          // Verify DeleteMedicationRequested was dispatched
          verify(
            mockBloc.add(
              DeleteMedicationRequested(medicationId: medicationToDelete.id),
            ),
          ).called(1);

          // Simulate the bloc emitting MedicationDeleted state
          when(
            mockBloc.state,
          ).thenReturn(MedicationDeleted(medicationId: medicationToDelete.id));
          stateController.add(
            MedicationDeleted(medicationId: medicationToDelete.id),
          );

          // Pump to process the state change and snackbar animation
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          // Verify confirmation snackbar is shown
          expect(
            find.text('Medication deleted'),
            findsOneWidget,
            reason: 'Confirmation message should be shown for iteration $i',
          );

          // Verify GetMedicationsRequested was dispatched to reload the list
          verify(mockBloc.add(any)).called(greaterThanOrEqualTo(1));

          // Clean up for next iteration
          await tester.pumpWidget(Container());
          reset(mockBloc);
          stateController = StreamController<MedicationState>.broadcast();
        }
      },
    );

    /// **Feature: navigation-ux-improvements, Property 5 (Medication no longer appears)**
    /// **Validates: Requirements 3.3**
    testWidgets('Property 5: Deleted medication no longer appears in list', (
      tester,
    ) async {
      // Property: For any deleted medication, it should not appear in
      // subsequent medication list queries

      // Test with multiple random medications
      for (int i = 0; i < 10; i++) {
        // Generate medications with unique names to avoid duplicates
        final allMedications = List.generate(
          5,
          (index) => MockMedicationGenerator.generate(
            userId: 'test_user_id',
            name: 'Medication_${i}_$index',
          ),
        );

        final medicationToDelete = allMedications[2]; // Delete middle one
        final remainingMedications = allMedications
            .where((m) => m.id != medicationToDelete.id)
            .toList();

        // Simulate the state AFTER deletion - the medication list should not
        // contain the deleted medication
        when(mockBloc.stream).thenAnswer(
          (_) =>
              Stream.value(MedicationLoaded(medications: remainingMedications)),
        );
        when(
          mockBloc.state,
        ).thenReturn(MedicationLoaded(medications: remainingMedications));

        // Build the medication list page with the post-deletion state
        await tester.pumpWidget(makeTestableWidget(const MedicationListPage()));
        await tester.pumpAndSettle();

        // Verify deleted medication is NOT displayed
        expect(
          find.text(medicationToDelete.name),
          findsNothing,
          reason:
              'Deleted medication should not appear in list for iteration $i',
        );

        // Verify remaining medications ARE still displayed
        for (final medication in remainingMedications) {
          expect(
            find.text(medication.name),
            findsAtLeastNWidgets(1),
            reason:
                'Remaining medication ${medication.name} should still be displayed for iteration $i',
          );
        }

        // Clean up for next iteration
        await tester.pumpWidget(Container());
        reset(mockBloc);
      }
    });
  });
}
