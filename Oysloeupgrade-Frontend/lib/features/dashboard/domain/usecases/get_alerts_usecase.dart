import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/alert_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetAlertsUseCase {
  const GetAlertsUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, List<AlertEntity>>> call(NoParams params) {
    return _repository.getAlerts();
  }
}
