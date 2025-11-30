import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

@injectable
class SignInWithEmailAndPassword implements UseCase<UserEntity, SignInParams> {
  final AuthRepository repository;

  SignInWithEmailAndPassword(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInParams params) async {
    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});
}