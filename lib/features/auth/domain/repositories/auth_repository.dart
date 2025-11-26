
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Stream to listen to authentication state changes
  Stream<UserEntity> get user;

  // Current user
  UserEntity get currentUser;

  // Email & Password Authentication
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  // Google Sign-In
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  // Sign Out
  Future<Either<Failure, void>> signOut();

  // Password Reset
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);

  // Email Verification
  Future<Either<Failure, void>> sendEmailVerification();

  // Check if user is authenticated
  bool get isSignedIn;

  // Reload user data
  Future<Either<Failure, void>> reloadUser();

  // ADD THIS METHOD: Get current user for auth check
  Future<UserEntity?> getCurrentUser();
}