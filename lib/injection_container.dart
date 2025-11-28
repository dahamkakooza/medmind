// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get_it/get_it.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:injectable/injectable.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'injection_container.config.dart';
//
// // Add these Profile-related imports
// import 'features/profile/data/datasources/profile_local_data_source.dart';
// import 'features/profile/data/repositories/profile_repository_impl.dart';
// import 'features/profile/domain/repositories/profile_repository.dart';
// import 'features/profile/domain/usecases/get_user_preferences.dart';
// import 'features/profile/domain/usecases/save_user_preferences.dart';
// import 'features/profile/domain/usecases/update_theme_mode.dart';
// import 'features/profile/domain/usecases/update_notifications.dart';
// import 'features/profile/presentation/blocs/profile_bloc/profile_bloc.dart';
//
// final getIt = GetIt.instance;
//
// @InjectableInit(
//   initializerName: r'$initGetIt',
//   preferRelativeImports: true,
//   asExtension: false,
// )
// void configureDependencies() => $initGetIt(getIt);
//
// @module
// abstract class RegisterModule {
//   @lazySingleton
//   FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
//
//   @lazySingleton
//   GoogleSignIn get googleSignIn => GoogleSignIn();
//
//   // REMOVED: SharedPreferences registration (already in main.dart)
//   // Use the existing registration from main.dart instead
//
//   // Add ProfileLocalDataSource registration using existing SharedPreferences
//   @lazySingleton
//   ProfileLocalDataSource get profileLocalDataSource => ProfileLocalDataSourceImpl(
//     sharedPreferences: getIt<SharedPreferences>(), // Use existing registration
//   );
//
//   // Add ProfileRepository registration with required localDataSource
//   @lazySingleton
//   ProfileRepository get profileRepository => ProfileRepositoryImpl(
//     localDataSource: getIt<ProfileLocalDataSource>(),
//   );
//
//   // Add explicit registrations for Profile use cases
//   @lazySingleton
//   GetUserPreferences get getUserPreferences => GetUserPreferences(getIt<ProfileRepository>());
//
//   @lazySingleton
//   SaveUserPreferences get saveUserPreferences => SaveUserPreferences(getIt<ProfileRepository>());
//
//   @lazySingleton
//   UpdateThemeMode get updateThemeMode => UpdateThemeMode(getIt<ProfileRepository>());
//
//   @lazySingleton
//   UpdateNotifications get updateNotifications => UpdateNotifications(getIt<ProfileRepository>());
//
//   // Add ProfileBloc registration
//   @lazySingleton
//   ProfileBloc get profileBloc => ProfileBloc(
//     getUserPreferences: getIt<GetUserPreferences>(),
//     saveUserPreferences: getIt<SaveUserPreferences>(),
//     updateThemeMode: getIt<UpdateThemeMode>(),
//     updateNotifications: getIt<UpdateNotifications>(),
//   );
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'injection_container.config.dart';

// Add Auth Repository import
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';

// Add Profile-related imports
import 'features/profile/data/datasources/profile_local_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_user_preferences.dart';
import 'features/profile/domain/usecases/save_user_preferences.dart';
import 'features/profile/domain/usecases/update_theme_mode.dart';
import 'features/profile/domain/usecases/update_notifications.dart';
import 'features/profile/presentation/blocs/profile_bloc/profile_bloc.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
void configureDependencies() => $initGetIt(getIt);

@module
abstract class RegisterModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn();

  // Add AuthRepository registration
  @lazySingleton
  AuthRepository get authRepository => AuthRepositoryImpl(
    firebaseAuth: getIt<FirebaseAuth>(), // FIXED: Add required parameters
    googleSignIn: getIt<GoogleSignIn>(), // FIXED: Add required parameters
  );

  // Add ProfileLocalDataSource registration using existing SharedPreferences
  @lazySingleton
  ProfileLocalDataSource get profileLocalDataSource => ProfileLocalDataSourceImpl(
    sharedPreferences: getIt<SharedPreferences>(),
  );

  // Add ProfileRepository registration with required localDataSource
  @lazySingleton
  ProfileRepository get profileRepository => ProfileRepositoryImpl(
    localDataSource: getIt<ProfileLocalDataSource>(),
  );

  // Add explicit registrations for Profile use cases
  @lazySingleton
  GetUserPreferences get getUserPreferences => GetUserPreferences(getIt<ProfileRepository>());

  @lazySingleton
  SaveUserPreferences get saveUserPreferences => SaveUserPreferences(getIt<ProfileRepository>());

  @lazySingleton
  UpdateThemeMode get updateThemeMode => UpdateThemeMode(getIt<ProfileRepository>());

  @lazySingleton
  UpdateNotifications get updateNotifications => UpdateNotifications(getIt<ProfileRepository>());

  // Add ProfileBloc registration with authRepository
  @lazySingleton
  ProfileBloc get profileBloc => ProfileBloc(
    getUserPreferences: getIt<GetUserPreferences>(),
    saveUserPreferences: getIt<SaveUserPreferences>(),
    updateThemeMode: getIt<UpdateThemeMode>(),
    updateNotifications: getIt<UpdateNotifications>(),
    authRepository: getIt<AuthRepository>(), // FIXED: Add required authRepository
  );
}