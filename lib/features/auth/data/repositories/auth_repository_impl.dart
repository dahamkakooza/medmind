// import 'package:dartz/dartz.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:injectable/injectable.dart';
// import '../../../../core/errors/failures.dart';
// import '../../domain/entities/user_entity.dart';
// import '../../domain/repositories/auth_repository.dart';
//
// @LazySingleton(as: AuthRepository)
// class AuthRepositoryImpl implements AuthRepository {
//   final FirebaseAuth _firebaseAuth;
//   final GoogleSignIn _googleSignIn;
//
//   AuthRepositoryImpl(this._firebaseAuth, this._googleSignIn);
//
//   @override
//   Stream<UserEntity> get user {
//     return _firebaseAuth.authStateChanges().asyncMap((user) {
//       if (user == null) return UserEntity.empty;
//       return UserEntity.fromFirebaseUser(user);
//     });
//   }
//
//   @override
//   UserEntity get currentUser {
//     final user = _firebaseAuth.currentUser;
//     return user == null ? UserEntity.empty : UserEntity.fromFirebaseUser(user);
//   }
//
//   @override
//   Future<UserEntity?> getCurrentUser() async {
//     final user = _firebaseAuth.currentUser;
//     return user == null ? null : UserEntity.fromFirebaseUser(user);
//   }
//
//   @override
//   Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return Right(UserEntity.fromFirebaseUser(userCredential.user!));
//     } on FirebaseAuthException catch (e) {
//       return Left(AuthFailure(message: e.message ?? 'Authentication failed'));
//     } catch (e) {
//       return Left(AuthFailure(message: 'An unexpected error occurred'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
//     required String email,
//     required String password,
//     required String displayName,
//   }) async {
//     try {
//       final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       // Update display name
//       await userCredential.user?.updateDisplayName(displayName);
//       await userCredential.user?.reload();
//
//       return Right(UserEntity.fromFirebaseUser(userCredential.user!));
//     } on FirebaseAuthException catch (e) {
//       return Left(AuthFailure(message: e.message ?? 'Registration failed'));
//     } catch (e) {
//       return Left(AuthFailure(message: 'An unexpected error occurred'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, UserEntity>> signInWithGoogle() async {
//     try {
//       final googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         return Left(AuthFailure(message: 'Google Sign-In cancelled'));
//       }
//
//       final googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       final userCredential = await _firebaseAuth.signInWithCredential(credential);
//       return Right(UserEntity.fromFirebaseUser(userCredential.user!));
//     } on FirebaseAuthException catch (e) {
//       return Left(AuthFailure(message: e.message ?? 'Google Sign-In failed'));
//     } catch (e) {
//       return Left(AuthFailure(message: 'Google Sign-In failed: $e'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> signOut() async {
//     try {
//       await _googleSignIn.signOut();
//       await _firebaseAuth.signOut();
//       return const Right(null);
//     } catch (e) {
//       return Left(AuthFailure(message: 'Sign out failed'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
//     try {
//       await _firebaseAuth.sendPasswordResetEmail(email: email);
//       return const Right(null);
//     } on FirebaseAuthException catch (e) {
//       return Left(AuthFailure(message: e.message ?? 'Password reset failed'));
//     } catch (e) {
//       return Left(AuthFailure(message: 'An unexpected error occurred'));
//     }
//   }
//
//   @override
//   Future<Either<Failure, void>> sendEmailVerification() async {
//     try {
//       await _firebaseAuth.currentUser?.sendEmailVerification();
//       return const Right(null);
//     } catch (e) {
//       return Left(AuthFailure(message: 'Email verification failed'));
//     }
//   }
//
//   @override
//   bool get isSignedIn => _firebaseAuth.currentUser != null;
//
//   @override
//   Future<Either<Failure, void>> reloadUser() async {
//     try {
//       await _firebaseAuth.currentUser?.reload();
//       return const Right(null);
//     } catch (e) {
//       return Left(AuthFailure(message: 'Failed to reload user'));
//     }
//   }
// }
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl(this._firebaseAuth, this._googleSignIn);

  @override
  Stream<UserEntity> get user {
    return _firebaseAuth.authStateChanges().asyncMap((user) {
      if (user == null) return UserEntity.empty;
      return UserEntity.fromFirebaseUser(user);
    });
  }

  @override
  UserEntity get currentUser {
    final user = _firebaseAuth.currentUser;
    return user == null ? UserEntity.empty : UserEntity.fromFirebaseUser(user);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      print('🔍 AuthRepository - Firebase currentUser: $user');
      print('🔍 AuthRepository - Firebase user UID: ${user?.uid}');

      if (user != null) {
        // Force token refresh to ensure it's valid
        await user.getIdToken(true);
        print('✅ AuthRepository - User token refreshed: ${user.uid}');
        return UserEntity.fromFirebaseUser(user);
      }

      print('❌ AuthRepository - No current user found');
      return null;
    } catch (e) {
      print('❌ AuthRepository - Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(UserEntity.fromFirebaseUser(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? 'Authentication failed'));
    } catch (e) {
      return Left(AuthFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();

      return Right(UserEntity.fromFirebaseUser(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? 'Registration failed'));
    } catch (e) {
      return Left(AuthFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Left(AuthFailure(message: 'Google Sign-In cancelled'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return Right(UserEntity.fromFirebaseUser(userCredential.user!));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? 'Google Sign-In failed'));
    } catch (e) {
      return Left(AuthFailure(message: 'Google Sign-In failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: 'Sign out failed'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(message: e.message ?? 'Password reset failed'));
    } catch (e) {
      return Left(AuthFailure(message: 'An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: 'Email verification failed'));
    }
  }

  @override
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  @override
  Future<Either<Failure, void>> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: 'Failed to reload user'));
    }
  }
}