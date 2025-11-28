
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide RouterConfig;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
<<<<<<< HEAD
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
import 'features/profile/presentation/blocs/profile_bloc/profile_bloc.dart';

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
=======

// Core imports
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/constants/route_constants.dart';
import 'core/utils/notification_utils.dart';

// Configuration
import 'config/router_config.dart';

// Service Locator
import 'features/adherence/presentation/blocs/adherence_bloc/adherence_bloc.dart';
import 'features/auth/presentation/blocs/auth_bloc.dart';
import 'features/auth/presentation/blocs/auth_event.dart';
import 'features/dashboard/presentation/blocs/dashboard_bloc/dashboard_bloc.dart';
import 'features/medication/presentation/blocs/barcode_bloc/barcode_bloc.dart';
import 'features/medication/presentation/blocs/medication_bloc/medication_bloc.dart';
import 'features/profile/presentation/blocs/profile_bloc/profile_bloc.dart';
import 'injection_container.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Configure dependency injection
  configureDependencies();

  // Initialize core services
  await _initializeCoreServices();

  runApp(const MedMindApp());
}

class MedMindApp extends StatelessWidget {
  const MedMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth BLoC
        BlocProvider(create: (context) => getIt<AuthBloc>()..add(AuthCheckRequested())),

        // Medication BLoC
        BlocProvider(create: (context) => getIt<MedicationBloc>()),

        // Dashboard BLoC
        BlocProvider(create: (context) => getIt<DashboardBloc>()),

        // Profile BLoC
        BlocProvider(create: (context) => getIt<ProfileBloc>()),

        // Adherence BLoC
        BlocProvider(create: (context) => getIt<AdherenceBloc>()),

        // Barcode BLoC
        BlocProvider(create: (context) => getIt<BarcodeBloc>()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RouterConfig.generateRoute,
        initialRoute: RouteConstants.splash,
        navigatorKey: getIt<GlobalKey<NavigatorState>>(),
>>>>>>> 834de40 (added some more pages in profile)
      ),
    );
  }
}

<<<<<<< HEAD
class MedMindApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;
  final String? initializationError;

  const MedMindApp({
    super.key,
    required this.sharedPreferences,
    this.initializationError,
  });

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
              );
            },
          ),
        ],
        child: MaterialApp(
          title: 'MedMind',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
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
                return MaterialPageRoute(builder: (_) => const RegisterPage());
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
                return MaterialPageRoute(builder: (_) => const DashboardPage());

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
                    builder: (_) =>
                        MedicationDetailPage(medication: medication as dynamic),
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
                return MaterialPageRoute(builder: (_) => const ProfilePage());
              case '/settings':
                return MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: AppBar(title: const Text('Settings')),
                    body: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'Settings page coming soon!',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
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
