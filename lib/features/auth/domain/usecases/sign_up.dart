import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class SignUp implements UseCase<UserEntity, SignUpParams> {
  final AuthRepository repository;

  SignUp(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignUpParams params) async {
    return await repository.signUpWithEmailAndPassword(
      email: params.email,
      password: params.password,
      displayName: params.displayName,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String displayName;

  SignUpParams({
    required this.email,
    required this.password,
    required this.displayName,
  });
}