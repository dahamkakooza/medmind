import 'package:flutter/material.dart';
import 'package:medmind/core/constants/route_constants.dart';

// Authentication pages
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';

// Dashboard pages
import '../features/dashboard/presentation/pages/dashboard_page.dart';

// Medication pages
import '../features/medication/presentation/pages/medication_list_page.dart';
import '../features/medication/presentation/pages/add_medication_page.dart';

// Profile pages
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/settings_page.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';
import '../features/profile/presentation/pages/privacy_security_page.dart';
import '../features/profile/presentation/pages/help_support_page.dart';
import '../features/profile/presentation/pages/about_page.dart';

// Adherence pages
import '../features/adherence/presentation/pages/adherence_history_page.dart';
import '../features/adherence/presentation/pages/adherence_analytics_page.dart';

// Notification pages
import '../features/notification/presentation/pages/notifications_page.dart';

class RouterConfig {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
    // Authentication routes
      case RouteConstants.splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case RouteConstants.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case RouteConstants.register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case RouteConstants.forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

    // Main app routes
      case RouteConstants.dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardPage());
      case RouteConstants.medicationList:
        return MaterialPageRoute(builder: (_) => const MedicationListPage());
      case RouteConstants.addMedication:
        return MaterialPageRoute(builder: (_) => const AddMedicationPage());
      case RouteConstants.profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case RouteConstants.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case RouteConstants.adherenceHistory:
        return MaterialPageRoute(builder: (_) => const AdherenceHistoryPage());
      case RouteConstants.adherenceAnalytics:
        return MaterialPageRoute(builder: (_) => const AdherenceAnalyticsPage());
      case RouteConstants.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());

    // Profile sub-routes - ADD THESE MISSING CASES
      case RouteConstants.editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      case RouteConstants.privacySecurity:
        return MaterialPageRoute(builder: (_) => const PrivacySecurityPage());
      case RouteConstants.helpSupport:
        return MaterialPageRoute(builder: (_) => const HelpSupportPage());
      case RouteConstants.about:
        return MaterialPageRoute(builder: (_) => const AboutPage());

      default:
        return _errorRoute(settings.name);
    }
  }

  static Route<dynamic> _errorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text('Route $routeName not found'),
        ),
      ),
    );
  }
}