import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart' hide RouterConfig;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'features/profile/presentation/blocs/profile_bloc/profile_event.dart';
import 'features/profile/presentation/blocs/profile_bloc/profile_state.dart';
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
        BlocProvider(create: (context) => getIt<ProfileBloc>()..add(LoadPreferences())), // ✅ Load preferences on startup

        // Adherence BLoC
        BlocProvider(create: (context) => getIt<AdherenceBloc>()),

        // Barcode BLoC
        BlocProvider(create: (context) => getIt<BarcodeBloc>()),
      ],
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          // Determine current theme based on preferences
          ThemeMode currentThemeMode = ThemeMode.system;

          if (state is PreferencesLoaded) {
            currentThemeMode = state.preferences.themeMode;
            print('🎨 App theme updated to: ${state.preferences.themeMode}');
          } else if (state is PreferencesUpdated) {
            currentThemeMode = state.preferences.themeMode;
            print('🎨 App theme updated to: ${state.preferences.themeMode}');
          }

          return MaterialApp(
            title: AppConstants.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: currentThemeMode, // ✅ Dynamic theme that updates
            debugShowCheckedModeBanner: false,
            onGenerateRoute: RouterConfig.generateRoute,
            initialRoute: RouteConstants.splash,
            navigatorKey: getIt<GlobalKey<NavigatorState>>(),
          );
        },
      ),
    );
  }
}

/// Core service initialization
Future<void> _initializeCoreServices() async {
  try {
    // Initialize Firebase with manual configuration
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyC_b2w_sJ7_JJRWcoxqcDv1g_hHj0nS8Ew",
        appId: "1:257346834376:android:7c186269d766fe4d9b7afd",
        messagingSenderId: "257346834376",
        projectId: "medmind-ca71d",
        storageBucket: "medmind-ca71d.firebasestorage.app",
      ),
    );

    // ADDED: Enable Firebase Auth persistence
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    print('✅ Firebase initialized successfully with project: medmind-ca71d');
    print('✅ Firebase Auth persistence enabled');

  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    // Fallback to automatic initialization
    try {
      await Firebase.initializeApp();
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
      print('✅ Firebase auto-initialization successful');
    } catch (e2) {
      print('❌ Firebase auto-initialization also failed: $e2');
      // Continue without Firebase - the app will still work in demo mode
    }
  }

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);

  // Initialize notifications
  await NotificationUtils.initialize();

  // Register global keys
  getIt.registerLazySingleton(() => GlobalKey<NavigatorState>());
}