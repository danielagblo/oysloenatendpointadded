import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/location_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetLocationsByRegionUseCase
    implements UseCase<List<LocationEntity>, String> {
  GetLocationsByRegionUseCase(this._repository);

  final DashboardRepository _repository;

  @override
  Future<Either<Failure, List<LocationEntity>>> call(String region) {
    return _repository.getLocationsByRegion(region);
  }
}
