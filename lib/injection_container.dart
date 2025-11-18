import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  
  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn(
    clientId: '456707171572-es72fgb189m2bjmomaiml0vn0evd4tvs.apps.googleusercontent.com',
  ));

  getIt.init();
}
