import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/adherence_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class ExportAdherenceData implements UseCase<String, ExportAdherenceDataParams> {
  final AdherenceRepository repository;

  ExportAdherenceData(this.repository);

  @override
  Future<Either<Failure, String>> call(ExportAdherenceDataParams params) async {
    return await repository.exportAdherenceData(params.format);
  }
}

class ExportAdherenceDataParams {
  final String format;

  ExportAdherenceDataParams({required this.format});
}