import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_preferences_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateThemeMode implements UseCase<UserPreferencesEntity, UpdateThemeModeParams> {
  final ProfileRepository repository;

  UpdateThemeMode(this.repository);

  @override
  Future<Either<Failure, UserPreferencesEntity>> call(UpdateThemeModeParams params) async {
    return await repository.updateThemeMode(params.themeMode);
  }
}

class UpdateThemeModeParams {
  final ThemeMode themeMode;

  UpdateThemeModeParams({required this.themeMode});
}
