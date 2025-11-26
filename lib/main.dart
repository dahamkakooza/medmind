import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
import 'features/dashboard/presentation/pages/dashboard_page.dart';

// Repository implementations
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/medication/data/repositories/medication_repository_impl.dart';
import 'features/adherence/data/repositories/adherence_repository_impl.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';

// Data sources
import 'features/medication/data/datasources/medication_remote_data_source.dart';
import 'features/adherence/data/datasources/adherence_remote_data_source.dart';
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';

// Use cases
import 'features/auth/domain/usecases/sign_in_with_email_and_password.dart';
import 'features/auth/domain/usecases/sign_in_with_google.dart';
import 'features/auth/domain/usecases/sign_up.dart';
import 'features/auth/domain/usecases/sign_out.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await FirebaseConfig.initialize();

    // Initialize notifications
    await NotificationUtils.initialize();

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
              case '/dashboard':
                return MaterialPageRoute(builder: (_) => const DashboardPage());
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
