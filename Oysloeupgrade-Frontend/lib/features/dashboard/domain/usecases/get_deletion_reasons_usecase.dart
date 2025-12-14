import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/dashboard_repository.dart';

class GetDeletionReasonsUseCase implements UseCase<List<String>, NoParams> {
  GetDeletionReasonsUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, List<String>>> call(NoParams params) {
    return _repository.getDeletionReasons();
  }
}

