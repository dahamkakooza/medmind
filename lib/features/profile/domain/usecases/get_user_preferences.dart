import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_preferences_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserPreferences implements UseCase<UserPreferencesEntity, NoParams> {
  final ProfileRepository repository;

  GetUserPreferences(this.repository);

  @override
  Future<Either<Failure, UserPreferencesEntity>> call(NoParams params) async {
    return await repository.getPreferences();
  }
}
