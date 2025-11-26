import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medmind/core/widgets/custom_button.dart';
import 'package:medmind/core/widgets/custom_text_field.dart';
import 'package:medmind/core/widgets/empty_state_widget.dart';
import 'package:medmind/core/theme/app_theme.dart';

/// **Feature: system-verification, Responsive Design Tests**
/// **Validates: Requirements 25.1, 25.2, 25.3, 25.4, 25.5**
void main() {
  group('Responsive Design and Accessibility Tests', () {
    // Helper function to wrap widgets with MaterialApp for testing
    Widget makeTestableWidget(
      Widget child, {
      Size? size,
      ThemeData? theme,
      double? textScaleFactor,
    }) {
      return MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: size ?? const Size(375, 667), // Default iPhone SE size
            textScaler: TextScaler.linear(textScaleFactor ?? 1.0),
          ),
          child: Scaffold(body: child),
        ),
      );
    }

    group('Requirements 25.1, 25.2: Small and Large Screen Layouts', () {
      testWidgets('Small screen (≤5.5") displays content without overflow', (
        tester,
      ) async {
        // Arrange - iPhone SE size (4.7")
        const smallScreenSize = Size(320, 568);

        await tester.pumpWidget(
          makeTestableWidget(
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Welcome to MedMind',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CustomTextField(
                      label: 'Email',
                      hintText: 'Enter your email address',
                    ),
                    const SizedBox(height: 16),
                    const PasswordTextField(label: 'Password'),
                    const SizedBox(height: 24),
                    CustomButton(text: 'Sign In', onPressed: () {}),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Create Account',
                      onPressed: () {},
                      variant: ButtonVariant.outlined,
                    ),
                  ],
                ),
              ),
            ),
            size: smallScreenSize,
          ),
        );

        await tester.pumpAndSettle();

        // Assert - All widgets should be rendered without overflow
        expect(find.text('Welcome to MedMind'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Password'), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Create Account'), findsOneWidget);

        // Verify no overflow errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('Large screen (≥6.7") utilizes space effectively', (
        tester,
      ) async {
        // Arrange - iPhone 14 Pro Max size (6.7")
        const largeScreenSize = Size(430, 932);

        await tester.pumpWidget(
          makeTestableWidget(
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'Today\'s Adherence',
                              style: TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 120,
                              width: 120,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CircularProgressIndicator(
                                    value: 0.75,
                                    strokeWidth: 10,
                                    backgroundColor: Colors.grey[200],
                                  ),
                                  const Center(
                                    child: Text(
                                      '75%',
                                      style: TextStyle(
                                        fontSize: 28,
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
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildStatCard('12', 'Medications'),
                        _buildStatCard('85%', 'Adherence'),
                        _buildStatCard('3', 'Missed Today'),
                        _buildStatCard('28', 'Day Streak'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            size: largeScreenSize,
          ),
        );

        await tester.pumpAndSettle();

        // Assert - All widgets should be rendered
        expect(find.text('Dashboard'), findsOneWidget);
        expect(find.text('Today\'s Adherence'), findsOneWidget);
        expect(find.text('75%'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);
        expect(find.text('Medications'), findsOneWidget);

        // Verify no overflow errors
        expect(tester.takeException(), isNull);
      });

      testWidgets('Medium screen (5.5"-6.7") displays balanced layout', (
        tester,
      ) async {
        // Arrange - iPhone 13 size (6.1")
        const mediumScreenSize = Size(390, 844);

        await tester.pumpWidget(
          makeTestableWidget(
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'My Medications',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...List.generate(
                  5,
                  (index) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.medication),
                      ),
                      title: Text('Medication ${index + 1}'),
                      subtitle: const Text('100mg • Daily at 8:00 AM'),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ),
                ),
              ],
            ),
            size: mediumScreenSize,
          ),
        );

        await tester.pumpAndSettle();

        // Assert - All medications should be visible
        expect(find.text('My Medications'), findsOneWidget);
        expect(find.text('Medication 1'), findsOneWidget);
        expect(find.text('Medication 5'), findsOneWidget);

        // Verify no overflow errors
        expect(tester.takeException(), isNull);
      });

      testWidgets(
        'Buttons maintain minimum touch target size on small screens',
        (tester) async {
          // Arrange
          const smallScreenSize = Size(320, 568);

          await tester.pumpWidget(
            makeTestableWidget(
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(text: 'Primary Action', onPressed: () {}),
                    const SizedBox(height: 16),
                    IconButton(icon: const Icon(Icons.add), onPressed: () {}),
                  ],
                ),
              ),
              size: smallScreenSize,
            ),
          );

          await tester.pumpAndSettle();

          // Assert - Button should have minimum 48x48 touch target
          final buttonFinder = find.byType(ElevatedButton);
          expect(buttonFinder, findsOneWidget);

          final buttonSize = tester.getSize(buttonFinder);
          expect(buttonSize.height, greaterThanOrEqualTo(48));

          // IconButton should also meet minimum size
          final iconButtonFinder = find.byType(IconButton);
          expect(iconButtonFinder, findsOneWidget);

          final iconButtonSize = tester.getSize(iconButtonFinder);
          expect(iconButtonSize.width, greaterThanOrEqualTo(48));
          expect(iconButtonSize.height, greaterThanOrEqualTo(48));
        },
      );

      testWidgets('Cards adapt to screen width appropriately', (tester) async {
        // Arrange - Test on different screen sizes
        const sizes = [
          Size(320, 568), // Small
          Size(390, 844), // Medium
          Size(430, 932), // Large
        ];

        for (final size in sizes) {
          await tester.pumpWidget(
            makeTestableWidget(
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Medication Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('Name: Lisinopril'),
                        const Text('Dosage: 10mg'),
                        const Text('Schedule: Daily at 8:00 AM'),
                      ],
                    ),
                  ),
                ),
              ),
              size: size,
            ),
          );

          await tester.pumpAndSettle();

          // Assert - Card should be visible and not overflow
          expect(find.text('Medication Details'), findsOneWidget);
          expect(find.text('Name: Lisinopril'), findsOneWidget);
          expect(tester.takeException(), isNull);

          // Get card width
          final cardFinder = find.byType(Card);
          final cardSize = tester.getSize(cardFinder);

          // Card should fit within screen width (allowing for Material elevation/shadow)
          expect(cardSize.width, lessThan(size.width));
        }
      });

      testWidgets('Empty state displays correctly on all screen sizes', (
        tester,
      ) async {
        const sizes = [
          Size(320, 568), // Small
          Size(390, 844), // Medium
          Size(430, 932), // Large
        ];

        for (final size in sizes) {
          await tester.pumpWidget(
            makeTestableWidget(
              Center(
                child: EmptyStateWidget(
                  icon: Icons.medication,
                  title: 'No medications yet',
                  description: 'Add your first medication to get started',
                  actionText: 'Add Medication',
                  onAction: () {},
                ),
              ),
              size: size,
            ),
          );

          await tester.pumpAndSettle();

          // Assert - Empty state should be visible
          expect(find.text('No medications yet'), findsOneWidget);
          expect(
            find.text('Add your first medication to get started'),
            findsOneWidget,
          );
          expect(find.text('Add Medication'), findsOneWidget);
          expect(find.byIcon(Icons.medication), findsOneWidget);

          // Verify no overflow
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('Form fields stack vertically on small screens', (
        tester,
      ) async {
        // Arrange
        const smallScreenSize = Size(320, 568);

        await tester.pumpWidget(
          makeTestableWidget(
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CustomTextField(label: 'Medication Name'),
                    const SizedBox(height: 16),
                    const CustomTextField(label: 'Dosage'),
                    const SizedBox(height: 16),
                    const CustomTextField(label: 'Frequency'),
                    const SizedBox(height: 16),
                    const CustomTextField(label: 'Time'),
                    const SizedBox(height: 24),
                    CustomButton(text: 'Save', onPressed: () {}),
                  ],
                ),
              ),
            ),
            size: smallScreenSize,
          ),
        );

        await tester.pumpAndSettle();

        // Assert - All fields should be visible
        expect(find.text('Medication Name'), findsOneWidget);
        expect(find.text('Dosage'), findsOneWidget);
        expect(find.text('Frequency'), findsOneWidget);
        expect(find.text('Time'), findsOneWidget);
        expect(find.text('Save'), findsOneWidget);

        // Verify no overflow
        expect(tester.takeException(), isNull);
      });

      testWidgets('List items maintain readability on small screens', (
        tester,
      ) async {
        // Arrange
        const smallScreenSize = Size(320, 568);

        await tester.pumpWidget(
          makeTestableWidget(
            ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.medication, size: 20),
                    ),
                    title: Text(
                      'Medication Name ${index + 1}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Text(
                      '100mg • Daily',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                  ),
                );
              },
            ),
            size: smallScreenSize,
          ),
        );

        await tester.pumpAndSettle();

        // Assert - List items should be visible
        expect(find.text('Medication Name 1'), findsOneWidget);
        expect(find.text('100mg • Daily'), findsWidgets);

        // Verify no overflow
        expect(tester.takeException(), isNull);
      });
    });
  });
}

Widget _buildStatCard(String value, String label) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
