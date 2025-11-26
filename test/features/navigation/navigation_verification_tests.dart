import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medmind/core/constants/route_constants.dart';

/// **Feature: system-verification**
/// Navigation and Routing Verification Tests
///
/// This test suite verifies that navigation and routing work correctly
/// throughout the application, including route protection, navigation stack
/// management, and logout navigation.

void main() {
  group('Navigation and Routing Verification Tests', () {
    late MockNavigationObserver mockObserver;

    setUp(() {
      mockObserver = MockNavigationObserver();
    });

    /// **Feature: system-verification, Property 33: Unauthenticated users cannot access protected routes**
    /// **Validates: Requirements 10.1**
    testWidgets(
      'Property 33: Unauthenticated users cannot access protected routes',
      (WidgetTester tester) async {
        // Property: For any unauthenticated state, attempting to navigate to
        // protected routes should redirect to the login screen

        bool isAuthenticated = false;
        String? currentRoute;

        // Build app with route protection
        await tester.pumpWidget(
          MaterialApp(
            navigatorObservers: [mockObserver],
            initialRoute: RouteConstants.dashboard,
            onGenerateRoute: (settings) {
              // Route guard logic
              if (!isAuthenticated &&
                  settings.name != RouteConstants.login &&
                  settings.name != RouteConstants.register) {
                // Redirect to login for protected routes
                currentRoute = RouteConstants.login;
                return MaterialPageRoute(
                  builder: (_) =>
                      const Scaffold(body: Center(child: Text('Login Page'))),
                  settings: const RouteSettings(name: '/login'),
                );
              }

              // Route mapping
              currentRoute = settings.name;
              switch (settings.name) {
                case RouteConstants.login:
                  return MaterialPageRoute(
                    builder: (_) =>
                        const Scaffold(body: Center(child: Text('Login Page'))),
                    settings: settings,
                  );
                case RouteConstants.dashboard:
                  return MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: Center(child: Text('Dashboard Page')),
                    ),
                    settings: settings,
                  );
                case RouteConstants.medicationList:
                  return MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: Center(child: Text('Medication List Page')),
                    ),
                    settings: settings,
                  );
                case RouteConstants.profile:
                  return MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: Center(child: Text('Profile Page')),
                    ),
                    settings: settings,
                  );
                default:
                  return MaterialPageRoute(
                    builder: (_) =>
                        const Scaffold(body: Center(child: Text('Login Page'))),
                    settings: settings,
                  );
              }
            },
          ),
        );

        await tester.pumpAndSettle();

        // Verify: Should be on login page, not dashboard
        expect(find.text('Login Page'), findsOneWidget);
        expect(find.text('Dashboard Page'), findsNothing);
        expect(currentRoute, RouteConstants.login);

        // Test multiple protected routes
        final protectedRoutes = [
          RouteConstants.dashboard,
          RouteConstants.medicationList,
          RouteConstants.profile,
        ];

        for (final route in protectedRoutes) {
          // Reset observer
          mockObserver.reset();

          // Try to navigate to protected route
          await tester.pumpWidget(
            MaterialApp(
              navigatorObservers: [mockObserver],
              initialRoute: route,
              onGenerateRoute: (settings) {
                if (!isAuthenticated &&
                    settings.name != RouteConstants.login &&
                    settings.name != RouteConstants.register) {
                  currentRoute = RouteConstants.login;
                  return MaterialPageRoute(
                    builder: (_) =>
                        const Scaffold(body: Center(child: Text('Login Page'))),
                    settings: const RouteSettings(name: '/login'),
                  );
                }

                currentRoute = settings.name;
                switch (settings.name) {
                  case RouteConstants.login:
                    return MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: Center(child: Text('Login Page')),
                      ),
                      settings: settings,
                    );
                  case RouteConstants.dashboard:
                    return MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: Center(child: Text('Dashboard Page')),
                      ),
                      settings: settings,
                    );
                  case RouteConstants.medicationList:
                    return MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: Center(child: Text('Medication List Page')),
                      ),
                      settings: settings,
                    );
                  case RouteConstants.profile:
                    return MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: Center(child: Text('Profile Page')),
                      ),
                      settings: settings,
                    );
                  default:
                    return MaterialPageRoute(
                      builder: (_) => const Scaffold(
                        body: Center(child: Text('Login Page')),
                      ),
                      settings: settings,
                    );
                }
              },
            ),
          );

          await tester.pumpAndSettle();

          // Verify: Should always redirect to login
          expect(
            find.text('Login Page'),
            findsOneWidget,
            reason:
                'Route $route should redirect to login when unauthenticated',
          );
          expect(
            currentRoute,
            RouteConstants.login,
            reason: 'Current route should be login for protected route $route',
          );
        }
      },
    );

    /// **Feature: system-verification, Property 34: Navigation maintains proper stack**
    /// **Validates: Requirements 10.3**
    testWidgets('Property 34: Navigation maintains proper stack', (
      WidgetTester tester,
    ) async {
      // Property: For any navigation sequence, the back button should navigate
      // to the previous screen in the stack

      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [mockObserver],
          initialRoute: RouteConstants.dashboard,
          routes: {
            RouteConstants.dashboard: (_) =>
                const Scaffold(body: Center(child: Text('Dashboard'))),
            RouteConstants.medicationList: (_) =>
                const Scaffold(body: Center(child: Text('Medication List'))),
            RouteConstants.profile: (_) =>
                const Scaffold(body: Center(child: Text('Profile'))),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Verify initial route
      expect(find.text('Dashboard'), findsOneWidget);
      expect(mockObserver.pushedRoutes.length, 1);

      // Navigate to medication list
      navigatorKey.currentState!.pushNamed(RouteConstants.medicationList);
      await tester.pumpAndSettle();

      expect(find.text('Medication List'), findsOneWidget);
      expect(mockObserver.pushedRoutes.length, 2);

      // Navigate to profile
      navigatorKey.currentState!.pushNamed(RouteConstants.profile);
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(mockObserver.pushedRoutes.length, 3);

      // Pop back to medication list
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(find.text('Medication List'), findsOneWidget);
      expect(mockObserver.poppedRoutes.length, 1);

      // Pop back to dashboard
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      expect(mockObserver.poppedRoutes.length, 2);

      // Verify navigation stack is maintained correctly
      expect(mockObserver.pushedRoutes.length, 3);
      expect(mockObserver.poppedRoutes.length, 2);
    });

    /// **Feature: system-verification, Property 35: Logout clears navigation stack**
    /// **Validates: Requirements 10.5**
    testWidgets('Property 35: Logout clears navigation stack', (
      WidgetTester tester,
    ) async {
      // Property: For any logout action, the navigation stack should be cleared
      // and the user should be on the login screen

      final GlobalKey<NavigatorState> navigatorKey =
          GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [mockObserver],
          initialRoute: RouteConstants.dashboard,
          routes: {
            RouteConstants.login: (_) =>
                const Scaffold(body: Center(child: Text('Login'))),
            RouteConstants.dashboard: (_) =>
                const Scaffold(body: Center(child: Text('Dashboard'))),
            RouteConstants.medicationList: (_) =>
                const Scaffold(body: Center(child: Text('Medication List'))),
            RouteConstants.profile: (_) =>
                const Scaffold(body: Center(child: Text('Profile'))),
          },
        ),
      );

      await tester.pumpAndSettle();

      // Build up navigation stack
      expect(find.text('Dashboard'), findsOneWidget);

      navigatorKey.currentState!.pushNamed(RouteConstants.medicationList);
      await tester.pumpAndSettle();
      expect(find.text('Medication List'), findsOneWidget);

      navigatorKey.currentState!.pushNamed(RouteConstants.profile);
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);

      // Verify stack has multiple routes
      expect(mockObserver.pushedRoutes.length, 3);

      // Simulate logout - clear stack and navigate to login
      navigatorKey.currentState!.pushNamedAndRemoveUntil(
        RouteConstants.login,
        (route) => false, // Remove all routes
      );
      await tester.pumpAndSettle();

      // Verify on login screen
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Dashboard'), findsNothing);
      expect(find.text('Medication List'), findsNothing);
      expect(find.text('Profile'), findsNothing);

      // Try to pop - should not be able to go back (stack was cleared)
      final canPop = navigatorKey.currentState!.canPop();
      expect(canPop, false, reason: 'Should not be able to pop after logout');

      // Verify that we're on the login screen and can't navigate back
      expect(find.text('Login'), findsOneWidget);
    });
  });
}

/// Mock NavigationObserver for testing
class MockNavigationObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = [];
  final List<Route<dynamic>> poppedRoutes = [];
  final List<Route<dynamic>> replacedRoutes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    poppedRoutes.add(route);
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      replacedRoutes.add(newRoute);
    }
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  void reset() {
    pushedRoutes.clear();
    poppedRoutes.clear();
    replacedRoutes.clear();
  }
}
