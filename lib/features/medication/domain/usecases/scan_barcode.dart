import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/medication_repository.dart';

class ScanBarcode implements UseCase<String, NoParams> {
  final MedicationRepository repository;

  ScanBarcode(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.scanBarcode();
  }
}