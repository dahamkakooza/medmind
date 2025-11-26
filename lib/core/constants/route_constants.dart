// class RouteConstants {
//   // Authentication Routes
//   static const String splash = '/';
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String forgotPassword = '/forgot-password';
//
//   // Main App Routes
//   static const String dashboard = '/dashboard';
//   static const String medicationList = '/medications';
//   static const String addMedication = '/medications/add';
//   static const String medicationDetail = '/medications/:id';
//   static const String adherenceHistory = '/adherence/history';
//   static const String adherenceAnalytics = '/adherence/analytics';
//   static const String profile = '/profile';
//   static const String settings = '/settings';
//
//   static String? get notifications => null;
//
//   // Helper method to generate medication detail route
//   static String medicationDetailPath(String medicationId) {
//     return '/medications/$medicationId';
//   }
// }
class RouteConstants {
  // Authentication Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main App Routes
  static const String dashboard = '/dashboard';
  static const String medicationList = '/medications';
  static const String addMedication = '/add-medication';
  static const String medicationDetail = '/medications/:id';
  static const String adherenceHistory = '/adherence-history';
  static const String adherenceAnalytics = '/adherence/analytics';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  // Profile Sub-routes - ADD THESE MISSING CONSTANTS
  static const String editProfile = '/edit-profile';
  static const String privacySecurity = '/privacy-security';
  static const String helpSupport = '/help-support';
  static const String about = '/about';

  // Helper method to generate medication detail route
  static String medicationDetailPath(String medicationId) {
    return '/medications/$medicationId';
  }
}