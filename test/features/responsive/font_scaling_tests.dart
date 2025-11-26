import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medmind/core/widgets/custom_button.dart';
import 'package:medmind/core/widgets/custom_text_field.dart';
import 'package:medmind/core/widgets/empty_state_widget.dart';
import 'package:medmind/core/theme/app_theme.dart';

/// **Feature: system-verification, Font Scaling Tests**
/// **Validates: Requirements 25.4**
void main() {
  group('Requirement 25.4: Font Scaling Tests', () {
    // Helper function to wrap widgets with MaterialApp for testing
    Widget makeTestableWidget(
      Widget child, {
      double textScaleFactor = 1.0,
      Size? size,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(
            size: size ?? const Size(390, 844),
            textScaler: TextScaler.linear(textScaleFactor),
          ),
          child: Scaffold(body: child),
        ),
      );
    }

    testWidgets('Text scales correctly with 1.0x scale factor', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome to MedMind', style: TextStyle(fontSize: 24)),
                SizedBox(height: 16),
                Text(
                  'Manage your medications easily',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          textScaleFactor: 1.0,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Welcome to MedMind'), findsOneWidget);
      expect(find.text('Manage your medications easily'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Text scales correctly with 1.5x scale factor', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome to MedMind',
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Manage your medications easily',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          textScaleFactor: 1.5,
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Text should still be visible with larger scale
      expect(find.text('Welcome to MedMind'), findsOneWidget);
      expect(find.text('Manage your medications easily'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Text scales correctly with 2.0x scale factor', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Welcome to MedMind',
                      style: TextStyle(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Manage your medications easily',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          textScaleFactor: 2.0,
        ),
      );

      await tester.pumpAndSettle();

      // Assert - Text should still be visible with maximum scale
      expect(find.text('Welcome to MedMind'), findsOneWidget);
      expect(find.text('Manage your medications easily'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Buttons maintain usability with increased font scaling', (
      tester,
    ) async {
      // Test with different scale factors
      final scaleFactors = [1.0, 1.5, 2.0];

      for (final scale in scaleFactors) {
        await tester.pumpWidget(
          makeTestableWidget(
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
            ),
            textScaleFactor: scale,
          ),
        );

        await tester.pumpAndSettle();

        // Assert - Buttons should be visible and tappable
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Create Account'), findsOneWidget);

        // Verify buttons are still tappable
        final signInButton = find.text('Sign In');
        expect(tester.getSize(signInButton).height, greaterThan(0));

        // Verify no overflow
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('Form fields maintain layout integrity with font scaling', (
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
                  const Text(
                    'Login',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  const CustomTextField(
                    label: 'Email',
                    hintText: 'Enter your email',
                  ),
                  const SizedBox(height: 16),
                  const PasswordTextField(label: 'Password'),
                  const SizedBox(height: 24),
                  CustomButton(text: 'Sign In', onPressed: () {}),
                ],
              ),
            ),
          ),
          textScaleFactor: 1.5,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('List items remain readable with increased font scaling', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.medication)),
                  title: Text('Medication ${index + 1}'),
                  subtitle: const Text('100mg • Daily at 8:00 AM'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
          textScaleFactor: 1.5,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Medication 1'), findsOneWidget);
      expect(find.text('100mg • Daily at 8:00 AM'), findsWidgets);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Cards adapt to larger text without overflow', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Today\'s Adherence',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                              backgroundColor: Colors.grey[200],
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
                      const SizedBox(height: 8),
                      const Text('3 of 4 medications taken'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          textScaleFactor: 1.5,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Today\'s Adherence'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('3 of 4 medications taken'), findsOneWidget);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Empty state displays correctly with font scaling', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          SingleChildScrollView(
            child: Center(
              child: EmptyStateWidget(
                icon: Icons.medication,
                title: 'No medications yet',
                description: 'Add your first medication to get started',
                actionText: 'Add Medication',
                onAction: () {},
              ),
            ),
          ),
          textScaleFactor: 1.5,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No medications yet'), findsOneWidget);
      expect(
        find.text('Add your first medication to get started'),
        findsOneWidget,
      );
      expect(find.text('Add Medication'), findsOneWidget);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Dialog text scales appropriately', (tester) async {
      // Arrange & Act
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
                          'Are you sure you want to delete this medication? This action cannot be undone.',
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
          textScaleFactor: 1.5,
        ),
      );

      await tester.pumpAndSettle();

      // Act - Show dialog
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Confirm Delete'), findsOneWidget);
      expect(
        find.text(
          'Are you sure you want to delete this medication? This action cannot be undone.',
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Navigation labels remain visible with font scaling', (
      tester,
    ) async {
      // Arrange & Act
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
          textScaleFactor: 1.5,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Medications'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Error messages scale correctly', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomTextField(
                    label: 'Email',
                    errorText: 'Please enter a valid email address',
                  ),
                  const SizedBox(height: 16),
                  const PasswordTextField(
                    label: 'Password',
                    errorText: 'Password must be at least 6 characters',
                  ),
                ],
              ),
            ),
          ),
          textScaleFactor: 1.5,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Please enter a valid email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Multi-line text wraps correctly with font scaling', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Important Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'This is a longer text that should wrap to multiple lines when the font size is increased. It contains important information about medication adherence and tracking.',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      CustomButton(text: 'Got It', onPressed: () {}),
                    ],
                  ),
                ),
              ),
            ),
          ),
          textScaleFactor: 1.5,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Important Information'), findsOneWidget);
      expect(find.textContaining('This is a longer text'), findsOneWidget);
      expect(find.text('Got It'), findsOneWidget);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Table/Grid layouts adapt to font scaling', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        makeTestableWidget(
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistics',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard('85%', 'Adherence'),
                      _buildStatCard('12', 'Medications'),
                      _buildStatCard('3', 'Missed'),
                      _buildStatCard('28', 'Day Streak'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          textScaleFactor: 1.5,
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('Adherence'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Medications'), findsOneWidget);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });

    testWidgets('Validation messages remain visible with font scaling', (
      tester,
    ) async {
      // Arrange
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController();

      await tester.pumpWidget(
        makeTestableWidget(
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      label: 'Email',
                      controller: controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Submit',
                      onPressed: () {
                        formKey.currentState!.validate();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          textScaleFactor: 1.5,
        ),
      );

      await tester.pumpAndSettle();

      // Act - Trigger validation
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email is required'), findsOneWidget);

      // Act - Enter invalid email
      await tester.enterText(find.byType(TextFormField), 'invalid');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a valid email address'), findsOneWidget);

      // Verify no overflow
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _buildStatCard(String value, String label) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
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
          const SizedBox(height: 4),
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
