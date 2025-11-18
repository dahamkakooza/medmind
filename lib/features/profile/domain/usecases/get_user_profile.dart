import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_profile_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserProfile implements UseCase<UserProfileEntity, NoParams> {
  final ProfileRepository repository;

  GetUserProfile(this.repository);

  @override
  Future<Either<Failure, UserProfileEntity>> call(NoParams params) async {
    return await repository.getUserProfile();
  }
}
