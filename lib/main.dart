import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Core imports
import 'core/theme/app_theme.dart';
import 'core/utils/notification_utils.dart';
import 'config/firebase_config.dart';

// Feature imports - Auth
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/auth/presentation/blocs/auth_event.dart';
import 'features/auth/presentation/blocs/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';

// Feature imports - Dashboard
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/dashboard/presentation/blocs/dashboard_bloc/dashboard_bloc.dart';

// Feature imports - Medication
import 'features/medication/presentation/pages/medication_list_page.dart';
import 'features/medication/presentation/pages/add_medication_page.dart';
import 'features/medication/presentation/pages/medication_detail_page.dart';
import 'features/medication/presentation/blocs/medication_bloc/medication_bloc.dart';
import 'features/medication/domain/entities/medication_entity.dart';

// Feature imports - Adherence
import 'features/adherence/presentation/pages/adherence_history_page.dart';
import 'features/adherence/presentation/pages/adherence_analytics_page.dart';
import 'features/adherence/presentation/blocs/adherence_bloc/adherence_bloc.dart';

// Feature imports - Profile
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/profile/presentation/pages/about_page.dart';
import 'features/profile/presentation/pages/help_support_page.dart';
import 'features/profile/presentation/pages/privacy_security_page.dart';
import 'features/profile/presentation/pages/settings_page.dart';
import 'features/profile/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'features/profile/presentation/blocs/profile_bloc/profile_event.dart';
import 'features/profile/presentation/blocs/profile_bloc/profile_state.dart'
    as profile_state;

// Feature imports - Notifications
import 'features/notifications/presentation/pages/notification_test_page.dart';
import 'features/medication/presentation/pages/pending_doses_page.dart';

// Repository implementations
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/medication/data/repositories/medication_repository_impl.dart';
import 'features/adherence/data/repositories/adherence_repository_impl.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';

// Data sources
import 'features/medication/data/datasources/medication_remote_data_source.dart';
import 'features/adherence/data/datasources/adherence_remote_data_source.dart';
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'features/profile/data/datasources/profile_local_data_source.dart';

// Use cases - Auth
import 'features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/domain/usecases/sign_out.dart';

// Use cases - Dashboard
import 'features/dashboard/domain/usecases/get_today_medications.dart';
import 'features/dashboard/domain/usecases/get_adherence_stats.dart';
import 'features/dashboard/domain/usecases/log_medication_taken.dart';

// Use cases - Medication
import 'features/medication/domain/usecases/get_medications.dart';
import 'features/medication/domain/usecases/add_medication.dart';
import 'features/medication/domain/usecases/update_medication.dart';
import 'features/medication/domain/usecases/delete_medication.dart';

// Use cases - Adherence
import 'features/adherence/domain/usecases/get_adherence_logs.dart';
import 'features/adherence/domain/usecases/get_adherence_summary.dart';
import 'features/adherence/domain/usecases/log_medication_taken.dart'
    as adherence_log;
import 'features/adherence/domain/usecases/export_adherence_data.dart';

// Use cases - Profile
import 'features/profile/domain/usecases/get_user_preferences.dart';
import 'features/profile/domain/usecases/save_user_preferences.dart';
import 'features/profile/domain/usecases/update_theme_mode.dart';
import 'features/profile/domain/usecases/update_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await FirebaseConfig.initialize();

    // Initialize timezone data for notifications
    tz.initializeTimeZones();
    // Use device's local timezone
    final String timeZoneName = DateTime.now().timeZoneName;
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print('📍 Using timezone: $timeZoneName');
    } catch (e) {
      // Fallback to UTC if device timezone not found
      tz.setLocalLocation(tz.UTC);
      print('⚠️ Could not find timezone $timeZoneName, using UTC');
    }

    // Initialize notifications
    await NotificationUtils.initialize();
    await NotificationUtils.requestPermissions();

    // Get SharedPreferences instance
    final sharedPreferences = await SharedPreferences.getInstance();

    runApp(MedMindApp(sharedPreferences: sharedPreferences));
  } catch (e) {
    // If Firebase initialization fails, still run the app but show error
    print('Firebase initialization failed: $e');
    final sharedPreferences = await SharedPreferences.getInstance();
    runApp(
      MedMindApp(
        sharedPreferences: sharedPreferences,
        initializationError: e.toString(),
      ),
    );
  }
}

class MedMindApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final String? initializationError;

  const MedMindApp({
    super.key,
    required this.sharedPreferences,
    this.initializationError,
  });

  static Locale _getLocaleFromLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'spanish':
      case 'es':
        return const Locale('es', 'ES');
      case 'french':
      case 'fr':
        return const Locale('fr', 'FR');
      case 'english':
      case 'en':
      default:
        return const Locale('en', 'US');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Initialize repositories with Firebase instances
        RepositoryProvider<AuthRepositoryImpl>(
          create: (context) => AuthRepositoryImpl(
            firebaseAuth: FirebaseAuth.instance,
            firestore: FirebaseFirestore.instance,
            sharedPreferences: sharedPreferences,
          ),
        ),
        RepositoryProvider<MedicationRepositoryImpl>(
          create: (context) => MedicationRepositoryImpl(
            remoteDataSource: MedicationRemoteDataSourceImpl(
              firestore: FirebaseFirestore.instance,
              firebaseAuth: FirebaseAuth.instance,
            ),
            firebaseAuth: FirebaseAuth.instance,
          ),
        ),
        RepositoryProvider<AdherenceRepositoryImpl>(
          create: (context) => AdherenceRepositoryImpl(
            remoteDataSource: AdherenceRemoteDataSourceImpl(
              firestore: FirebaseFirestore.instance,
              firebaseAuth: FirebaseAuth.instance,
            ),
            firebaseAuth: FirebaseAuth.instance,
          ),
        ),
        RepositoryProvider<DashboardRepositoryImpl>(
          create: (context) => DashboardRepositoryImpl(
            remoteDataSource: DashboardRemoteDataSourceImpl(
              firestore: FirebaseFirestore.instance,
              firebaseAuth: FirebaseAuth.instance,
            ),
            firebaseAuth: FirebaseAuth.instance,
          ),
        ),
        RepositoryProvider<ProfileRepositoryImpl>(
          create: (context) => ProfileRepositoryImpl(
            localDataSource: ProfileLocalDataSourceImpl(
              sharedPreferences: sharedPreferences,
            ),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) {
              final authRepo = context.read<AuthRepositoryImpl>();
              return AuthBloc(
                signInWithEmailAndPassword: SignInWithEmailAndPassword(
                  authRepo,
                ),
                signInWithGoogle: SignInWithGoogle(authRepo),
                signUp: SignUp(authRepo),
                signOut: SignOut(authRepo),
              )..add(AuthCheckRequested());
            },
          ),
          BlocProvider<AdherenceBloc>(
            create: (context) {
              final adherenceRepo = context.read<AdherenceRepositoryImpl>();
              return AdherenceBloc(
                getAdherenceLogs: GetAdherenceLogs(adherenceRepo),
                getAdherenceSummary: GetAdherenceSummary(adherenceRepo),
                logMedicationTaken: adherence_log.LogMedicationTaken(
                  adherenceRepo,
                ),
                exportAdherenceData: ExportAdherenceData(adherenceRepo),
              );
            },
          ),
          BlocProvider<DashboardBloc>(
            create: (context) {
              final dashboardRepo = context.read<DashboardRepositoryImpl>();
              final authRepo = context.read<AuthRepositoryImpl>();
              final adherenceBloc = context.read<AdherenceBloc>();
              return DashboardBloc(
                getTodayMedications: GetTodayMedications(dashboardRepo),
                getAdherenceStats: GetAdherenceStats(dashboardRepo),
                logMedicationTaken: LogMedicationTaken(dashboardRepo),
                authRepository: authRepo,
                adherenceBloc: adherenceBloc,
              );
            },
          ),
          BlocProvider<MedicationBloc>(
            create: (context) {
              final medicationRepo = context.read<MedicationRepositoryImpl>();
              return MedicationBloc(
                getMedications: GetMedications(medicationRepo),
                addMedication: AddMedication(medicationRepo),
                updateMedication: UpdateMedication(medicationRepo),
                deleteMedication: DeleteMedication(medicationRepo),
              );
            },
          ),
          BlocProvider<ProfileBloc>(
            create: (context) {
              final profileRepo = context.read<ProfileRepositoryImpl>();
              return ProfileBloc(
                getUserPreferences: GetUserPreferences(profileRepo),
                saveUserPreferences: SaveUserPreferences(profileRepo),
                updateThemeMode: UpdateThemeMode(profileRepo),
                updateNotifications: UpdateNotifications(profileRepo),
              )..add(LoadPreferences()); // Load preferences on app start
            },
          ),
        ],
        child: BlocBuilder<ProfileBloc, profile_state.ProfileState>(
          builder: (context, profileState) {
            // Extract theme mode from profile state
            ThemeMode themeMode = ThemeMode.system;
            if (profileState is profile_state.PreferencesLoaded) {
              themeMode = profileState.preferences.themeMode;
            } else if (profileState is profile_state.PreferencesUpdated) {
              themeMode = profileState.preferences.themeMode;
            }

            // Extract locale from profile state
            Locale locale = const Locale('en', 'US');
            if (profileState is profile_state.PreferencesLoaded) {
              locale = _getLocaleFromLanguage(
                profileState.preferences.language,
              );
            } else if (profileState is profile_state.PreferencesUpdated) {
              locale = _getLocaleFromLanguage(
                profileState.preferences.language,
              );
            }

            return MaterialApp(
              title: 'MedMind',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              locale: locale,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('en', 'US'), // English
                Locale('es', 'ES'), // Spanish
                Locale('fr', 'FR'), // French
              ],
              home: initializationError != null
                  ? ErrorScreen(error: initializationError!)
                  : const AuthWrapper(),
              onGenerateRoute: (settings) {
                // Handle navigation routes
                switch (settings.name) {
                  // Auth routes
                  case '/login':
                    return MaterialPageRoute(builder: (_) => const LoginPage());
                  case '/register':
                    return MaterialPageRoute(
                      builder: (_) => const RegisterPage(),
                    );
                  case '/forgot-password':
                    return MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: const Text('Reset Password')),
                        body: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'Password reset functionality coming soon!\n\nFor now, you can reset your password through Firebase Console.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    );

                  // Dashboard route
                  case '/dashboard':
                    return MaterialPageRoute(
                      builder: (_) => const DashboardPage(),
                    );

                  // Medication routes
                  case '/medications':
                    return MaterialPageRoute(
                      builder: (_) => const MedicationListPage(),
                    );
                  case '/add-medication':
                    return MaterialPageRoute(
                      builder: (_) => const AddMedicationPage(),
                    );
                  case '/edit-medication':
                    final medication = settings.arguments;
                    if (medication != null) {
                      return MaterialPageRoute(
                        builder: (_) => AddMedicationPage(
                          medication: medication as MedicationEntity,
                        ),
                      );
                    }
                    return null;
                  case '/medication-detail':
                    final medication = settings.arguments;
                    if (medication != null) {
                      return MaterialPageRoute(
                        builder: (_) => MedicationDetailPage(
                          medication: medication as dynamic,
                        ),
                      );
                    }
                    return null;

                  // Adherence routes
                  case '/adherence-history':
                    return MaterialPageRoute(
                      builder: (_) => const AdherenceHistoryPage(),
                    );
                  case '/adherence-analytics':
                    return MaterialPageRoute(
                      builder: (_) => const AdherenceAnalyticsPage(),
                    );

                  // Profile routes
                  case '/profile':
                    return MaterialPageRoute(
                      builder: (_) => const ProfilePage(),
                    );
                  case '/profile/edit':
                    return MaterialPageRoute(
                      builder: (_) => const EditProfilePage(),
                    );
                  case '/profile/notifications':
                    return MaterialPageRoute(
                      builder: (_) => const NotificationTestPage(),
                    );
                  case '/profile/privacy-security':
                    return MaterialPageRoute(
                      builder: (_) => const PrivacySecurityPage(),
                    );
                  case '/profile/help-support':
                    return MaterialPageRoute(
                      builder: (_) => const HelpSupportPage(),
                    );
                  case '/profile/about':
                    return MaterialPageRoute(builder: (_) => const AboutPage());
                  case '/settings':
                    return MaterialPageRoute(
                      builder: (_) => const SettingsPage(),
                    );

                  // Notifications
                  case '/notifications':
                    return MaterialPageRoute(
                      builder: (_) => const NotificationTestPage(),
                    );

                  // Pending Doses
                  case '/pending-doses':
                    return MaterialPageRoute(
                      builder: (_) => const PendingDosesPage(),
                    );

                  default:
                    return null;
                }
              },
            );
          },
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const SplashScreen();
        } else if (state is Authenticated) {
          return const DashboardPage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 80, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'MedMind',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your Medication Companion',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;

  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 24),
              const Text(
                'Initialization Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to initialize the app. Please check your Firebase configuration.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red.shade700),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error,
                  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Restart the app
                  main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
