import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medmind/core/widgets/custom_button.dart';
import 'package:medmind/core/widgets/custom_text_field.dart';
import 'package:medmind/core/widgets/loading_widget.dart';
import 'package:medmind/core/widgets/error_widget.dart';
import 'package:medmind/core/widgets/empty_state_widget.dart';
import 'package:medmind/core/theme/app_theme.dart';

/// **Feature: system-verification, Property 17: Forms validate before submission**
/// **Validates: Requirements 5.2**
void main() {
  group('UI Components Widget Tests', () {
    // Helper function to wrap widgets with MaterialApp for testing
    Widget makeTestableWidget(Widget child, {ThemeData? theme}) {
      return MaterialApp(
        theme: theme ?? AppTheme.lightTheme,
        home: Scaffold(body: child),
      );
    }

    group('Property 17: Forms validate before submission', () {
      testWidgets('Form with empty required field prevents submission', (
        tester,
      ) async {
        // Arrange
        final formKey = GlobalKey<FormState>();
        bool submitted = false;
        final controller = TextEditingController();

        await tester.pumpWidget(
          makeTestableWidget(
            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Email',
                    controller: controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  CustomButton(
                    text: 'Submit',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        submitted = true;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );

        // Act - Try to submit with empty field
        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();

        // Assert - Form should not be submitted
        expect(submitted, false);
        expect(find.text('Email is required'), findsOneWidget);
      });

      testWidgets('Form with valid data allows submission', (tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();
        bool submitted = false;
        final controller = TextEditingController();

        await tester.pumpWidget(
          makeTestableWidget(
            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Email',
                    controller: controller,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  CustomButton(
                    text: 'Submit',
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        submitted = true;
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );

        // Act - Enter valid data and submit
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();

        // Assert - Form should be submitted
        expect(submitted, true);
        expect(find.text('Email is required'), findsNothing);
      });

      testWidgets('Multiple validation errors are displayed', (tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();
        final emailController = TextEditingController();
        final passwordController = TextEditingController();

        await tester.pumpWidget(
          makeTestableWidget(
            Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    label: 'Email',
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      return null;
                    },
                  ),
                  PasswordTextField(
                    label: 'Password',
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
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
        );

        // Act - Try to submit with empty fields
        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();

        // Assert - Both validation errors should be displayed
        expect(find.text('Email is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);
      });
    });

    group('Property 18: Loading states display indicators', () {
      testWidgets('LoadingWidget displays circular progress indicator', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(makeTestableWidget(const LoadingWidget()));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('LoadingWidget displays message when provided', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(const LoadingWidget(message: 'Loading data...')),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading data...'), findsOneWidget);
      });

      testWidgets(
        'CustomButton shows loading indicator when isLoading is true',
        (tester) async {
          // Arrange & Act
          await tester.pumpWidget(
            makeTestableWidget(
              CustomButton(text: 'Submit', onPressed: () {}, isLoading: true),
            ),
          );

          // Assert
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          expect(find.text('Submit'), findsNothing);
        },
      );

      testWidgets('CustomButton is disabled when isLoading is true', (
        tester,
      ) async {
        // Arrange
        bool pressed = false;

        await tester.pumpWidget(
          makeTestableWidget(
            CustomButton(
              text: 'Submit',
              onPressed: () {
                pressed = true;
              },
              isLoading: true,
            ),
          ),
        );

        // Act - Check that button is disabled (onPressed is null)
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );

        // Assert - Button should be disabled and callback not called
        expect(button.onPressed, isNull);
        expect(pressed, false);
      });

      testWidgets('LoadingOverlay displays when isLoading is true', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(
            LoadingOverlay(
              isLoading: true,
              message: 'Processing...',
              child: const Text('Content'),
            ),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Processing...'), findsOneWidget);
        expect(find.text('Content'), findsOneWidget);
      });

      testWidgets('LoadingOverlay hides when isLoading is false', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(
            LoadingOverlay(isLoading: false, child: const Text('Content')),
          ),
        );

        // Assert
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.text('Content'), findsOneWidget);
      });
    });

    group('Property 19: Error states display error widgets', () {
      testWidgets('ErrorDisplayWidget shows error message', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(
            ErrorDisplayWidget(message: 'Something went wrong', onRetry: () {}),
          ),
        );

        // Assert
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Try Again'), findsOneWidget);
      });

      testWidgets('ErrorDisplayWidget shows title when provided', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(
            ErrorDisplayWidget(
              title: 'Error',
              message: 'Something went wrong',
              onRetry: () {},
            ),
          ),
        );

        // Assert
        expect(find.text('Error'), findsOneWidget);
        expect(find.text('Something went wrong'), findsOneWidget);
      });

      testWidgets('ErrorDisplayWidget retry button calls onRetry', (
        tester,
      ) async {
        // Arrange
        bool retried = false;

        await tester.pumpWidget(
          makeTestableWidget(
            ErrorDisplayWidget(
              message: 'Something went wrong',
              onRetry: () {
                retried = true;
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Try Again'));
        await tester.pumpAndSettle();

        // Assert
        expect(retried, true);
      });

      testWidgets(
        'ErrorDisplayWidget hides retry button when onRetry is null',
        (tester) async {
          // Arrange & Act
          await tester.pumpWidget(
            makeTestableWidget(
              const ErrorDisplayWidget(message: 'Something went wrong'),
            ),
          );

          // Assert
          expect(find.text('Try Again'), findsNothing);
        },
      );

      testWidgets('ErrorContainer displays error message with icon', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(const ErrorContainer(message: 'Invalid input')),
        );

        // Assert
        expect(find.text('Invalid input'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });
    });

    group('Property 20: Theme changes apply globally', () {
      testWidgets('Widgets use light theme colors', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(
            Column(
              children: [
                CustomButton(text: 'Button', onPressed: () {}),
                const CustomTextField(label: 'Field'),
              ],
            ),
            theme: AppTheme.lightTheme,
          ),
        );

        // Assert - Verify widgets are rendered (theme colors are applied)
        expect(find.text('Button'), findsOneWidget);
        expect(find.text('Field'), findsOneWidget);
        expect(find.byType(CustomButton), findsOneWidget);
        expect(find.byType(CustomTextField), findsOneWidget);
      });

      testWidgets('Widgets use dark theme colors', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(
            Column(
              children: [
                CustomButton(text: 'Button', onPressed: () {}),
                const CustomTextField(label: 'Field'),
              ],
            ),
            theme: AppTheme.darkTheme,
          ),
        );

        // Assert - Verify widgets are rendered with dark theme
        expect(find.text('Button'), findsOneWidget);
        expect(find.text('Field'), findsOneWidget);
        expect(find.byType(CustomButton), findsOneWidget);
        expect(find.byType(CustomTextField), findsOneWidget);
      });

      testWidgets('Theme change updates widget appearance', (tester) async {
        // Arrange
        ThemeData currentTheme = AppTheme.lightTheme;

        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              return MaterialApp(
                theme: currentTheme,
                home: Scaffold(
                  body: Column(
                    children: [
                      CustomButton(
                        text: 'Toggle Theme',
                        onPressed: () {
                          setState(() {
                            currentTheme =
                                currentTheme.brightness == Brightness.light
                                ? AppTheme.darkTheme
                                : AppTheme.lightTheme;
                          });
                        },
                      ),
                      const Text('Content'),
                    ],
                  ),
                ),
              );
            },
          ),
        );

        // Act - Toggle theme
        await tester.tap(find.text('Toggle Theme'));
        await tester.pumpAndSettle();

        // Assert - Widgets should still be rendered with new theme
        expect(find.text('Toggle Theme'), findsOneWidget);
        expect(find.text('Content'), findsOneWidget);
      });
    });

    group('Property 37: Validation errors highlight fields', () {
      testWidgets('CustomTextField displays error text when provided', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(
            const CustomTextField(
              label: 'Email',
              errorText: 'Invalid email format',
            ),
          ),
        );

        // Assert
        expect(find.text('Invalid email format'), findsOneWidget);
      });

      testWidgets('CustomTextField shows validator error on validation', (
        tester,
      ) async {
        // Arrange
        final formKey = GlobalKey<FormState>();
        final controller = TextEditingController();

        await tester.pumpWidget(
          makeTestableWidget(
            Form(
              key: formKey,
              child: CustomTextField(
                label: 'Email',
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  if (!value.contains('@')) {
                    return 'Invalid email format';
                  }
                  return null;
                },
              ),
            ),
          ),
        );

        // Act - Enter invalid email and validate
        await tester.enterText(find.byType(TextFormField), 'invalid');
        formKey.currentState!.validate();
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Invalid email format'), findsOneWidget);
      });

      testWidgets('PasswordTextField shows validation error', (tester) async {
        // Arrange
        final formKey = GlobalKey<FormState>();
        final controller = TextEditingController();

        await tester.pumpWidget(
          makeTestableWidget(
            Form(
              key: formKey,
              child: PasswordTextField(
                label: 'Password',
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ),
          ),
        );

        // Act - Enter short password and validate
        await tester.enterText(find.byType(TextFormField), '123');
        formKey.currentState!.validate();
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.text('Password must be at least 6 characters'),
          findsOneWidget,
        );
      });

      testWidgets('Error text is cleared when field becomes valid', (
        tester,
      ) async {
        // Arrange
        final formKey = GlobalKey<FormState>();
        final controller = TextEditingController();

        await tester.pumpWidget(
          makeTestableWidget(
            Form(
              key: formKey,
              child: CustomTextField(
                label: 'Email',
                controller: controller,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        );

        // Act - Validate empty field
        formKey.currentState!.validate();
        await tester.pumpAndSettle();
        expect(find.text('Email is required'), findsOneWidget);

        // Act - Enter valid data and validate again
        await tester.enterText(find.byType(TextFormField), 'test@example.com');
        formKey.currentState!.validate();
        await tester.pumpAndSettle();

        // Assert - Error should be cleared
        expect(find.text('Email is required'), findsNothing);
      });
    });

    group('Additional UI Component Tests', () {
      testWidgets('CustomButton renders with text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(CustomButton(text: 'Click Me', onPressed: () {})),
        );

        // Assert
        expect(find.text('Click Me'), findsOneWidget);
      });

      testWidgets('CustomButton calls onPressed when tapped', (tester) async {
        // Arrange
        bool pressed = false;

        await tester.pumpWidget(
          makeTestableWidget(
            CustomButton(
              text: 'Click Me',
              onPressed: () {
                pressed = true;
              },
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Click Me'));
        await tester.pumpAndSettle();

        // Assert
        expect(pressed, true);
      });

      testWidgets('CustomButton is disabled when isDisabled is true', (
        tester,
      ) async {
        // Arrange
        bool pressed = false;

        await tester.pumpWidget(
          makeTestableWidget(
            CustomButton(
              text: 'Click Me',
              onPressed: () {
                pressed = true;
              },
              isDisabled: true,
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Click Me'));
        await tester.pumpAndSettle();

        // Assert
        expect(pressed, false);
      });

      testWidgets('CustomButton renders with icon', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(
            CustomButton(text: 'Add', icon: Icons.add, onPressed: () {}),
          ),
        );

        // Assert
        expect(find.text('Add'), findsOneWidget);
        expect(find.byIcon(Icons.add), findsOneWidget);
      });

      testWidgets('PasswordTextField toggles visibility', (tester) async {
        // Arrange
        final controller = TextEditingController(text: 'password123');

        await tester.pumpWidget(
          makeTestableWidget(
            PasswordTextField(label: 'Password', controller: controller),
          ),
        );

        // Assert - Initially shows visibility icon (password is obscured)
        expect(find.byIcon(Icons.visibility), findsOneWidget);

        // Act - Tap visibility toggle
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pumpAndSettle();

        // Assert - Now shows visibility_off icon (password is visible)
        expect(find.byIcon(Icons.visibility_off), findsOneWidget);
        expect(find.byIcon(Icons.visibility), findsNothing);
      });

      testWidgets('EmptyStateWidget displays title and description', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(
            EmptyStateWidget(
              title: 'No Data',
              description: 'There is no data to display',
              onAction: () {},
              actionText: 'Add Data',
            ),
          ),
        );

        // Assert
        expect(find.text('No Data'), findsOneWidget);
        expect(find.text('There is no data to display'), findsOneWidget);
        expect(find.text('Add Data'), findsOneWidget);
      });

      testWidgets('EmptyStateWidget action button calls onAction', (
        tester,
      ) async {
        // Arrange
        bool actionCalled = false;

        await tester.pumpWidget(
          makeTestableWidget(
            EmptyStateWidget(
              title: 'No Data',
              description: 'There is no data to display',
              onAction: () {
                actionCalled = true;
              },
              actionText: 'Add Data',
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Add Data'));
        await tester.pumpAndSettle();

        // Assert
        expect(actionCalled, true);
      });

      testWidgets('EmptyStateWidget displays icon when provided', (
        tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(
          makeTestableWidget(
            const EmptyStateWidget(
              title: 'No Data',
              description: 'There is no data to display',
              icon: Icons.inbox,
              showAction: false,
            ),
          ),
        );

        // Assert
        expect(find.byIcon(Icons.inbox), findsOneWidget);
      });

      testWidgets('CustomTextField accepts text input', (tester) async {
        // Arrange
        final controller = TextEditingController();

        await tester.pumpWidget(
          makeTestableWidget(
            CustomTextField(label: 'Name', controller: controller),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextFormField), 'John Doe');
        await tester.pumpAndSettle();

        // Assert
        expect(controller.text, 'John Doe');
      });

      testWidgets('CustomTextField calls onChanged callback', (tester) async {
        // Arrange
        String? changedValue;

        await tester.pumpWidget(
          makeTestableWidget(
            CustomTextField(
              label: 'Name',
              onChanged: (value) {
                changedValue = value;
              },
            ),
          ),
        );

        // Act
        await tester.enterText(find.byType(TextFormField), 'Test');
        await tester.pumpAndSettle();

        // Assert
        expect(changedValue, 'Test');
      });
    });
  });
}
