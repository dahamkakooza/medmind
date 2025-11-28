import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  @override
  Stream<UserEntity> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser == null
          ? UserEntity.empty
          : UserEntity.fromFirebaseUser(firebaseUser); // FIXED: Use factory constructor
    });
  }

  @override
  UserEntity get currentUser {
    final user = _firebaseAuth.currentUser;
    return user == null
        ? UserEntity.empty
        : UserEntity.fromFirebaseUser(user); // FIXED: Use factory constructor
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
      return Right(UserEntity.fromFirebaseUser(userCredential.user!)); // FIXED
    } on FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e) {
      return Left(AuthFailure(message: 'Sign in failed: $e'));
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
      await userCredential.user!.updateDisplayName(displayName);

      return Right(UserEntity.fromFirebaseUser(userCredential.user!)); // FIXED
    } on FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e) {
      return Left(AuthFailure(message: 'Sign up failed: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return Left(AuthFailure(message: 'Google sign in cancelled'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      return Right(UserEntity.fromFirebaseUser(userCredential.user!)); // FIXED
    } on FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e) {
      return Left(AuthFailure(message: 'Google sign in failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(message: 'Sign out failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e) {
      return Left(AuthFailure(message: 'Password reset failed: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        return const Right(null);
      }
      return Left(AuthFailure(message: 'User not found or already verified'));
    } on FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e) {
      return Left(AuthFailure(message: 'Email verification failed: $e'));
    }
  }

  @override
  bool get isSignedIn => _firebaseAuth.currentUser != null;

  @override
  Future<Either<Failure, void>> reloadUser() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e) {
      return Left(AuthFailure(message: 'Failed to reload user: $e'));
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    return user == null ? null : UserEntity.fromFirebaseUser(user); // FIXED
  }

  // NEW: Password Change Method
  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Left(AuthFailure(message: 'No user signed in'));
      }

      if (user.email == null) {
        return Left(AuthFailure(message: 'User email not available'));
      }

      // Re-authenticate user before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e) {
      return Left(AuthFailure(message: 'Password change failed: $e'));
    }
  }

  // NEW: Two-Factor Authentication Method
  @override
  Future<Either<Failure, String>> enableTwoFactorAuth(String phoneNumber) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Left(AuthFailure(message: 'No user signed in'));
      }

      // This would integrate with your 2FA service
      // For now, simulate the process
      await Future.delayed(const Duration(seconds: 2));

      // In production, this would be the actual verification ID from Firebase
      final verificationId = 'simulated_verification_id_${DateTime.now().millisecondsSinceEpoch}'; // FIXED: Remove const

      return Right(verificationId);
    } on FirebaseAuthException catch (e) {
      return Left(_handleFirebaseAuthError(e));
    } catch (e) {
      return Left(AuthFailure(message: '2FA setup failed: $e'));
    }
  }

  // Helper method for Firebase Auth errors
  Failure _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return EmailAlreadyInUseFailure();
      case 'invalid-email':
        return AuthFailure(message: 'Invalid email address');
      case 'operation-not-allowed':
        return AuthFailure(message: 'Operation not allowed');
      case 'weak-password':
        return AuthFailure(message: 'Password is too weak');
      case 'user-disabled':
        return AuthFailure(message: 'This user has been disabled');
      case 'user-not-found':
        return UserNotFoundFailure();
      case 'wrong-password':
        return InvalidCredentialsFailure();
      case 'too-many-requests':
        return AuthFailure(message: 'Too many attempts. Try again later');
      default:
        return AuthFailure(message: e.message ?? 'Authentication failed');
    }
  }
}