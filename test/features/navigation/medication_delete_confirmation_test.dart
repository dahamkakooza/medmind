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
import 'medication_delete_confirmation_test.mocks.dart';

/// **Feature: navigation-ux-improvements**
/// Medication Delete Confirmation Tests
///
/// This test suite verifies that delete actions require confirmation
/// before medications are removed from the system.

void main() {
  group('Medication Delete Confirmation Tests', () {
    late MockMedicationBloc mockBloc;

    setUp(() {
      mockBloc = MockMedicationBloc();
    });

    Widget makeTestableWidget(Widget child) {
      return MaterialApp(
        home: BlocProvider<MedicationBloc>.value(value: mockBloc, child: child),
      );
    }

    /// **Feature: navigation-ux-improvements, Property 4: Delete requires confirmation**
    /// **Validates: Requirements 3.2**
    testWidgets('Property 4: Delete requires confirmation', (tester) async {
      // Property: For any delete action (from list page), a confirmation dialog
      // should be displayed before the medication is removed

      // Test with multiple random medications
      for (int i = 0; i < 10; i++) {
        final medications = MockMedicationGenerator.generateList(
          count: 3,
          userId: 'test_user_id',
        );

        // Set up the bloc to return loaded state with medications
        when(mockBloc.stream).thenAnswer(
          (_) => Stream.value(MedicationLoaded(medications: medications)),
        );
        when(
          mockBloc.state,
        ).thenReturn(MedicationLoaded(medications: medications));

        // Build the medication list page
        await tester.pumpWidget(makeTestableWidget(const MedicationListPage()));
        await tester.pumpAndSettle();

        // Verify medications are displayed
        expect(
          find.text(medications[0].name),
          findsAtLeastNWidgets(1),
          reason: 'First medication should be displayed for iteration $i',
        );

        // Find the delete button for the first medication
        final deleteButtons = find.byIcon(Icons.delete_outline);
        expect(
          deleteButtons,
          findsAtLeastNWidgets(1),
          reason: 'Delete button should be present for iteration $i',
        );

        // Tap the delete button
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();

        // Verify confirmation dialog is shown
        expect(
          find.text('Delete Medication'),
          findsOneWidget,
          reason: 'Delete confirmation dialog should be shown for iteration $i',
        );

        expect(
          find.text('Are you sure you want to delete ${medications[0].name}?'),
          findsOneWidget,
          reason:
              'Confirmation message should include medication name for iteration $i',
        );

        // Verify Cancel button is present
        expect(
          find.text('Cancel'),
          findsOneWidget,
          reason: 'Cancel button should be present for iteration $i',
        );

        // Verify Delete button is present
        expect(
          find.text('Delete'),
          findsAtLeastNWidgets(1),
          reason: 'Delete button should be present in dialog for iteration $i',
        );

        // Test cancellation - tap Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Verify dialog is dismissed
        expect(
          find.text('Delete Medication'),
          findsNothing,
          reason: 'Dialog should be dismissed after cancel for iteration $i',
        );

        // Clean up for next iteration
        await tester.pumpWidget(Container());
        reset(mockBloc);
      }
    });

    /// **Feature: navigation-ux-improvements, Property 4 (Confirmation leads to deletion)**
    /// **Validates: Requirements 3.2**
    testWidgets('Property 4: Confirming deletion dispatches delete event', (
      tester,
    ) async {
      // Property: For any delete confirmation, the delete event should be
      // dispatched to the bloc

      // Test with multiple random medications
      for (int i = 0; i < 10; i++) {
        final medications = MockMedicationGenerator.generateList(
          count: 3,
          userId: 'test_user_id',
        );

        // Set up the bloc to return loaded state with medications
        when(mockBloc.stream).thenAnswer(
          (_) => Stream.value(MedicationLoaded(medications: medications)),
        );
        when(
          mockBloc.state,
        ).thenReturn(MedicationLoaded(medications: medications));

        // Build the medication list page
        await tester.pumpWidget(makeTestableWidget(const MedicationListPage()));
        await tester.pumpAndSettle();

        // Find the delete button for the first medication
        final deleteButtons = find.byIcon(Icons.delete_outline);

        // Tap the delete button
        await tester.tap(deleteButtons.first);
        await tester.pumpAndSettle();

        // Verify confirmation dialog is shown
        expect(
          find.text('Delete Medication'),
          findsOneWidget,
          reason: 'Delete confirmation dialog should be shown for iteration $i',
        );

        // Find the Delete button in the dialog (not the icon button)
        final dialogDeleteButton = find.ancestor(
          of: find.text('Delete'),
          matching: find.byType(TextButton),
        );

        // Tap the Delete button in the dialog
        await tester.tap(dialogDeleteButton.first);
        await tester.pumpAndSettle();

        // Verify DeleteMedicationRequested was dispatched with correct ID
        verify(
          mockBloc.add(
            DeleteMedicationRequested(medicationId: medications[0].id),
          ),
        ).called(1);

        // Verify dialog is dismissed
        expect(
          find.text('Delete Medication'),
          findsNothing,
          reason:
              'Dialog should be dismissed after confirmation for iteration $i',
        );

        // Clean up for next iteration
        await tester.pumpWidget(Container());
        reset(mockBloc);
      }
    });
  });
}
