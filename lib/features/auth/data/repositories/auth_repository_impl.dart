import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Stream<UserEntity> get user => const Stream.empty();

  @override
  UserEntity get currentUser => UserEntity.empty;

  @override
  Future<Either<Failure, UserEntity>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    // Temporary implementation for testing
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'test@medmind.com' && password == 'password') {
      return Right(UserEntity(
        id: 'test-user-123',
        email: email,
        displayName: 'Test User',
        dateJoined: DateTime.now(),
        emailVerified: true,
      ));
    } else {
      return const Left(InvalidCredentialsFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Temporary implementation for testing
    await Future.delayed(const Duration(seconds: 2));

    return Right(UserEntity(
      id: 'new-user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      dateJoined: DateTime.now(),
      emailVerified: false,
    ));
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    // Temporary implementation for testing
    await Future.delayed(const Duration(seconds: 2));

    return Right(UserEntity(
      id: 'google-user-123',
      email: 'google@medmind.com',
      displayName: 'Google User',
      dateJoined: DateTime.now(),
      emailVerified: true,
    ));
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 2));
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    return const Right(null);
  }

  @override
  bool get isSignedIn => false;

  @override
  Future<Either<Failure, void>> reloadUser() async {
    return const Right(null);
  }
}