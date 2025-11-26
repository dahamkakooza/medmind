import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final SharedPreferences _sharedPreferences;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required SharedPreferences sharedPreferences,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _sharedPreferences = sharedPreferences,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<UserEntity> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser != null) {
        return UserEntity(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? '',
          dateJoined: firebaseUser.metadata.creationTime ?? DateTime.now(),
          emailVerified: firebaseUser.emailVerified,
        );
      } else {
        return UserEntity.empty;
      }
    });
  }

  @override
  UserEntity get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      return UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        dateJoined: firebaseUser.metadata.creationTime ?? DateTime.now(),
        emailVerified: firebaseUser.emailVerified,
      );
    } else {
      return UserEntity.empty;
    }
  }

  @override
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = UserEntity(
          id: credential.user!.uid,
          email: credential.user!.email ?? '',
          displayName: credential.user!.displayName ?? '',
          dateJoined: credential.user!.metadata.creationTime ?? DateTime.now(),
          emailVerified: credential.user!.emailVerified,
        );

        // Save user data to Firestore
        await _saveUserToFirestore(user);

        return Right(user);
      } else {
        return const Left(AuthenticationFailure(message: 'Sign in failed'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(displayName);

        final user = UserEntity(
          id: credential.user!.uid,
          email: credential.user!.email ?? '',
          displayName: displayName,
          dateJoined: credential.user!.metadata.creationTime ?? DateTime.now(),
          emailVerified: credential.user!.emailVerified,
        );

        // Save user data to Firestore
        await _saveUserToFirestore(user);

        // Send email verification
        await credential.user!.sendEmailVerification();

        return Right(user);
      } else {
        return const Left(AuthenticationFailure(message: 'Sign up failed'));
      }
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.signIn();
      } catch (e) {
        return Left(
          AuthenticationFailure(message: 'Google sign-in failed: $e'),
        );
      }

      if (googleUser == null) {
        return const Left(
          AuthenticationFailure(message: 'Google sign-in was cancelled'),
        );
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        return const Left(
          AuthenticationFailure(message: 'Google sign-in failed'),
        );
      }

      final firebaseUser = userCredential.user!;
      final user = UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        dateJoined: firebaseUser.metadata.creationTime ?? DateTime.now(),
        emailVerified: firebaseUser.emailVerified,
      );

      await _saveUserToFirestore(user);
      return Right(user);
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        return const Right(null);
      } else {
        return const Left(AuthenticationFailure(message: 'No user logged in'));
      }
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reloadUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.reload();
        return const Right(null);
      }
      return const Left(AuthenticationFailure(message: 'No user logged in'));
    } catch (e) {
      return Left(AuthenticationFailure(message: e.toString()));
    }
  }

  /// Save user data to Firestore
  Future<void> _saveUserToFirestore(UserEntity user) async {
    try {
      await _firestore.collection('users').doc(user.id).set({
        'email': user.email,
        'displayName': user.displayName,
        'dateJoined': Timestamp.fromDate(user.dateJoined),
        'emailVerified': user.emailVerified,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      // Log error but don't fail the authentication
      print('Failed to save user to Firestore: $e');
    }
  }

  /// Map Firebase Auth exceptions to custom failures
  Failure _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const AuthenticationFailure(
          message: 'No user found with this email.',
        );
      case 'wrong-password':
        return const AuthenticationFailure(message: 'Wrong password provided.');
      case 'email-already-in-use':
        return const AuthenticationFailure(
          message: 'An account already exists with this email.',
        );
      case 'weak-password':
        return const ValidationFailure(
          message: 'The password provided is too weak.',
        );
      case 'invalid-email':
        return const ValidationFailure(
          message: 'The email address is not valid.',
        );
      case 'user-disabled':
        return const AuthenticationFailure(
          message: 'This user account has been disabled.',
        );
      case 'too-many-requests':
        return const AuthenticationFailure(
          message: 'Too many requests. Try again later.',
        );
      case 'network-request-failed':
        return const NetworkFailure(
          message: 'Network error. Please check your connection.',
        );
      default:
        return AuthenticationFailure(
          message: e.message ?? 'Authentication failed.',
        );
    }
  }
}
