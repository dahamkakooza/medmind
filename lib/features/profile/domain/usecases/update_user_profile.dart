import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_preferences_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateNotifications implements UseCase<UserPreferencesEntity, UpdateNotificationsParams> {
  final ProfileRepository repository;

  UpdateNotifications(this.repository);

  @override
  Future<Either<Failure, UserPreferencesEntity>> call(UpdateNotificationsParams params) async {
    return await repository.updateNotifications(params.notificationsEnabled);
  }
}

class UpdateNotificationsParams {
  final bool notificationsEnabled;

  UpdateNotificationsParams({required this.notificationsEnabled});
}
