import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../entities/alert_entity.dart';
import '../repositories/dashboard_repository.dart';

class MarkAlertReadParams extends Equatable {
  const MarkAlertReadParams({required this.alert});

  final AlertEntity alert;

  @override
  List<Object?> get props => <Object?>[alert];
}

class MarkAlertReadUseCase {
  const MarkAlertReadUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Either<Failure, void>> call(MarkAlertReadParams params) {
    return _repository.markAlertRead(alert: params.alert);
  }
}
