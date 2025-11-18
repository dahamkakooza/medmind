// import 'package:dartz/dartz.dart';
// import '../../../../core/errors/failures.dart';
// import '../../../../core/usecases/usecase.dart';
// import '../entities/user_preferences_entity.dart';
// import '../repositories/profile_repository.dart';
//
// class SaveUserPreferences implements UseCase<void, SaveUserPreferencesParams> {
//   final ProfileRepository repository;
//
//   SaveUserPreferences(this.repository);
//
//   @override
//   Future<Either<Failure, void>> call(SaveUserPreferencesParams params) async {
//     return await repository.savePreferences(params.preferences);
//   }
// }
//
// class SaveUserPreferencesParams {
//   final UserPreferencesEntity preferences;
//
//   SaveUserPreferencesParams({required this.preferences});
// }
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';
import '../entities/user_preferences_entity.dart';

class SaveUserPreferences {
  final ProfileRepository repository;

  SaveUserPreferences(this.repository);

  Future<Either<Failure, void>> call(UserPreferencesEntity preferences) async { // CHANGED PARAMETER TYPE
    try {
      return await repository.savePreferences(preferences);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save preferences: $e'));
    }
  }
}
