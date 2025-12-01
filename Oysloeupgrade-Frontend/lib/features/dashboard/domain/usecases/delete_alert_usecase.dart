import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/dashboard_repository.dart';

class DeleteAlertParams extends Equatable {
  const DeleteAlertParams({required this.alertId});

  final int alertId;

  @override
  List<Object?> get props => <Object?>[alertId];
}

class DeleteAlertUseCase {
  const DeleteAlertUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, void>> call(DeleteAlertParams params) {
    return _repository.deleteAlert(alertId: params.alertId);
  }
}
