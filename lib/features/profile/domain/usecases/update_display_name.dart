import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';

class UpdateDisplayName implements UseCase<void, UpdateDisplayNameParams> {
  final ProfileRepository repository;

  UpdateDisplayName(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateDisplayNameParams params) async {
    return await repository.updateDisplayName(params.displayName);
  }
}

class UpdateDisplayNameParams {
  final String displayName;

  UpdateDisplayNameParams({required this.displayName});
}
