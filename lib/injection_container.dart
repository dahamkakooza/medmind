//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:get_it/get_it.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:injectable/injectable.dart';
// import 'injection_container.config.dart'; // CORRECT FILENAME
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
//   GoogleSignIn get googleSignIn => GoogleSignIn(
//     // clientId: '456707171572-es72fgb189m2bjmomaiml0vn0evd4tvs.apps.googleusercontent.com',
//   );
// }
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'injection_container.config.dart';

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
}