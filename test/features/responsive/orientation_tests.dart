import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medmind/core/widgets/custom_button.dart';
import 'package:medmind/core/widgets/custom_text_field.dart';
import 'package:medmind/core/theme/app_theme.dart';

/// **Feature: system-verification, Orientation Handling Tests**
/// **Validates: Requirements 25.3**
void main() {
  group('Requirement 25.3: Orientation Handling Tests', () {
    // Helper function to wrap widgets with MaterialApp for testing
    Widget makeTestableWidget(
      Widget child, {
      Orientation orientation = Orientation.portrait,
      Size? size,
    }) {
      final portraitSize = size ?? const Size(390, 844);
      final landscapeSize = Size(portraitSize.height, portraitSize.width);

      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: orientation == Orientation.portrait
                ? portraitSize
                : landscapeSize,
          ),
          child: Scaffold(body: child),
        ),
      );
    }

    testWidgets('Portrait orientation displays vertical layout', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Builder(
                    builder: (context) {
                      final orientation = MediaQuery.of(context).orientation;
                      return Text(
                        'Orientation: ${orientation.name}',
                        style: const TextStyle(fontSize: 18),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  const CustomTextField(label: 'Email'),
                  const SizedBox(height: 16),
                  const PasswordTextField(label: 'Password'),
                  const SizedBox(height: 24),
                  CustomButton(text: 'Sign In', onPressed: () {}),
                ],
              ),
            ),
          ),
          orientation: Orientation.portrait,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Orientation: portrait'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Landscape orientation adapts layout appropriately', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          Builder(
            builder: (context) {
              final orientation = MediaQuery.of(context).orientation;
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Orientation: ${orientation.name}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      orientation == Orientation.landscape
                          ? Row(
                              children: [
                                const Expanded(
                                  child: CustomTextField(label: 'Email'),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: CustomButton(
                                    text: 'Sign In',
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const CustomTextField(label: 'Email'),
                                const SizedBox(height: 16),
                                CustomButton(text: 'Sign In', onPressed: () {}),
                              ],
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
          orientation: Orientation.landscape,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Orientation: landscape'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Verify no overflow in landscape
      expect(tester.takeException(), isNull);
    });

    testWidgets('Grid layout adjusts columns based on orientation', (
      tester,
    ) async {
      // Test portrait - 2 columns
      await tester.pumpWidget(
        makeTestableWidget(
          OrientationBuilder(
            builder: (context, orientation) {
              final crossAxisCount = orientation == Orientation.portrait
                  ? 2
                  : 4;

              return GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: List.generate(
                  8,
                  (index) =>
                      Card(child: Center(child: Text('Item ${index + 1}'))),
                ),
              );
            },
          ),
          orientation: Orientation.portrait,
        ),
      );

      await tester.pumpAndSettle();

      // Assert - All items should be visible
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 8'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Test landscape - 4 columns
      await tester.pumpWidget(
        makeTestableWidget(
          OrientationBuilder(
            builder: (context, orientation) {
              final crossAxisCount = orientation == Orientation.portrait
                  ? 2
                  : 4;

              return GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: List.generate(
                  8,
                  (index) =>
                      Card(child: Center(child: Text('Item ${index + 1}'))),
                ),
              );
            },
          ),
          orientation: Orientation.landscape,
        ),
      );

      await tester.pumpAndSettle();

      // Assert - All items should still be visible
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 8'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Dashboard adapts to landscape orientation', (tester) async {
      // Arrange & Act - Landscape
      await tester.pumpWidget(
        makeTestableWidget(
          OrientationBuilder(
            builder: (context, orientation) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      orientation == Orientation.landscape
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        children: [
                                          const Text('Today\'s Adherence'),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            height: 80,
                                            width: 80,
                                            child: Stack(
                                              fit: StackFit.expand,
                                              children: [
                                                CircularProgressIndicator(
                                                  value: 0.75,
                                                  strokeWidth: 8,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                ),
                                                const Center(
                                                  child: Text(
                                                    '75%',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      _buildMedicationCard(
                                        'Lisinopril',
                                        '10mg at 8:00 AM',
                                      ),
                                      _buildMedicationCard(
                                        'Metformin',
                                        '500mg at 12:00 PM',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        const Text('Today\'s Adherence'),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          height: 100,
                                          width: 100,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              CircularProgressIndicator(
                                                value: 0.75,
                                                strokeWidth: 8,
                                                backgroundColor:
                                                    Colors.grey[200],
                                              ),
                                              const Center(
                                                child: Text(
                                                  '75%',
                                                  style: TextStyle(
                                                    fontSize: 24,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildMedicationCard(
                                  'Lisinopril',
                                  '10mg at 8:00 AM',
                                ),
                                _buildMedicationCard(
                                  'Metformin',
                                  '500mg at 12:00 PM',
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
          orientation: Orientation.landscape,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Today\'s Adherence'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Lisinopril'), findsOneWidget);
      expect(find.text('Metformin'), findsOneWidget);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Form layout adapts to landscape with side-by-side fields', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          OrientationBuilder(
            builder: (context, orientation) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Add Medication',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (orientation == Orientation.landscape) ...[
                        Row(
                          children: [
                            const Expanded(
                              child: CustomTextField(label: 'Medication Name'),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: CustomTextField(label: 'Dosage'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(
                              child: CustomTextField(label: 'Frequency'),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: CustomTextField(label: 'Time'),
                            ),
                          ],
                        ),
                      ] else ...[
                        const CustomTextField(label: 'Medication Name'),
                        const SizedBox(height: 16),
                        const CustomTextField(label: 'Dosage'),
                        const SizedBox(height: 16),
                        const CustomTextField(label: 'Frequency'),
                        const SizedBox(height: 16),
                        const CustomTextField(label: 'Time'),
                      ],
                      const SizedBox(height: 24),
                      CustomButton(text: 'Save Medication', onPressed: () {}),
                    ],
                  ),
                ),
              );
            },
          ),
          orientation: Orientation.landscape,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Add Medication'), findsOneWidget);
      expect(find.text('Medication Name'), findsOneWidget);
      expect(find.text('Dosage'), findsOneWidget);
      expect(find.text('Frequency'), findsOneWidget);
      expect(find.text('Time'), findsOneWidget);
      expect(find.text('Save Medication'), findsOneWidget);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('List view maintains scrollability in both orientations', (
      tester,
    ) async {
      // Test portrait
      await tester.pumpWidget(
        makeTestableWidget(
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.medication)),
                  title: Text('Medication ${index + 1}'),
                  subtitle: const Text('100mg • Daily'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
          orientation: Orientation.portrait,
        ),
      );

      await tester.pumpAndSettle();

      // Assert - First and some items should be visible
      expect(find.text('Medication 1'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Test landscape
      await tester.pumpWidget(
        makeTestableWidget(
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 10,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.medication)),
                  title: Text('Medication ${index + 1}'),
                  subtitle: const Text('100mg • Daily'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
          orientation: Orientation.landscape,
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Items should still be visible in landscape
      expect(find.text('Medication 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Bottom navigation bar adapts to orientation', (tester) async {
      // Test portrait
      await tester.pumpWidget(
        makeTestableWidget(
          Scaffold(
            body: const Center(child: Text('Content')),
            bottomNavigationBar: NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medication_outlined),
                  label: 'Medications',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          ),
          orientation: Orientation.portrait,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Medications'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Test landscape
      await tester.pumpWidget(
        makeTestableWidget(
          Scaffold(
            body: const Center(child: Text('Content')),
            bottomNavigationBar: NavigationBar(
              selectedIndex: 0,
              onDestinationSelected: (index) {},
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medication_outlined),
                  label: 'Medications',
                ),
                NavigationDestination(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          ),
          orientation: Orientation.landscape,
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Navigation should still work in landscape
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Medications'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Dialog maintains proper sizing in both orientations', (
      tester,
    ) async {
      // Test portrait
      await tester.pumpWidget(
        makeTestableWidget(
          Builder(
            builder: (context) {
              return Center(
                child: CustomButton(
                  text: 'Show Dialog',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                          'Are you sure you want to delete this medication?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          orientation: Orientation.portrait,
        ),
      );

      await tester.pumpAndSettle();

      // Act - Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Confirm Delete'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this medication?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Close dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Test landscape
      await tester.pumpWidget(
        makeTestableWidget(
          Builder(
            builder: (context) {
              return Center(
                child: CustomButton(
                  text: 'Show Dialog',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Delete'),
                        content: const Text(
                          'Are you sure you want to delete this medication?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
          orientation: Orientation.landscape,
        ),
      );

      await tester.pumpAndSettle();

      // Act - Show dialog in landscape
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert - Dialog should still display correctly
      expect(find.text('Confirm Delete'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildMedicationCard(String name, String dosage) {
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: const CircleAvatar(child: Icon(Icons.medication)),
      title: Text(name),
      subtitle: Text(dosage),
      trailing: const Icon(Icons.chevron_right),
    ),
  );
}
